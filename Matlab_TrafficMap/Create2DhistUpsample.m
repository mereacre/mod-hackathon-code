% % This should load in the LatLong data ad create a 2D histogram of all of
% % the LatLong ponts
% % clearvars
% % % first load in the relevant data
% % 
% % LatLong = loadData('LatLong');
% % Speeds = loadData('Speeds');
% % Times = loadData('Times');
% NoRoutes = size(LatLong,1);
% MaxX = 0;
% MinX = 0;
% MaxY = 0;
% MinY = 0;
% % Now convert the latlong data onto a 2D plane representation
% LatLong2 = LatLong;
% for route = 1:NoRoutes
%     Lat = LatLong{route}(:,1);
%     Long = LatLong{route}(:,2);
%     
%    [X,Y] = grn2eqa(Lat,Long);
%    
%    if max(X)>MaxX
%        MaxX = max(X);     
%    end
%    if min(X)<MinX
%        MinX = min(X);
%    end
%    if max(Y)>MaxY
%        MaxY = max(Y);
%    end
%    if min(Y)<MinY
%        MinY = min(Y);
%    end
%    % Now define an array of sample points to upsample the distances
%    points = [];
%    for i = 1:size(Speeds{route},1)-1
%        speed1 = Speeds{route}(i);
%        interPoints = interp1([1,2],[i,i+1],1:1/ceil(speed1):2-1/ceil(speed1));
%        points = [points,interPoints];
%    end
%    Speeds2 = interp1(1:size(Speeds{route},1),Speeds{route},points);
%    X = interp1(1:size(X,1),X,points);
%    Y = interp1(1:size(Y,1),Y,points); 
%    Dup_X = rude(ceil(Speeds2),X);
%    Dup_Y = rude(ceil(Speeds2),Y);
% 
%    
%    LatLong2{route} = zeros(size(Dup_X,2),2);
%    LatLong2{route}(:,1) = Dup_X;
%    LatLong2{route}(:,2) = Dup_Y;
% end
% 
% save('Latlong.mat','LatLong2');
% The oints should be weighted accoding to the velocity of the ship at that
% time, as vessels travelling contrbute more information

% The following two lines were to creat a bounding box to view within

[MinX,MinY] = grn2eqa(51.943308, -8.265422);
[MaxX,MaxY] = grn2eqa(62.224611, -0.026169);
% so for each route, create a 2D histogram with fixed bins, with counts
% that are updated for each new file. 

BinWidth = (MaxX-MinX)/800;

BinEdgesX = (MinX-binWidthX/2):BinWidth:(MaxX+binWidthX/2);
BinEdgesY = (MinY-binWidthY/2):BinWidth:(MaxY+binWidthY/2);
N2 = 0;
for route = 1:NoRoutes

    X = LatLong2{route}(:,1);
    Y = LatLong2{route}(:,2);
    
    [N,Xedges,Yedges] = histcounts2(X,Y,BinEdgesX,BinEdgesY);
    N2 = N2 + N;
    if rem(route,500) == 0
        disp(route)
    end
end

figure()
imagesc(rot90(log(N2)))