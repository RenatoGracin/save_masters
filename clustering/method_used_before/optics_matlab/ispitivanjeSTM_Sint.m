clear all
instrreset
%close all

s = serial('COM5','BaudRate',115200,'Timeout',50);
s.InputBufferSize = 50000;
fopen(s);

%%

addpath('C:\Users\Darjan\Desktop\moj_optics\data');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions');
addpath('C:\Users\Darjan\Desktop\SintData');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions_help');

load('SintData_17.mat');


%% pocetni prijenos svih podataka

pauseTime = 0.005;
for i=1:size(data_all,1)
    fprintf(s,'%f\n',data_all(i,1));
    pause(pauseTime);
end

for i=1:size(data_all,1)
    fprintf(s,'%f\n',data_all(i,2));
    pause(pauseTime);
end

%% razdvajanje uzoraka po zadanom broju

iter=1;
vrijeme = 0;
flushinput(s);

%parametri
boxSizeArr = [ 100, 200, 500, 1000, 2000];
crossPointPerc = [ 0.10, 0.15, 0.20, 0.30, 0.50];
epsilon = [3, 5, 7, 10, 15];
NminPerc = [ 0.02, 0.03, 0.04, 0.05, 0.07];


for i = 1:5
    for j= 1:5       
        for k= 1:5
            for z = 1:5
printf('i=%d, j=%d, k=%d, z=%d, %d from 625', i, j, k, z, iter); 
%%
% i = 2; 
% j=1; 
% k=1; 
% z=1;

boxSize = boxSizeArr(i);
crosPointNum = ceil(boxSize*crossPointPerc(j));
eps = epsilon(k);
Nmin = ceil(boxSize*NminPerc(z));

large_cluster_perc = 0.8;
merge_perc = 0.8;
type = 2;
w = 0.5;
t = 160;

firstStage = 0;
iter=iter+1;

totalClusterInd=zeros(size(data_all,1),1);
clustMat = zeros(200,5000);
vrijemeUkupno=0;
vrijemeMin=0;
vrijemeMax=0;

reset=1;

totalStages = floor((size(data_all,1)-crosPointNum)/(boxSize-crosPointNum));
%totalStages =1;

%reset
for step = firstStage:totalStages-1
       
    fprintf(s,'%d\n',reset);
    pause(pauseTime);
    fprintf(s,'%d\n',boxSize);
    pause(pauseTime);
    fprintf(s,'%d\n',crosPointNum);
    pause(pauseTime);
    fprintf(s,'%d\n',eps);
    pause(pauseTime);
    fprintf(s,'%d\n',Nmin);    
  
    reset = 0;
    
    tic
    clustNum = str2double(fgetl(s)); %    
    vrijeme=toc;

    vrijemeUkupno=vrijeme+vrijemeUkupno;

    if vrijeme<vrijemeMin
        vrijemeMin=vrijeme;
    end
    if step==0
        vrijemeMax=vrijeme;
        vrijemeMin=vrijeme;
    end
    if vrijeme>vrijemeMax
        vrijemeMax=vrijeme;
    end

    stmclusterIndices = zeros(boxSize,1);
    yMinStart = zeros(clustNum,1);
    yMinEnd = zeros(clustNum,1);
    yMaxStart = zeros(clustNum,1);
    yMaxEnd = zeros(clustNum,1);
    timeMin = zeros(clustNum,1);
    timeMax = zeros(clustNum,1);

    for x=1:boxSize
        stmclusterIndices(x)=str2double(fgetl(s));%
    end

    for x=1:clustNum
        clustMat(x,step+1)=str2double(fgetl(s));%
    end

    for x=1:clustNum
       timeMin(x)=str2double(fgetl(s)); 
       timeMax(x)=str2double(fgetl(s)); 
       yMinStart(x)=str2double(fgetl(s));
       yMaxStart(x)=str2double(fgetl(s)); 
       yMinEnd(x)=str2double(fgetl(s)); 
       yMaxEnd(x)=str2double(fgetl(s));   
    end

    for x = 1:boxSize
       if stmclusterIndices(x)~=0
       totalClusterInd(step*(boxSize-crosPointNum)+x) = clustMat(stmclusterIndices(x), step+1);
       else
       totalClusterInd(step*(boxSize-crosPointNum)+x) = 0;
       end
    end


end

vrijemeAvg = vrijemeUkupno/totalStages;

TIME_Sint_17(z,:,i,j,k)=[vrijemeUkupno vrijemeAvg vrijemeMax vrijemeMin];
MAT_Sint_17(z,:,i, j,k)=totalClusterInd;

            end
        end
    end
end


%%
figure
indices = MAT_Sint_17(1,:,4, 5, 2);
TIME_Sint_17(4,:,3,4,4)
%indices = totalClusterInd;
colors = ['b','r','g','y','c','m','k'];
    
for x=1:max(indices)
scatter(data_all(indices==x,2), data_all(indices==x,1),'.',colors(mod(x-1,7)+1));
hold on
end
ylim([ 0 400]); 
xlim([ 0 100]);
