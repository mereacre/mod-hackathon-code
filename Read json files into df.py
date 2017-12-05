
# This is the python code from the notebook
# developed by Chris Nott, IBM and Joe Plumb, IBM
# at the UK MOD AI Hackathon held on 28-29th November 2017
# using the IBM Data Science Experience on the IBM Cloud.
# It reads AIS (shipping data) from json files and amalgamates them
# into a dataframe ready for analysis.
# In the hackathon there were >24m json documents distributed
# unevenly in >8300 files totalling 3.9Gb.

# coding: utf-8

# In[29]:

# Creds to connect to the IBM Cloud Object Store containing the json objects
credentials = {
  'endpoints':'https://cos-service-blue.bluemix.net/endpoints',
  'apikey':'<add api key>',
  'resource_instance_id':'<add resource key>'
}

# In[30]:

# Define connection to IBM COS, view available buckets
import boto3
from botocore.client import Config
import json
import os
from os import listdir
from os.path import isfile, join
import pandas as pd
import pixiedust
from pprint import pprint
import requests
import random

print("Service credential:")
print(json.dumps(credentials, indent=2))
print("")
print("Connecting to COS...")

# Request detailed enpoint list
endpoints = requests.get(credentials.get('endpoints')).json()
#import pdb; pdb.set_trace()

# Obtain iam and cos host from the the detailed endpoints
iam_host = (endpoints['identity-endpoints']['iam-token'])
cos_host = (endpoints['service-endpoints']['cross-region']['us']['public']['us-geo'])


api_key = credentials.get('apikey')
service_instance_id = credentials.get('resource_instance_id')
#print('serviceid: '+service_instance_id)

# Constrict auth and cos endpoint
auth_endpoint = "https://" + iam_host + "/oidc/token"
service_endpoint = "https://" + cos_host

print("Creating client...")
# Get bucket list
cos = boto3.client('s3',
                    ibm_api_key_id=api_key,
                    ibm_service_instance_id=service_instance_id,
                    ibm_auth_endpoint=auth_endpoint,
                    config=Config(signature_version='oauth'),
                    endpoint_url=service_endpoint)


# Call S3 to list current buckets
response = cos.list_buckets()

# Get a list of all bucket names from the response
buckets = [bucket['Name'] for bucket in response['Buckets']]

# Print out the bucket list
print("Current Bucket List:")
print(json.dumps(buckets, indent=2))
print("---")
result = [bucket for bucket in buckets if 'cos-bucket-sample-' in bucket]


# In[50]:

# Defining functions:
# - To retrieve data from COS and return in big pd df
def makesmalldf(sublist):
    df = pd.DataFrame()
    for f in sublist:
        # get file from storage
        cos.download_file(Key=f, Filename=f,  Bucket=bucket)
        # load to df, note from https://stackoverflow.com/questions/30088006/loading-a-file-with-more-than-one-line-of-json-into-pythons-pandas
        with open(f) as f1:
            data = f1.readlines()
        data = map(lambda x: x.rstrip(), data)
        data_json_str = "[" + ','.join(data) + "]"
        tempdf = pd.read_json(data_json_str)
        # append to main df
        df = pd.concat([df, tempdf])
        # clear data from gpfs
        os.remove(f)
    return df

# - To build single df of whole dataset, from aggregated json files
def buildbigdf(directory, filenames):
    df = pd.DataFrame()
    for f in filenames:
        fileloc = directory + f
        tempdf = pd.read_json(fileloc)
        # append to main df
        df = pd.concat([df, tempdf])
    return df

# - To return object list return (limited to first 1k in a bucket)
def getobjectlist(bucket):
    # Call S3 to list current objects
    response = cos.list_objects(Bucket=bucket)
    # Get a list of all object names from the response
    objects = [object['Key'] for object in response['Contents']]
    return objects

# - To get all obj keys, from https://stackoverflow.com/questions/44238525/how-to-iterate-over-files-in-an-s3-bucket
def iteratebucketobjects(bucket):
    paginator = cos.get_paginator('list_objects')
    page_iterator = paginator.paginate(Bucket=bucket)
    for page in page_iterator:
        for item in page['Contents']:
            yield str(item['Key'])

# - To create list of lists for data aggregation
def createsubsets(fulllist):
    chunks = [fulllist[x:x+100] for x in range(0, len(fulllist), 100)]
    return chunks

# - To list tempfiles stored in GPFS
def listfiles(directory):
    onlyfiles = [f for f in listdir(directory) if isfile(join(directory, f))]
    return onlyfiles


# In[11]:

# test on subset of objects, using the simple object list function
Bucket='ais-data-json'
objects = getobjectlist(Bucket)
testobjects = objects[0:99]


# In[14]:

df1 = makesmalldf(Bucket, objects)


# In[15]:

display(df1)


# In[17]:

# Success!
# As we are working with > 8k files, concatenating these into a subset of larger files before joining into one big df
# makes sense, given inefficiencies experienced with the pd.concat() function. (Despite still actually being very slow)
allobjects = []

for i in iteratebucketobjects(bucket='ais-data-json'):
    allobjects.append(i)

objectnames = createsubsets(allobjects)

# Collect subset files from object store, write to pd df in memory in DSX, and write to GPFS dir 'ais'
counter = 0
for sublist in objectnames:
    df1 = makesmalldf(sublist)
    df1.reset_index().to_json('ais/temp'+str(counter)+'.json')
    counter = counter + 1


# In[ ]:

# Get file names, and build the big dataframe
filenames = [f for f in listdir('ais') if isfile(join('ais', f))]
df10 = buildbigdf('ais', filenames)
display(df10)


# In[58]:

# Sort the dataframe based on requirements
df3 = df10[['mmsi','timestamp','latitude','longitude']].copy()
sortedDf = df3.sort_values(['mmsi','timestamp'])

display(sortedDf)


# In[ ]:

# Write results to GPFS (need to update to write back to COS)
sortedDf.reset_index().to_json('pivoteddf.json', orient='index')
df10.reset_index().to_json('fulldf.json', orient='index')
