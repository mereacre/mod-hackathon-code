addpath('AIS')

jsonfiles = dir('AIS/ais-data-json/*.json');
NoFiles = size(jsonfiles,1);

% speeds = cell(NoFiles,1);
timeAxis = cell(NoFiles,1);


for fileNo = 1:NoFiles
    %test reading in a single json file
    text = fileread(['AIS/ais-data-json/', jsonfiles(fileNo).name]);
    [startpoints,endpoints] = regexp(text,'\{([^}]+)\}');
    NoPoints = size(startpoints,2);
%     speeds{fileNo} = zeros(NoPoints,1);
     timeAxis{fileNo} = zeros(NoPoints,1);
    Jsondata = cell(NoPoints,1);
    for i = 1:size(startpoints,2)
        test = jsondecode(text(startpoints(i):endpoints(i)));
%         speeds{fileNo}(i) = test.sog;
         timeAxis{fileNo}(i) = test.timestamp;
        Jsondata{i} = test; 
    end
    
    [~,idx] = sort(timeAxis{fileNo});
    Jsondata = Jsondata(idx);
    save(strcat('Mat_Json_files/',string(fileNo),'.mat'),'Jsondata')
%     timeAxis{fileNo} = timeAxis{fileNo}(idx);
%     speeds{fileNo} = speeds{fileNo}(idx);
    if rem(fileNo,200) == 0
        disp(fileNo)
    end
end

