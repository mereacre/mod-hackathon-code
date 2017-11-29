function OUT = loadData(Field)

files = dir(strcat('Mat_Json_files/',Field,'*'));

NoFiles = size(files,1);

OUT = cell(NoFiles,1);

for i = 1:NoFiles
    temp = load(strcat('Mat_Json_files/',files(i).name));
    OUT{i} = temp.(Field);
end


