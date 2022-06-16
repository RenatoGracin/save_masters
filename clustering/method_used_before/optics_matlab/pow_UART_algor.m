% mjerenje potrošnje, UART i algoritam

clear all
instrreset

addpath('C:\Users\Darjan\Desktop\moj_optics\data');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions_help');

s = serial('COM5','BaudRate',115200,'Timeout',500);
s.InputBufferSize = 50000;
fopen(s);

%%
clear data_all

%load('UAE_data_exp_13_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_09_2018_07_23.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
load('UAE_data_exp_07_2018_07_16_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');   %dosta sumovit
%load('UAE_data_exp_08_2018_07_19.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_10_25_07_2018_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_12_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');     
%load('UAE_data_exp14_part_03.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_06_2018_06_05_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
%load('UAE_data_exp_12_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');     


data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1);UAE_multi_f_mat(:,2);UAE_multi_f_mat(:,3)]/1e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr; UAE_multi_t_mat_hr; UAE_multi_t_mat_hr];  


% data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1); UAE_single_f_mat; UAE_multi_f_mat(:,1); UAE_single_f_mat; UAE_multi_f_mat(:,1) ]/2e3;
% data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr; UAE_single_t_mat_hr.*-1+2*max(UAE_single_t_mat_hr); UAE_multi_t_mat_hr.*-1+2*max(UAE_multi_t_mat_hr); UAE_single_t_mat_hr+2*max(UAE_multi_t_mat_hr); UAE_multi_t_mat_hr+2*max(UAE_multi_t_mat_hr)];

data_all = sortrows(data_all',2);


%%


    
    Nmin=30;
    eps=10;
    boxSize=1000;
    crosPointNum=200;

    firstStage = 0;
    iter=0;
    compareVect=zeros(size(data_all,1),1);
    vrijemeUkupno=0;
    vrijemeMin=0;
    vrijemeMax=0;

    reset=1;

    totalStages = floor((size(data_all,1)-crosPointNum)/(boxSize-crosPointNum));
    clustMat=zeros(20,100);

    pauseTime=0.005;

    for step = firstStage:3

    fprintf(s,'%d\n',reset);
    pause(pauseTime);
    fprintf(s,'%d\n',eps);
    pause(pauseTime);
    fprintf(s,'%d\n',Nmin);

    reset=0;

    flushinput(s);    
    data = data_all(step*(boxSize-crosPointNum)+1:(step+1)*(boxSize)-step*crosPointNum,:);    

    pauseTime = 0.005;
    for i=1:size(data,1)

        fprintf(s,'%f\n',data(i,1));
        pause(pauseTime);
    end

    for i=1:size(data,1)

        fprintf(s,'%f\n',data(i,2));
        pause(pauseTime);
    end

    tic
    % optics u matlabu

    clustNum = str2double(fgetl(s)); %
    toc
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

    for i=1:size(data,1)  
        stmclusterIndices(i)=str2double(fgetl(s));%
    end

    for i=1:clustNum
        clustMat(i,step+1)=str2double(fgetl(s));%
    end

    for i=1:clustNum
       timeMin(i)=str2double(fgetl(s)); 
       timeMax(i)=str2double(fgetl(s)); 
       yMinStart(i)=str2double(fgetl(s));
       yMaxStart(i)=str2double(fgetl(s)); 
       yMinEnd(i)=str2double(fgetl(s)); 
       yMaxEnd(i)=str2double(fgetl(s));   
    end

    if step==0
        for x = 1:boxSize
               if stmclusterIndices(x)~=0
                   totalClusterInd(step*(boxSize-crosPointNum)+x) = clustMat(stmclusterIndices(x), step+1);
               else
                   totalClusterInd(step*(boxSize-crosPointNum)+x) = 0;
               end
        end
    else
        for x = crosPointNum:boxSize
               if stmclusterIndices(x)~=0
                   totalClusterInd(step*(boxSize-crosPointNum)+x) = clustMat(stmclusterIndices(x), step+1);
               else
                   totalClusterInd(step*(boxSize-crosPointNum)+x) = 0;
               end
        end    
    end



    % for i=1:clustNum 
    %     fill([timeMin(i) timeMax(i) timeMax(i) timeMin(i) ],[yMinStart(i) yMinEnd(i) yMaxEnd(i) yMaxStart(i) ], colors(mod(clustMat(i,step+1)-1,7)+1));
    %     ylim([ 100 850]);  
    % end
   
    end
%%    
vrijemeAvg = vrijemeUkupno/totalStages;
colors = ['b','r','g','y','c','m','k'];

figure
for i=1:max(totalClusterInd)
    index = totalClusterInd(:)==i;
    ylim([ 100 900]);   
    xlim([ 0 max(data_all(:,2))]);
    scatter(data_all(index,2),data_all(index,1),'.',colors(mod(clustMat(i,step+1)-1,7)+1));

    hold on
    grid on 
    set(gca,'box','on');
    ylabel('frekvencija [kHz]');
    xlabel('vrijeme [h]');
    
    title('Set podataka 7');
    
end

 index = totalClusterInd(:)==0;
 scatter(data_all(index,2),data_all(index,1),8,[0.8 0.8 0.8],'filled'); 