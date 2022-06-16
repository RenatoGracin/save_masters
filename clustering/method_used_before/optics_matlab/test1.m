clear all
close all

% addpath('C:\Users\Darjan\Desktop\moj_optics\data');
% addpath('C:\Users\Darjan\Desktop\moj_optics\functions');
% addpath('C:\Users\Darjan\Desktop\SintData');
% addpath('C:\Users\Darjan\Desktop\moj_optics\functions_help');
addpath('.\data');
addpath('.\functions');
% addpath('C:\Users\Darjan\Desktop\SintData');
addpath('.\functions_help');

% load('UAE_data_exp_13_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
% load('UAE_data_exp_09_2018_07_23.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
load('UAE_data_exp_07_2018_07_16_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');   %dosta sumovit
% %load('UAE_data_exp_08_2018_07_19.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_10_25_07_2018_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_10_25_07_2018_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
% load('UAE_data_exp_12_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');     
%load('UAE_data_exp14_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp14_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp14_part_03.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');

%  figure
%  scatter( UAE_single_t_mat_hr, UAE_single_f_mat,8, 'b','.');
%  hold on
%  scatter( UAE_multi_t_mat_hr, UAE_multi_f_mat(:,1),8, 'r','.');
 
% data_all(1,:) = [UAE_single_f_mat ; UAE_multi_f_mat(:,1)]./1000; %1000
% data_all(2,:) = [UAE_single_t_mat_hr ; UAE_multi_t_mat_hr ];

% data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/1e3;
% data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];


dataset_name = 'big_dataset';

% load(['../../input_matrices/' dataset_name '_feature_selection.mat']);
addpath('C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\input_matrices\');
load(['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\input_matrices\big_dataset_stand_feature_matrix.mat']);


data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1);UAE_multi_f_mat(:,2);UAE_multi_f_mat(:,3)]/1e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr; UAE_multi_t_mat_hr; UAE_multi_t_mat_hr];  

data = sortrows(data_all',2);

data = dataset(:,[5,14,18]);

%% Data from equalized feature matrix
% down_size = 2;
% data= [downsample(equ_feature_matrix(:,18),down_size),downsample(equ_emiss_max_t_hr,down_size)];
% 
% %% Standardize dataset
% data(:,1) = (data(:,1)-mean(data(:,1)))/std(data(:,1));
% data(:,2) = (data(:,2)-mean(data(:,2)))/std(data(:,2));

figure
scatter( data(:,2), data(:,1), 'b','.');
title('Ulazni podaci za grupiranje');
ylabel('frequency, kHz');
%%

Nmin =70; % 10% ukupnih
eps = 8; % 40 za 2000
Nmin =10; % 10% ukupnih
eps = 0.04; % 40 za 2000
% Nmin = 5; 
% eps = 0.0889; %clusterDBSCAN.estimateEpsilon(data,Nmin,Nmin*2); % 0.0889

tic
[orderedList, reachDistList, coreDistList, procesList] = faster_optics(data, Nmin, eps);
toc


 for i = 1:size(data,1)
     orderedReachList(i,1) = reachDistList(orderedList(i));
 end
 
 
 figure
 plot(orderedReachList, 'linewidth', 1);
 grid on
 title('Rezultat OPTICS algoritma','fontSize' ,20);
%  ylabel('dohvatna udaljenost','fontSize' , 16);
%  xlabel('redoslijed obrađivanih točaka','fontSize' , 16);
%  set(gca,'FontSize',14)
 xlim([0 3000]);
 

w = 0.5;
t = 160;

large_cluster_perc = 1;
merge_perc = 0.8;

tic
[SetClusters, clustNum] = gradient_clustering( orderedReachList, Nmin, t, w, large_cluster_perc, merge_perc, 2);
toc

figure
plot(orderedReachList);
hold on
axis([0 size(reachDistList,1) 0 max(reachDistList(reachDistList~=1024))*3]);
set(gca,'Box','on');
ylim([0 20]);
grid on
title('Dohvatna krivlulja, konačne otkrivene grupacije');
ylabel('dohvatna udaljenost');
xlabel('redoslijed obrađivanih točaka');

 for i=1:clustNum
    
    first = SetClusters(i,1);
    last = SetClusters(i,2);
    line([first;last],[orderedReachList(first);orderedReachList(last)],'color',rand(1,3));

 end 


clusterIndices=getClusterIndices(orderedList, SetClusters, clustNum);

show_3D_clustering(data,clusterIndices);

if clustNum>0
    clustSize = SetClusters(:,3);
    %[startX, endX, startY, endY, centerF, centerT] = feature_extraction(data, clusterIndices, clustNum, clustSize);
    
    colors = ['b','r','g','y','c','m','k'];
    figure
    hold on
    grid on
    xlabel('vrijeme [h]');
    ylabel('frekvencija [kHz]');
    title('Rezultat GC algoritma, set podataka 8');
   
    for i=0:clustNum
        index = find(clusterIndices==i);
        labels{i+1} = ['clust: ' num2str(i)];
        disp( ['clust: ' num2str(i)]);
        scatter(data(index,2),data(index,1),'.', colors(mod(i,7)+1));
%         axis([ 0 max(data(:,2)) 100 900]);
%         set(gca,'Box','on');
    end
    legend(labels{:});
    disp('done');
end
index = clusterIndices==0;
scatter(data(index,2),data(index,1),8,[0.8 0.8 0.8],'filled'); 
% set(gca,'FontSize',14)