clear all
%close all

s = serial('COM5','BaudRate',115200,'Timeout',50);
s.InputBufferSize = 50000;
fopen(s);

%%

addpath('C:\Users\Darjan\Desktop\moj_optics\data');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions');
addpath('C:\Users\Darjan\Desktop\SintData');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions_help');

%load('UAE_data_exp_13_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_09_2018_07_23.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
load('UAE_data_exp_07_2018_07_16_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');   %dosta sumovit
%load('UAE_data_exp_08_2018_07_19.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_10_25_07_2018_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_10_25_07_2018_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_12_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');     
%load('UAE_data_exp14_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp14_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp14_part_03.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');

data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];
  
data_all = sortrows(data_all',2);

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

vrijeme = 0;
flushinput(s);

%parametri
boxSizeArr = [ 50, 100, 200, 500, 1000, 2000];
crossPointPerc = [ 0.10, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50];
epsilon = [1, 2, 3, 5, 7, 10, 15];
NminPerc = [ 0.02, 0.03, 0.04, 0.05, 0.07, 0.10, 0.15];


for i = 1:6
    for j= 1:7       
        for k= 1:7
            for z = 1:7
printf('i=%d, j=%d, k=%d, z=%d', i, j, k, z); 
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
iter=0;

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

TIME_Sint_01(z,:,i,j,k)=[vrijemeUkupno vrijemeAvg vrijemeMax vrijemeMin];
MAT_Sint_01(z,:,i, j,k)=totalClusterInd;

            end
        end
    end
end


%%
figure
indices = MAT_Sint_01(3,:,5, 4, 4);
TIME_Sint_01(4,:,4,6,6)
%indices = totalClusterInd;
colors = ['b','r','g','y','c','m','k'];
    
for x=1:max(indices)
scatter(data_all(indices==x,2), data_all(indices==x,1),'.',colors(mod(x-1,7)+1));
hold on
end
ylim([ 25 350]); 