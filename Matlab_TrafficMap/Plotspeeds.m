figure()

for i = 1:16
    
subplot(4,4,i)
PingNumber = size(speeds{i},1);
if PingNumber < 40
    filterLength = 1;
else
    filterLength = 30;
end
convSpeeds = conv(speeds{i},ones(filterLength,1)./filterLength,'same');
plot(timeAxis{i},convSpeeds)


end
