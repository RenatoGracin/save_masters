clear all
%close all

addpath('C:\Users\Darjan\Desktop\SintData');
addpath('C:\Users\Darjan\Desktop\moj_optics\data');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions');



%load('UAE_data_exp_13_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_09_2018_07_23.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_07_2018_07_16_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');   %dosta sumovit
load('UAE_data_exp_08_2018_07_19.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_10_25_07_2018_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_10_25_07_2018_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_12_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');     
%load('UAE_data_exp14_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp14_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp14_part_03.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_06_2018_06_05_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
% prikaz podataka

% figure
% scatter( UAE_single_t_mat_hr, UAE_single_f_mat, 'b');
% hold on
% scatter( UAE_multi_t_mat_hr, UAE_multi_f_mat(:,1), 'r');


% data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1); UAE_single_f_mat; UAE_multi_f_mat(:,1); UAE_single_f_mat; UAE_multi_f_mat(:,1) ]/2e3;
% data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr; UAE_single_t_mat_hr.*-1+2*max(UAE_single_t_mat_hr); UAE_multi_t_mat_hr.*-1+2*max(UAE_multi_t_mat_hr); UAE_single_t_mat_hr+2*max(UAE_multi_t_mat_hr); UAE_multi_t_mat_hr+2*max(UAE_multi_t_mat_hr)];

%data_all=importdata('dataclust.txt')';

data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1);UAE_multi_f_mat((~isnan(UAE_multi_f_mat(:,2))),2);UAE_multi_f_mat((~isnan(UAE_multi_f_mat(:,3))),3)]/1e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr; UAE_multi_t_mat_hr(~isnan(UAE_multi_f_mat(:,2))); UAE_multi_t_mat_hr(~isnan(UAE_multi_f_mat(:,3)))];  

%  data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/1e3;
%  data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  

% data_all(1,:) = [ UAE_multi_f_mat(:,1);UAE_multi_f_mat(:,2);UAE_multi_f_mat(:,3)]/1e3;
% data_all(2,:) = [ UAE_multi_t_mat_hr; UAE_multi_t_mat_hr; UAE_multi_t_mat_hr];  

