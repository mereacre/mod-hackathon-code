%goal of the file is to save the individual fields for fast access

mat_files = dir('Mat_Json_files/*.mat');
NoFiles = size(mat_files,1);
for file = 1:size(mat_files,1)
    
    load(strcat('Mat_Json_files/',mat_files(file).name));
    
    NoPings = size(Jsondata,1);
    LatLong = zeros(NoPings,2);
    Speeds = zeros(NoPings,1);
    MMSI = zeros(NoPings,1);
    Cog = zeros(NoPings,1);
    Times = zeros(NoPings,1);
    
    for i = 1:size(Jsondata,1)
        LatLong(i,:) = [Jsondata{i}.latitude,Jsondata{i}.longitude];
        Speeds(i) = Jsondata{i}.sog;
        MMSI(i) = Jsondata{i}.mmsi;
        Cog(i) = Jsondata{i}.cog;
        Times(i) = Jsondata{i}.timestamp;
    end
    
    save(strcat('Mat_Json_files/','LatLong',string(file)),'LatLong');
    save(strcat('Mat_Json_files/','Speeds',string(file)),'Speeds');
    save(strcat('Mat_Json_files/','MMSI',string(file)),'MMSI');
    save(strcat('Mat_Json_files/','Cog',string(file)),'Cog');
    save(strcat('Mat_Json_files/','Times',string(file)),'Times');
    
                
end


