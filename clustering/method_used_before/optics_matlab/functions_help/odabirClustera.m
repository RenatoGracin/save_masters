clear all

load('UAE_data_exp_07_2018_07_16_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');  
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{1,1} = data_all;
clear data_all;

load('UAE_data_exp_08_2018_07_19.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{2,1} = data_all;
clear data_all;

load('UAE_data_exp_09_2018_07_23.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{3,1} = data_all;
clear data_all;

load('UAE_data_exp_10_25_07_2018_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{4,1} = data_all;
clear data_all;

load('UAE_data_exp_10_25_07_2018_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{5,1} = data_all;
clear data_all;

load('UAE_data_exp_13_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{6,1} = data_all;
clear data_all;

load('UAE_data_exp14_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{7,1} = data_all;
clear data_all;

load('UAE_data_exp14_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{8,1} = data_all;
clear data_all;

load('UAE_data_exp14_part_03.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat');
data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];  
data_all = sortrows(data_all',2);
DATA{9,1} = data_all;
clear data_all;

%%

%for i=1:8
    i=8;
    figure
    scatter(DATA{i,1}(:,2), DATA{i,1}(:,1),'.');
    ylim([ 25 350]); 
    %axis equal;
    indices=zeros(size(DATA{i,1},1),1);
    
    for j=1:2
    [pointslist,~,~] = selectdata();
    indices(pointslist)=j;
    end
    HAND_Indices{i,1}=indices;
%end


    figure
    indices = HAND_Indices{i,1};
    
    colors = ['b','r','g','y','c','m','k'];
    for x=1:max(indices)
        scatter(DATA{i,1}(indices==x,2), DATA{i,1}(indices==x,1),'.',colors(mod(x-1,7)+1));
        hold on
    end
    clear indices;
    ylim([ 25 350]); 

%%

for i=1:9
    figure
    indices = HAND_Indices{i,1};
    
    colors = ['b','r','g','y','c','m','k'];
    for x=1:max(indices)
        scatter(DATA{i,1}(indices==x,2), DATA{i,1}(indices==x,1),'.',colors(mod(x-1,7)+1));
        hold on
    end
    clear indices;
    ylim([ 25 350]); 
end