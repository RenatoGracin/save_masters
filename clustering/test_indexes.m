clear all
close all
% load(['../feature_selection/input_matrices/small_dataset_UAE_equ_features.mat']);
% data = feature_matrix(:,[1,2,18]);

%% Calculate if index has good evaulation of clustering quality
% load iris_dataset.mat
load 'input_matrices/classified_data.mat'
dataset_num = length(datasets);

epsilons_array = [0:0.01:1];
min_points_array = [5:20];

all_tests_num = length(epsilons_array)*length(min_points_array);
disp(['Num od combinations: ' num2str(all_tests_num)])
test_num=0;
for dataset_ind = 1: dataset_num
    data = datasets{dataset_ind};
    labels_goal = labels{dataset_ind};
    
    for min_points_ind = 1:length(min_points_array)
        for epsilons_ind = 1:length(epsilons_array)
            test_num = test_num+1;
            epsilon = epsilons_array(epsilons_ind);
            min_points = min_points_array(min_points_ind);
    
            idx = optics_with_clustering(data,min_points,epsilon);
            idx(idx==0) = -1;

            ARI{dataset_ind}(min_points_ind,epsilons_ind) = rand_index(labels_goal,idx,'adjusted');

            valid_indices = find(idx>0);
            data_without_outliers = data(valid_indices,:);
            idx_without_outliers = idx(valid_indices);
            DCVB_index{dataset_ind}(min_points_ind,epsilons_ind) = Calculate_DBCV_index(data_without_outliers,idx_without_outliers,length(find(idx<1)));
            disp(['Dataset' num2str(dataset_ind) ' finished test : ' num2str(test_num) '/' num2str(all_tests_num)]);
        end
    end
end

for ind = 1:length(epsilon_comb)
    min_points = 10;
    epsilon = epsilon_comb(ind);
    % epsilon = clusterDBSCAN.estimateEpsilon(data,min_points,min_points*3);
    % [order,reach_dist] = clusterDBSCAN.discoverClusters(data,epsilon,min_points);
    % 
    % plot(reach_dist(order),'LineWidth',2);
    
    % clusterer = clusterDBSCAN('Epsilon',epsilon,'MinNumPoints',min_points);
    % [idx,~] = clusterer(data);

%     epsilon = clusterDBSCAN.estimateEpsilon(data,min_points,min_points*3);
    idx = optics_with_clustering(data,min_points,epsilon);
    idx(idx==0) = -1;
    
    show_3D_clustering(data,idx);
    circle(0,0,0.7);
    title(['Epsilon was: ' num2str(epsilon)])
    
    %% Undefined should always be first cluser so the color stays the same
    label = idx;
    dataset = data;
    outliers_ind = find(label<1);
    outliers_len = length(outliers_ind);
    dataset(outliers_ind,:) = [];
    label(outliers_ind) = [];
    
    %% Evaluate clusters of feature subset
    
    %% Density based index
    
    DBCV_index = Calculate_DBCV_index(dataset,label,outliers_len);
    disp(['Epsilon = ' num2str(epsilon) ', DBCV_index = ' num2str(DBCV_index)]);
end

%  save(['../clustering/DBCV_index/DBCV/DBCV/DBCV_input.mat'],'MST', 'labels','epsilon_comb');

% DBCV_index = calc_DBCV_index(data, idx);

%% Intra-set distance

[intra_index, clust_num] = calc_intra_clust_dist(data,idx);

for id = 1:clust_num
    disp(['intra-clust' num2str(id) ': ' num2str(intra_index(id)) ' , should be min']);
end

%% Rousseeuws silhouette value
% eva_silhouette = evalclusters(data,idx,'silhouette');
% silhouette_indices = eva_silhouette.CriterionValues;
% disp(['silhouette_indices: ' num2str(silhouette_indices) ' , should be max']);


%% The Davies–Bouldin index.
% eva_davies_bouldin = evalclusters(data,idx,'DaviesBouldin');
% db_indices = eva_davies_bouldin.CriterionValues;
% disp(['db_indices: ' num2str(db_indices) ' , should be min']);


%% The Calinski-Harabasz index
% eva_calinski = evalclusters(data,idx,'CalinskiHarabasz');
% calinski_indices = eva_calinski.CriterionValues;
% disp(['calinski_indices: ' num2str(calinski_indices) ' , should be max']);


function [intra_index, clust_num] = calc_intra_clust_dist(data,idx)
    u_clust = unique(idx);
    clust_num = length(u_clust);
    intra_index = zeros(1,clust_num);
    for id_ind = 1:clust_num
        data_clust = data(u_clust(id_ind)==idx,:);
        mean_clust = mean(data_clust,1);
        intra_index(id_ind) = mean(pdist2(data_clust, mean_clust));
    end
end

function [inter_index, clust_num] = calc_inter_clust_dist(data,idx)
    u_clust = unique(idx);
    clust_num = length(u_clust);
    inter_index = zeros(1,clust_num);
    for id_ind = 1:clust_num
        data_clust = data(u_clust(id_ind)==idx,:);
        mean_clust = mean(data_clust,1);
    end

    inter_index(id_ind) = mean(pdist2(data_clust, mean_clust));
end
