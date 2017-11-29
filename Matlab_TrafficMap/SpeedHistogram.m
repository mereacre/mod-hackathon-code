clearvars
Speeds = loadData('Speeds');
NoRoutes = size(Speeds,1);
speeds = [];
for route = 1:NoRoutes
    speeds = [speeds,Speeds{route}'];
end
figure()
histogram(speeds)

