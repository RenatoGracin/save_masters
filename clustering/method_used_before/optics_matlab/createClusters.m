addpath('C:\Users\Darjan\Desktop\SintData');

% for i=1:16
% 
% if i<10
% load(sprintf('SintData_0%d', i));
% else
% load(sprintf('SintData_%d', i));
% end
% 
% figure
% scatter(data_all(:,2),data_all(:,1),'.');
% ylim([0 400]);
% grid on
% 
% end

%%
clear all

totalSize = 2000;
clustNum = 4;
newClustInd = 1;
theta = 0;                      % angle of rotation
center=[200; 80];

freqVal = [75 150 225 300];       % central freq values
freqDens = [10 5 5 2];         % width of the cluster 

timeVal = [50 50 50 50];         % central time values
timeDens = [15 15 15 15];          % time width of the cluster

clustPoints = [450 450 450 450];
noisePoints = 200;


% creating data

data=zeros(2, totalSize);

data(1,1:clustPoints(1)) = normrnd(freqVal(1), freqDens(1), [clustPoints(1),1])+linspace(20,-20, clustPoints(1))';
data(2,1:clustPoints(1)) = sort(normrnd(timeVal(1), timeDens(1), [clustPoints(1),1]));
data(3,1:clustPoints(1)) = newClustInd;
newClustInd = newClustInd+1;

index = clustPoints(1);

i=2;
while(i<=clustNum)
   data(1, index+1:index+clustPoints(i)) = normrnd(freqVal(i), freqDens(i), [clustPoints(i),1])+linspace(20,-20, clustPoints(i))'; 
   data(2, index+1:index+clustPoints(i)) = sort(normrnd(timeVal(i), timeDens(i), [clustPoints(i),1]));
   data(3, index+1:index+clustPoints(i)) = newClustInd;
   newClustInd = newClustInd+1;
   
   index = index+clustPoints(i);
   i=i+1;
end

data(1, index+1:end) = randi([0 400], noisePoints, 1);
data(2, index+1:end) = randi([0 ceil(max(data(2,:)))], noisePoints,1);
data(3, index+1:end) = 0;

data=data';

for i=1:totalSize
   if data(i,1)<1
       data(i,1)=1;
   end
   if data(i,2)<1
       data(i,2)=1;
   end
end

data_all=sortrows(data,2);
SinIndices = data_all(:,3); 
data_all=data_all(:,1:2);

colors = ['b','r','g','y','c','m','k'];

figure
for i=1:clustNum 
        index = SinIndices(:)==i;
        ylim([ 0 400]);        
        scatter(data_all(index,2),data_all(index,1),'.',colors(i));
        hold on
        
        Density(i)=clustPoints(i)/(3*freqDens(i)*3*timeDens(i)*pi);
        
end 
index = SinIndices(:)==0;
scatter(data_all(index,2),data_all(index,1),'.');

clear data;

%%

clear all

newClustInd = 1;
totalSize = 2000;
clustNum = 1;
theta = 0;                      % angle of rotation
center=[200; 80];

freqVal = [ 200 ];       % central freq values
freqDens = [ 80 ];         % width of the cluster 

% freqVal = [200, 200, 200, 200];       % central freq values
% freqDens = [40, 20, 10, 10];         % width of the cluster 

timeVal = [ 50];         % central time values
timeDens = [ 40 ];          % time width of the cluster

% timeVal = [20, 40, 60, 80];         % central time values
% timeDens = [5, 5, 5, 5];          % time width of the cluster

clustPoints = [1800];
noisePoints = 200;

rng('shuffle');

% creating data

data=zeros(2, totalSize);

data(1,1:clustPoints(1)) = freqVal(1)-freqDens(1)+2*freqDens(1)*rand(clustPoints(1),1);%+linspace(-20,20, clustPoints(1))';
data(2,1:clustPoints(1)) = sort(timeVal(1)-timeDens(1)+2*timeDens(1)*rand(clustPoints(1),1));
data(3,1:clustPoints(1)) = newClustInd;
newClustInd = newClustInd+1;

index = clustPoints(1);
for i=2:clustNum
   data(1, index+1:index+clustPoints(i)) = freqVal(i)-freqDens(i)+2*freqDens(i)*rand(clustPoints(i),1);%+linspace(-20,20, clustPoints(i))';
   data(2, index+1:index+clustPoints(i)) = sort(timeVal(i)-timeDens(i)+2*timeDens(i)*rand(clustPoints(i),1));
   data(3, index+1:index+clustPoints(i)) = newClustInd;
   newClustInd = newClustInd+1;
   
   index = index+clustPoints(i);
end

data(1, index+1:end) = randi([0 400], noisePoints, 1);
data(2, index+1:end) = randi([0 100], noisePoints,1);
data(3, index+1:end) = 0;

for i=1:totalSize
   for j=1:clustNum
    if data(3, i) == 0 && data(1,i) <= freqVal(j)+freqDens(j) && data(1,i) >= freqVal(j)-freqDens(j) && data(2,i) <= timeVal(j)+timeDens(j) && data(2,i) >= timeVal(j)-timeDens(j)
        data(3,i)=j;
    end
   end
end

data=data';

for i=1:totalSize
   if data(i,1)<1
       data(i,1)=1;
   end
   if data(i,2)<1
       data(i,2)=1;
   end
end

data_all=sortrows(data,2);
SinIndices = data_all(:,3); 
data_all=data_all(:,1:2);

colors = ['b','r','g','y','c','m','k'];

figure
for i=1:clustNum 
        index = SinIndices(:)==i;
        ylim([ 0 400]);        
        scatter(data_all(index,2),data_all(index,1),'.',colors(i));
        hold on
        
        Density(i)=numel(find(SinIndices==i))/(freqDens(i)*timeDens(i)*4);
        
end 
index = SinIndices(:)==0;
scatter(data_all(index,2),data_all(index,1),'.');

clear data;

%%
% i=1;
% 
% fname = sprintf('SintIndices_%d', i);
% save(fname, 'SinIndices'); 
% 
% fname = sprintf('SintIndices_%d', i);
% save(fname, 'SinIndices'); 
