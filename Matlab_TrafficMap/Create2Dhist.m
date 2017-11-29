% This should load in the LatLong data ad create a 2D histogram of all of
% the LatLong ponts
clearvars
% % first load in the relevant data
% % 
LatLong = loadData('LatLong');
Speeds = loadData('Speeds');
NoRoutes = size(LatLong,1);
MaxX = 0;
MinX = 0;
MaxY = 0;
MinY = 0;
% Now convert the latlong data onto a 2D plane representation
LatLong2 = LatLong;
for route = 1:NoRoutes
    Lat = LatLong{route}(:,1);
    Long = LatLong{route}(:,2);
    
   [X,Y] = grn2eqa(Lat,Long);
   
   if max(X)>MaxX
       MaxX = max(X);     
   end
   if min(X)<MinX
       MinX = min(X);
   end
   if max(Y)>MaxY
       MaxY = max(Y);
   end
   if min(Y)<MinY
       MinY = min(Y);
   end
  
   Dup_X = rude(ceil(Speeds{route}),X);
   Dup_Y = rude(ceil(Speeds{route}),Y);
   LatLong2{route} = zeros(size(Dup_X,2),2);
   LatLong2{route}(:,1) = Dup_X;
   LatLong2{route}(:,2) = Dup_Y;
end

% The oints should be weighted accoding to the velocity of the ship at that
% time, as vessels travelling contrbute more information

% [MinX,MinY] = grn2eqa(55.070039, -6.116419);
% [MaxX,MaxY] = grn2eqa(55.656495, -5.670648);
% so for each route, create a 2D histogram with fixed bins, with counts
% that are updated for each new file. 
[MinX,MinY] = grn2eqa(51.943308, -8.265422);
[MaxX,MaxY] = grn2eqa(62.224611, -0.026169);
% so for each route, create a 2D histogram with fixed bins, with counts
% that are updated for each new file. 

BinWidth = (MaxX-MinX)/800;



BinEdgesX = (MinX-BinWidth/2):BinWidth:(MaxX+BinWidth/2);
BinEdgesY = (MinY-BinWidth/2):BinWidth:(MaxY+BinWidth/2);
N2 = 0;
for route = 1:NoRoutes

    X = LatLong2{route}(:,1);
    Y = LatLong2{route}(:,2);
    
    [N,Xedges,Yedges] = histcounts2(X,Y,BinEdgesX,BinEdgesY);
    N2 = N2 + N;
end

figure()
imagesc(rot90(log(N2)))

text = jsonencode(N2);

[a,BinEdgesLong] = eqa2grn(BinEdgesX,zeros(1,size(BinEdgesX,2)));
[BinEdgesLat,b] = eqa2grn(zeros(1,size(BinEdgesY,2)),BinEdgesY);



Xmin = [];
Xmax = [];
Ymin = [];
Ymax = [];
Intensity = [];
for pixel = 1:numel(N2(:))
    [x,y] = ind2sub(size(N2),pixel);
    Xmin(end+1) = BinEdgesLong(x);
    Xmax(end+1) = BinEdgesLong(x+1);
    Ymin(end+1) = BinEdgesLat(y);
    Ymax(end+1) = BinEdgesLat(y+1);
    Intensity(end+1) = N2(pixel);
end

text = jsonencode(table(Xmin',Xmax',Ymin',Ymax',Intensity'));

fileID = fopen('BoundingBox.json','w');
fprintf(fileID,text);
fclose(fileID);





