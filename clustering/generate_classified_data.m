clear all
close all

%% Basic shape datasets
load 'input_matrices/optics_artficial_data.mat'
datasets = artificial_dataset(:,1)';
dataset_num = length(datasets);

%% Dataset 1
dataset_ind = 1;
data = datasets{dataset_ind};

x0 = 0; y0 = 0; r = 0.7;
idx = elipse_check_inside(data,x0,y0,r,1,1) +1;

% epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
% clusterer = clusterDBSCAN("Epsilon",0.15,'MinNumPoints',10);
% [idx,~] = clusterer(data);
% 
% show_3D_clustering(data,idx)
labels{dataset_ind} = idx';
epsilon_range{dataset_ind} = [0.03:0.01:0.2];

%% Dataset 2
dataset_ind = dataset_ind + 1;
data = datasets{dataset_ind};
% show_3D_clustering(data,ones(length(data(:,1)),1))

x0 = 1; y0 = 0.55; r = 0.81; a = 1.5; b = 1.6;
x1 = 1; y1 = 0.55; r1 = 0.5; a1 = 1.5; b1 = 1.6;

idx = (elipse_check_inside(data,x0,y0,r,a,b) & elipse_check_outside(data,x1,y1,r1,a1,b1) & (data(:,2)' < 0.7) )+1;

% show_3D_clustering(data,idx)
% elipse(x0,y0,r,a,b);
% elipse(x1,y1,r1,a1,b1);
% yline(0.7);

% epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
% clusterer = clusterDBSCAN("Epsilon",0.1,'MinNumPoints',10);
% [idx,~] = clusterer(data);
% 
% show_3D_clustering(data,idx);
labels{dataset_ind} = idx';
epsilon_range{dataset_ind} = [0.03:0.01:0.25];

%% Dataset 3
dataset_ind = dataset_ind + 1;
data = datasets{dataset_ind};
% ind_id = [1:length(data(:,1))];
% show_3D_clustering([data,ind_id'],ones(length(data(:,1)),1))

min_points = 15;
idx = optics_with_clustering(data,min_points,0.8);
idx(idx==0) = -1;
idx(7) = 2;
% show_3D_clustering(data,idx);

% epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
% clusterer = clusterDBSCAN("Epsilon",epsilon,'MinNumPoints',10);
% [idx,~] = clusterer(data);
% 
% show_3D_clustering(data,idx);
labels{dataset_ind} = idx; 
epsilon_range{dataset_ind} = [0.1:0.02:1];

%% Dataset 4
dataset_ind = dataset_ind + 1;
data = datasets{dataset_ind};
% show_3D_clustering(data,ones(length(data(:,1)),1))

min_points = 15;
epsilon = clusterDBSCAN.estimateEpsilon(data,min_points,min_points*3);
idx = optics_with_clustering(data,min_points,0.422);
idx(idx==0) = -1;
idx(3) = 1;
% show_3D_clustering(data,idx);

% epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
% clusterer = clusterDBSCAN("Epsilon",0.45,'MinNumPoints',10);
% [idx,~] = clusterer(data);

% show_3D_clustering(data,idx);
labels{dataset_ind} = idx; 
epsilon_range{dataset_ind} = [0.1:0.01:0.45];

%% Dataset 5
dataset_ind = dataset_ind + 1;
data = datasets{dataset_ind};
% show_3D_clustering(data,ones(length(data(:,1)),1))

min_points = 15;
epsilon = clusterDBSCAN.estimateEpsilon(data,min_points,min_points*3);
idx = optics_with_clustering(data,min_points,2.5);
idx(idx==0) = -1;
idx([1,1393]) = 1;
idx([4,1390]) = 2;
idx([9,1413]) = 3;

% show_3D_clustering(data,idx);

% epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
% clusterer = clusterDBSCAN("Epsilon",3,'MinNumPoints',10);
% [idx,~] = clusterer(data);

% show_3D_clustering(data,idx);
labels{dataset_ind} = idx; 
epsilon_range{dataset_ind} = [0.15:0.07:3];

%% Dataset 6
%% Remove uniform data as valid dataset
datasets{dataset_ind+1} = [];
% dataset_ind = dataset_ind + 1;
% data = datasets{dataset_ind};
% show_3D_clustering(data,ones(length(data(:,1)),1))


% idx = ones(length(data(:,1)),1);

% show_3D_clustering(data,idx);

% epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
% clusterer = clusterDBSCAN("Epsilon",0.02,'MinNumPoints',10);
% [idx,~] = clusterer(data);

% show_3D_clustering(data,idx);
% labels{dataset_ind} = idx;
% epsilons{dataset_ind} = [0.01:0.01:0.1];

%% Dataset 7
%% GMM dataset - remove as valid dataset beacuse it has only 1 cluster
mu1 = [1 2];          % Mean of the 1st component
sigma1 = [70 0; 0 70]; % Covariance of the 1st component
mu2 = [1 2];        % Mean of the 2nd component
sigma2 = [1 0; 0 1];  % Covariance of the 2nd component

r1_data_len = 200;
r2_data_len = 1000;
r1 = mvnrnd(mu1,sigma1,r1_data_len);
r2 = mvnrnd(mu2,sigma2,r2_data_len);

data = [r1; r2];

% idx = zeros(r1_data_len+r2_data_len,1);
% idx(1:r1_data_len) = 1; 
% idx(r1_data_len+1:r1_data_len+r2_data_len) = 2;

idx = elipse_check_inside(data,1,2,3.37,1,1);

% show_3D_clustering([data,[1:length(data(:,1))]'],idx);
% show_3D_clustering(data,idx);

% dataset_ind = dataset_ind + 1;

% datasets{dataset_ind} = data;
% labels{dataset_ind} = idx';
% epsilons{dataset_ind} = [0.01:0.01:0.1];

%% Dataset 8
%% 3 Circles with noise dataset
% link: https://www.analyticsvidhya.com/blog/2020/09/how-dbscan-clustering-works/

circle_dataset = [create_circle_data(500,1000); create_circle_data(300,700); create_circle_data(100,300)];

range = [floor(min(circle_dataset(:,1))),ceil(max(circle_dataset(:,1)))];
noise_dataset =  create_noise_data(300,range);
data = [ circle_dataset; noise_dataset];
% data = circle_dataset;

% scatter(circle_dataset(:,1),circle_dataset(:,2),10,'blue','filled','o')
% hold on
% scatter(noise_dataset(:,1),noise_dataset(:,2),10,'red','filled','o')
data_len = length(data(:,1));

x = -25; y = -25;

idx1 =  elipse_check_inside(data,x,y,185,1,1);

idx2 =  (elipse_check_inside(data,x,y,385,1,1) &  elipse_check_outside(data,x,y,240,1,1))*2;

idx3 =  (elipse_check_inside(data,x,y,585,1,1) &  elipse_check_outside(data,x,y,440,1,1))*3;

idx=idx1+idx2+idx3;
idx(idx==0) = -1;

% show_3D_clustering(data,idx);
% circle(x,y,185);
% circle(x,y,240);
% circle(x,y,385);
% circle(x,y,440);
% circle(x,y,585);

% epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
% clusterer = clusterDBSCAN("Epsilon",55,'MinNumPoints',10);
% [idx,~] = clusterer(data);
% 
% show_3D_clustering(data,idx);
dataset_ind = dataset_ind + 1;

datasets{dataset_ind} = data;
labels{dataset_ind} = idx'; 
epsilon_range{dataset_ind} = [20:1:55];


%% Dataset 9
%% Complicated dataset

data_all=importdata('dataclust.txt');

data = sortrows(data_all(2:end,:),2);

% figure
% scatter( data_all(:,2), data_all(:,1), 'b','.');
% title('Ulazni podaci za grupiranje');
% ylabel('frequency, kHz');
addpath(['CVDD_index']);
min_points = 15;
% epsilon = clusterDBSCAN.estimateEpsilon(data,min_points,min_points*3);
% idx = optics_with_clustering(data,min_points,9);
% idx(idx==0) = -1;
% show_3D_clustering(data,idx);

i=0;
epsilons_val = [4:0.5:12];
for eps = epsilons_val
    i = i+1;

    idx = optics_with_clustering(data,min_points,eps);
    
    if length(unique(idx(idx>0))) < 2 %|| length(unique(idx(idx>0))) > 10
        continue;
    end

    idx(idx<1) = -1;
%     show_3D_clustering(data,idx);

    valid_indices = find(idx>0);
    valid_data = data(valid_indices,:);
    valid_idx = idx(valid_indices);
    
%     dunn_index = Calc_Dunn_Index(valid_data,valid_idx);
    DBCV_index(i) = Calculate_DBCV_index(valid_data,valid_idx,length(find(idx<1)));
    CVDD_index(i) = CVDDIndex(valid_data,valid_idx);
    disp(["DBCV_index = " num2str(DBCV_index(i))])
end

[dbcv_sorted,dbcv_sort_ind] = max(DBCV_index,[],"all");
[cvdd_sorted,cvdd_sort_ind] = max(CVDD_index,[],"all");
disp(["Best epsilon = " epsilons_val(dbcv_sort_ind) ]);
disp(["Best epsilon = " epsilons_val(cvdd_sort_ind) ]);

idx = optics_with_clustering(data,min_points,epsilons_val(dbcv_sort_ind));
show_3D_clustering(data,idx);
title('DBCV')

idx = optics_with_clustering(data,min_points,epsilons_val(cvdd_sort_ind));
show_3D_clustering(data,idx);
title('CVDD')



dataset_ind = dataset_ind + 1;


datasets{dataset_ind} = data;
labels{dataset_ind} = idx;
epsilon_range{dataset_ind} = [4:0.5:12];

%% Save every dataset and it's labels
save('input_matrices/classified_data.mat','datasets','labels','epsilon_range')
disp('Successfully generated classified data.')

function [xunit,yunit] = circle(x,y,r)
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) + x;
    yunit = r * sin(th) + y;
    hold on
    plot(xunit,yunit)
    hold off
end

function [xunit,yunit] = elipse(x,y,r,a,b)
    th = 0:pi/50:2*pi;
    xunit = r * cos(th) * a + x;
    yunit = r * sin(th) * b + y;
    hold on
    plot(xunit,yunit)
    hold off
end

function idx = elipse_check_inside(data,x,y,r,a,b)
    for data_ind = 1:length(data(:,1))
        if (data(data_ind,1)-x)^2/(a^2) + (data(data_ind,2)-y)^2/(b^2) < r^2
            idx(data_ind) = 1;
        else
            idx(data_ind) = 0;
        end
    end
end

function idx = elipse_check_outside(data,x,y,r,a,b)
    for data_ind = 1:length(data(:,1))
        if (data(data_ind,1)-x)^2/(a^2) + (data(data_ind,2)-y)^2/(b^2) > r^2
            idx(data_ind) = 1;
        else
            idx(data_ind) = 0;
        end
    end
end

function circle_dataset = create_circle_data(radius,N)
    circle_dataset = zeros(N,2);
    for data_ind = 1:N
        circle_dataset(data_ind,:) = [cos(2*pi/N*data_ind)*radius+normrnd(-30,30),sin(2*pi/N*data_ind)*radius+normrnd(-30,30)];
    end
end

function noise_dataset = create_noise_data(N,range)
    noise_dataset = zeros(N,2);
    for data_ind = 1:N
        noise_dataset(data_ind,:) = randi(range,2,1);
    end
end