data_all = sortrows(data_all',2);


% 
% figure
% scatter( data_all(:,2), data_all(:,1), 'b','.');
% title('Vremensko-frekvencijski prikaz UAE');
% ylabel('frekvencija [kHz]');
% xlabel('vrijeme [h]');
% set(gca,'Box','on');
% grid on
% ylim([100 700]);



%% razdvajanje uzoraka po zadanom broju

figure
vrijeme = 0;

%parametri
boxSize = 500; %block size
crosPointNum =200;


Nmin=25;
eps = 8;
type = 2;
w = 0.5;
t = 160;

iter = 0;
clustersMatrix = zeros(200,5000);
colorMatrix = zeros(10,50);
prevCluster=zeros(crosPointNum,1);
newClustInd=0;

% podesavanje zadnjeg intervala
totalStages = floor((size(data_all,1)-crosPointNum)/(boxSize-crosPointNum));
%totalStages =1;

firstStage = 0;
iter=0;

for step = firstStage:totalStages-1

data = data_all(step*(boxSize-crosPointNum)+1:(step+1)*(boxSize)-step*crosPointNum,:);    
%data = [data_all(1:500,1)' ; (data_all(1:500,2)+step*100)']';

% figure
% scatter( data(:,2), data(:,1), 'b','.');
% title('Input data');
% ylabel('frequency, kHz');
% xlabel('time, h');
% axis([ min(data(:,2)) max(data(:,2)) 50 350]);
% set(gca,'Box','on');

tic
[orderedList, reachDistList, coreDistList, procesList] = optics(data, Nmin, eps);

 for i = 1:size(data,1)
     orderedReachList(i,1) = reachDistList(orderedList(i));
 end
 

large_cluster_perc = 1;
merge_perc = 0.8;

[SetClusters, clustnum] = gradient_clustering( orderedReachList, Nmin, t, w, large_cluster_perc, merge_perc, type );


[clusterIndices]=getClusterIndices(orderedList, SetClusters, clustnum);

[clustersMatrix, prevCluster, newClustInd, newClustTest, colorMatrix] = optics_merging(clusterIndices, clustersMatrix, prevCluster,  crosPointNum, clustnum, newClustInd, iter, step, colorMatrix);
iter=1;

if step == 0
     timeStampStart = 0;
     prevClustVect = 0;
     currClustVect = 0;
     prevyMaxEnd = 0; 
     prevyMinEnd = 0;
 else

    prevClustVect = clustersMatrix(:,step);
    currClustVect = clustersMatrix(:,step+1);
end

timeStampEnd = data(boxSize,2);

[timeMin, timeMax, yMinStart, yMinEnd, yMaxStart, yMaxEnd] = feature_extraction(data, clusterIndices, clustnum, timeStampEnd, timeStampStart, crosPointNum, newClustTest, prevClustVect, currClustVect, prevyMaxEnd, prevyMinEnd, Nmin);
prevyMaxEnd = yMaxEnd;
prevyMinEnd = yMinEnd;

timeStampStart = timeStampEnd;

vrijeme=vrijeme+toc;

colors = ['b','r','g','y','c','m','k'];
colormaps = ['Blues','BuGn','BuPu','GnBu','Greens','Reds','OrRd','Oranges','PuBu'];
cstart = [1,6,10,14,18,24,28,32,39];
cend = [5,9,13,17,23,27,31,38,42];

if step==0
    for x = 1:boxSize
           if clusterIndices(x)~=0
               totalClusterInd(step*(boxSize-crosPointNum)+x) = clustersMatrix(clusterIndices(x), step+1);
           else
               totalClusterInd(step*(boxSize-crosPointNum)+x) = 0;
           end
    end
else
    for x = crosPointNum:boxSize
           if clusterIndices(x)~=0
               totalClusterInd(step*(boxSize-crosPointNum)+x) = clustersMatrix(clusterIndices(x), step+1);
           else
               totalClusterInd(step*(boxSize-crosPointNum)+x) = 0;
           end
    end    
end


if clustnum ~=0 
     for i=1:clustnum 
        index = clusterIndices(:)==i;
        ylim([ 100 700]);   
        xlim([ 0 max(data_all(:,2))]);
        %scatter(data(index,2),data(index,1),'.',colors(mod(clustersMatrix(i,step+1)-1,7)+1));
        

        hold on
        grid on 
        set(gca,'box','on');
        set(gca,'FontSize',14)

        fill([timeMin(i) timeMax(i) timeMax(i) timeMin(i) ],[yMinStart(i) yMinEnd(i) yMaxEnd(i) yMaxStart(i) ], colors(mod(clustersMatrix(i,step+1)-1,7)+1));

     end 
     
end
 title('Rezultat skupa algoritama');
 xlabel('vrijeme [h]');
 ylabel('frekvencija [kHz]');
 index = totalClusterInd(:)==0;
 scatter(data_all(index,2),data_all(index,1),4,[0.8 0.8 0.8],'filled'); 

end 


%%
%  colors = ['b','r','g','y','c','m','k', [0.8500, 0.3250, 0.0980],[0.9290, 0.6940, 0.1250],[0.6350, 0.0780, 0.1840],[0.3010, 0.7450, 0.9330],[0.4940, 0.1840, 0.5560]];
% figure
% for i=1:max(totalClusterInd)
%     index = totalClusterInd(:)==i;
%     ylim([ 100 900]);   
%     xlim([ 0 max(data_all(:,2))]);
%     scatter(data_all(index,2),data_all(index,1),8,colors(mod(i-1,12)+1),'filled');
%     
%     hold on
%     grid on 
%     set(gca,'box','on');
%     ylabel('frekvencija [kHz]');
%     xlabel('vrijeme [h]');
%     
%     title('Set podataka 10, Nmin = 100');
%     
% end
% 
%  index = totalClusterInd(:)==0;
%  scatter(data_all(index,2),data_all(index,1),8,[0.8 0.8 0.8],'filled'); 