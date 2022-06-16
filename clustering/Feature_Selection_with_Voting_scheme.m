%% Feature selection with voting scheme, using OPTICS
clc
% close all
clear all

% dataset_name = 'small_dataset';
% dataset_name = 'big_dataset';
dataset_name = 'exp_14_part_3';
addpath("method_used_before\optics_matlab\functions\")

 %% Open new word document to save feature distribution results
addpath('..\clustering\Word_support\')

%% Create folder for dataset figures if it doesn't exist
dataset_fig_folder = ['../figures/feature_selection/' dataset_name '/'];
if ~exist(dataset_fig_folder, 'dir')
   mkdir(dataset_fig_folder)
end

%% Create folder for dataset documentation if it doesn't exist
dataset_doc_folder=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\documentation\feature_selection\' dataset_name ];
if ~exist(dataset_doc_folder, 'dir')
   mkdir(dataset_doc_folder)
end

dataset_mat_folder = ['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\feature_selection\feature_calc_matrices\' dataset_name '\'];
% load(['../feature_selection/input_matrices/' dataset_name '_UAE_equ_features.mat']);
load([dataset_mat_folder dataset_name '_UAE_equ_features.mat']);


% find index when mixed data begins
equ_emiss_max_t_hr = (equ_emiss_max_t) ./ 3600;

feature_matrix = equ_feature_matrix;

%% 0) Standardize feature matrix 
% mentioned here: https://medium.com/analytics-vidhya/principal-component-analysis-pca-8a0fcba2e30c

% Remove rows that have element with inf value
err_rows = [];

for feat_ind = 1:length(feature_matrix(1,:))
    x = feature_matrix(:,feat_ind);
    err_ele_ind = find(isinf(x) | isnan(x))';
    if ismember(err_ele_ind,err_rows) == 0
        err_rows = [err_rows,err_ele_ind];
    end
end

%% Find specific emissions based on feature values
feature_matrix(err_rows,:) = [];
equ_feature_matrix(err_rows,:) = [];
equ_emiss_max_t_hr(err_rows) = [];
equ_emiss_max_t(err_rows) = [];

feat_names_new = {'rise time','counts to','counts from','duration',...
        'peak amplitude','average frequency','rms','asl','reverbation frequency',...
        'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',...
        'pp3','pp4','centroid frequency','peak frequency','amp of peak frequency','num of freq peaks','weighted peak frequency',...
        'total counts','fall time'};
% 
% figure;
% heatmap(vbls2,vbls2,corr(feature_matrix),'XLabel','Features','YLabel','Features');
% colormap turbo

% Standardization
for feat_ind = 1:length(feature_matrix(1,:))
    % Standardization with z-score using formula x_norm = (x-mean(x))/std(x);
    % link: https://www.indeed.com/career-advice/career-development/how-to-calculate-z-score
    x = feature_matrix(:,feat_ind);
%     feature_matrix(:,feat_ind) = (x-mean(x))/std(x);
    feature_matrix(:,feat_ind) = (x-min(x))/(max(x)-min(x));
end

dataset = feature_matrix;

save(['../clustering/input_matrices/' dataset_name '_stand_feature_matrix.mat'], 'dataset');

feat_names_underscore = {'rise_time','counts_to','counts_from','duration',...
        'peak_amplitude','average_frequency','rms','asl','reverbation_frequency',...
        'initial_frequency', 'signal_strength', 'absolute_energy', 'pp1','pp2',...
        'pp3','pp4','centroid_frequency','peak_frequency','amp_of_peak_frequency','num_of_freq peaks','weighted_peak_frequency',...
        'total_counts','fall_time'};

%% Laplacian score feature selection
% [idx, score] = fsulaplacian(feature_matrix);
% 
% figure;
% grid on
% scatter(1:20,score(idx),'black','filled')
% xlab = vbls2(idx);
% xticks([1:20]);
% xticklabels(xlab);
% ylabel('Laplace score');
% title('Feature selection based on Laplace score');

disp('Started feature selection...')

%% Choose 7 frequency features
%% They used WPF, PF, FC, PP1, PP2, PP3, PP4
choose_features = [1,3,5,11,13:19,22,23];

%% Iterate for all feature subsets of 4 to 7 features -> sum(7 povrh X), za X=4,5,6,7 -> 64 combinations
subsets = Get_Distinct_Subsets(choose_features,3,3);

subsets = Remove_Subsets_Without_Feature(subsets,18);

correlated_feature_pairs = [5,7,11,12];
subsets = Remove_Math_Correlated_Subsets(subsets,correlated_feature_pairs);
subsets = Remove_Math_Correlated_Subsets(subsets,[18,21]);
number_of_subsets = length(subsets);

disp(['Number of subsets: ' num2str(number_of_subsets)])

Nmins = [10];

number_of_combs = length(Nmins);
disp(['Number of Nmin combination per subset: ' num2str(number_of_combs)])

skipped_comb = 0;
data_len = length(feature_matrix(:,1));
for subset_ind = 1:number_of_subsets
    
    %% Choose feature subset
    features = subsets{subset_ind};
    feature_subset = feature_matrix(:,features);
    comb_ind = 0;
    tic
    for Nmins_ind = 1:length(Nmins)
        Nmin = Nmins(Nmins_ind);

        epsilon_knee =  Estimate_Epsilon(feature_subset,Nmin);
        epsilon_low_limit = max([0,epsilon_knee-2*0.01]);
        epsilon_high_limit = epsilon_knee+1*0.01;
        epsilons = [epsilon_high_limit:-0.0025:epsilon_low_limit];
        calc_sum = 0;
        for eps_ind = 1:length(epsilons)
            comb_ind = comb_ind +1;
            epsilon = epsilons(eps_ind);
            tic
            idx= optics_with_clustering(feature_subset,Nmin,epsilon);
            toc
            idx(idx<1) = -1;
            all_labels_dbcv{subset_ind,comb_ind} = idx;

            saved_epsilon(subset_ind,comb_ind) = epsilon;
            saved_Nmin(subset_ind,comb_ind) = Nmin;
     
            if 10 < length(unique(idx(idx~=-1))) || isempty(find(idx>0))% || length(idx(idx~=-1))/data_len < 0.5
%                  disp(['Skipped local comb: ' num2str(comb_ind) '/' num2str(number_of_combs) ' for subset ' num2str(subset_ind) '/' num2str(number_of_subsets)])
%                 skipped_comb = skipped_comb + 1;
                dbcv_indices(subset_ind,comb_ind) = -1;
%                 silh_indices(subset_ind,comb_ind) = -1;
                continue;
            else
                valid_indices = find(idx>0);
                data_without_outliers = feature_subset(valid_indices,:);
                idx_without_outliers = idx(valid_indices);

                if 2 > length(unique(idx(idx~=-1)))
                    single_cluster(subset_ind,comb_ind) = 1;
                end
                calc_sum = calc_sum+1;
                dbcv_indices(subset_ind,comb_ind) = Calculate_DBCV_index(data_without_outliers, idx_without_outliers,length(find(idx<1)));
                
                if calc_sum >= 2
                    break;
                end
%                 show_3D_clustering(feature_subset,idx);
%                 xlabel(strrep(feat_names_underscore{features(1)},'_',' '))
%                 ylabel(strrep(feat_names_underscore{features(2)},'_',' '))
%                 zlabel(strrep(feat_names_underscore{features(3)},'_',' '))
%             
%                 title({['Figure: ' num2str(eps_ind)],['Epsilon is: ' num2str(epsilon) ' , MinNumPoints is: ' num2str(Nmin) ', Index value: ' num2str(dbcv_indices(subset_ind,comb_ind))]})
                if comb_ind > 1
                    if dbcv_indices(subset_ind,comb_ind) > 0.8 && (dbcv_indices(subset_ind,comb_ind) > dbcv_indices(subset_ind,comb_ind-1))
                        break;
                    end
                end
            end
        end
        disp(['Done with local comb: ' num2str(Nmins_ind) '/' num2str(length(Nmins)) ' for subset ' num2str(subset_ind) '/' num2str(number_of_subsets)])
    end
    disp(['Done with subset: ' num2str(subset_ind) '/' num2str(number_of_subsets)])
    toc
end
disp(['Skipped feature subsets: ' num2str(skipped_comb) '/' num2str(number_of_subsets)])
disp(['Finished feature selection!'])
clear guid
[~,guid] = fileparts(tempname);

save([ dataset_name 'better_feature_selection_with_DBCV_id_' guid],'all_labels_dbcv','dbcv_indices',"dataset_name",'saved_Nmin','saved_epsilon','feat_names_underscore','equ_feature_matrix','equ_emiss_max_t_hr','subsets','feature_matrix','single_cluster','guid');

%% Show best feature subsets calculated and save data
% show_subset_ranks(dataset,dataset_name,feat_names,Nmins,epsilons,scoring_limit,subsets,validity_indices,index_name,index_min)
show_subset_ranks_2_0(feature_matrix,dataset_name,feat_names_underscore,saved_Nmin,saved_epsilon,10,subsets,dbcv_indices,'DBCV',-1,equ_emiss_max_t_hr,equ_feature_matrix,guid);
[maxes_val,maxes_ind] = max(dbcv_indices,[],2);
[sort_val,best_subset_ind] = sort(maxes_val,'descend');
for i=1:10
    all_best_labels{i} = all_labels_dbcv{best_subset_ind(1),maxes_ind(best_subset_ind(i))};
end
clust_intersection_perc = Intersect_All_Labels(all_best_labels);
single_dbcv = dbcv_indices;
single_dbcv(single_cluster==0) = -1;
show_subset_ranks_2_0(feature_matrix,dataset_name,feat_names_underscore,saved_Nmin,saved_epsilon,10,subsets,single_dbcv,'DBCV_single_clust',-1,equ_emiss_max_t_hr,equ_feature_matrix,guid);

return;

for i=1:length(feat_names_new) 
    feat_names_new{i} = [' ' feat_names_new{i} ' ']; 
end

%% Calculate best feature set for all indices based on voting scheme
% [tou_sorted,tou_sort_ind] = sort(tou_indices,2,'descend');
% Set feature subsets that were not calculated as least important
silh_indices(silh_indices==0) = Inf;
[db_sorted,db_sort_ind] = sort(silh_indices(),2,'ascend');
% [ch_sorted,ch_sort_ind] = sort(calinski_indices,2,'descend');
[silh_sorted,silh_sort_ind] = sort(silhouette_indices,2,'descend');
[dbcv_sorted,dbcv_sort_ind] = sort(dunn_indices,2,'descend');

voting_scheme = zeros(1,length(subsets));
voting_limit = 25;
for index_ele = sort(1:voting_limit,2,'descend')
%     voting_scheme(tou_sort_ind(index_ele)) = voting_scheme(tou_sort_ind(index_ele)) + index_ele;
%     voting_scheme(db_sort_ind(index_ele)) = voting_scheme(db_sort_ind(index_ele)) + index_ele;
%     voting_scheme(ch_sort_ind(index_ele)) = voting_scheme(ch_sort_ind(index_ele)) + index_ele;
%     voting_scheme(silh_sort_ind(index_ele)) = voting_scheme(silh_sort_ind(index_ele)) + index_ele;
    voting_scheme(dbcv_sort_ind(index_ele)) = voting_scheme(dbcv_sort_ind(index_ele)) + index_ele;
end
[sorted_vote, sort_subset_ind] = sort(voting_scheme,2,'descend');
disp(['Voting scheme 1st result are features: ' feat_names_new{subsets{sort_subset_ind(1)}}])
disp(['Voting scheme 2nd result are features: ' feat_names_new{subsets{sort_subset_ind(2)}}])
disp(['Voting scheme 3rd result are features: ' feat_names_new{subsets{sort_subset_ind(3)}}])
disp(['Voting scheme 4th result are features: ' feat_names_new{subsets{sort_subset_ind(4)}}])


%% Calculate best feature set for each index
% % Tou index results
% [~,tou_ind] = max(tou_indices); 
% disp(['Tou result are features: ' vbls2{subsets{tou_ind}}])
% tou_subset = feature_matrix(:,subsets{tou_ind});
% calculate_clusters(tou_subset,1,{vbls2{subsets{tou_ind}}});
% 
% % Silhouette index results
% [~,silh_ind] = max(silhouette_indices); 
% disp(['Silhouette result are features: ' vbls2{subsets{silh_ind}}])
% silh_subset = feature_matrix(:,subsets{silh_ind});
% calculate_clusters(silh_subset,1,{vbls2{subsets{silh_ind}}});
% 
% % Gamma index results
% % [~,gamma_ind] = max(gamma_indices); 
% % disp(['Gamma result are features: ' vbls2{subsets{gamma_ind}}])
% % gamma_subset = feature_matrix(:,subsets{gamma_ind});
% % calculate_clusters(gamma_subset,1,{vbls2{subsets{tou_ind}}});
% 
% % DB index results
% [~,db_ind] = min(db_indices); 
% disp(['DB result are features: ' vbls2{subsets{db_ind}}])
% db_subset = feature_matrix(:,subsets{db_ind});
% calculate_clusters(db_subset,1,{vbls2{subsets{db_ind}}});
% 
% % Calinski index results
% [~,cal_ind] = max(calinski_indices); 
% disp(['Calinski result are features: ' vbls2{subsets{cal_ind}}])
% cal_subset = feature_matrix(:,subsets{cal_ind});
% calculate_clusters(cal_subset,1,{vbls2{subsets{cal_ind}}});



X = [X(:,choose_features)];

[emiss_num,feat_num] = size(X);
min_points = feat_num*3;

% [m,n]=size(X);
% CD=zeros(1,m);
% k_dist=zeros(1,m);
% % Calculate optimal epsilon for set min num points
% for i=1:m	
%     D=sort(sqrt(sum((((ones(m,1)*X(i,:))-X).^2)')));
%     k_dist(i) = mean(D(1:k+1));
% end
% 
% scatter(1:length(k_dist),sort(k_dist),'blue','filled');

clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',0.2,'MaxNumPoints',min_points*2);

%% OPTICS?
% [order, reach_dist] = clusterer.discoverClusters(X,0.2,k);
% 
% for i = 1:size(X,1)
%     ordered_reach_list(i,1) = reach_dist(order(i));
% end
% 
% figure
% scatter(1:length(ordered_reach_list),ordered_reach_list,'blue','filled');
% grid on
% title('Rezultat OPTICS algoritma','fontSize' ,20);

%% DBSCAN?
[idx,clusterids] = clusterer(X);
plot(clusterer,X,idx);

idx(idx<0) = 69;

eva_calinski = evalclusters(X,idx,'CalinskiHarabasz');
eva_calinski.CriterionValues

% figure
% hold on
% scatter(time(idx==1),X(idx==1,18),'red','filled','SizeData',4);
% scatter(time(idx==2),X(idx==2,18),'blue','filled','SizeData',4);

%% Plot cluster by cluster
% %% Show difference of epsilon on reachability plot
% % (x-min(x))/(max(x)-min(x));
% % features(:,18) = (equ_feature_matrix(:,18))/1e6;
% test_features = [1,3,18; 16,18,23; 16,18,22; 11,18,19; 15,16,18; 2,16,18; 5,14,18; 16,17,18; 14,16,18; 15,18,23; 11,13,18; 5,16,18; 5,18,19; 11,18,22; 5,13,18; 18,19,22; 5,18,23; 5,18,22; 18,19,23; 13,18,19];
% test_features = [11,18,19; 5,18,19; 1,3,18; 5,15,18; 15,18,19; 11,15,18; 14,18,19; 3,18,23; 11,17,18; 5,14,18;];
% epsilon_outer= [0.018; 0.021; 0.041; 0.04; 0.039; 0.04; 0.04; 0.043; 0.033; 0.041; 0.043];
% % for features_ind = 1:length(test_features(:,1))
% % load('big_dataset_feature_selection_with_DBCV_id_tp2f8f588c_e987_4df4_bb05_12cddcee21d6.mat')
% subset_ind = 8;
% % for features_ind = [1:length(test_features(:,1))]
% for features_ind = []
%     features = test_features(features_ind,:);
%     features = [1,2,18];
%     % features = [1,18,19];
% %     features = subsets{subset_ind};
%     data = dataset(:,features);
%     
%     % load('C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\test_my_index.mat');
%     addpath('C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\HDBSCAN-master');
%     addpath('C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\HDBSCAN-master\source\');
%     % addpath('C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\HDBSCAN-master\source\functions\')
% 
%     Nmins = [10];
%     ranks = 1;
%     for i = 1:length(Nmins)
%         epsilon_knee = Estimate_Epsilon(data,Nmins(i));
%         epsilon_low_limit = max([0,epsilon_knee-3*0.01]);
%         epsilon_high_limit = epsilon_knee+3*0.01;
%         epsilons = [epsilon_high_limit:-0.0025:epsilon_low_limit];
% %         epsilons = saved_epsilon(subset_ind,:);
% 
% %         epsilons = epsilon_outer(features_ind);
%     
% %         for eps_ind = 1:length(epsilons)
%         for eps_ind = [1:20]
%             eps = epsilons(eps_ind);
%             labels = optics_with_clustering(data,Nmins(i),eps);
%     
%     %         clusterer.run_hdbscan( minpts,minclustsize,[],outlierThresh); 
%     %         clusterer.run_hdbscan( 5,10,[],1); 
%     %         labels = clusterer.labels;
%     
%             tic
% %             labels = all_labels_dbcv{eps_ind};
% %             all_labels{eps_ind} = labels;
%     
%             if length(unique(labels)) > 10 || length(unique(labels)) < 2
%                index(eps_ind) = -1;
%                continue;
%             end
%     
%             labels(labels<1) = -1;
%             show_3D_clustering(data,labels);
%             xlabel(strrep(feat_names_underscore{features(1)},'_',' '))
%             ylabel(strrep(feat_names_underscore{features(2)},'_',' '))
%             zlabel(strrep(feat_names_underscore{features(3)},'_',' '))
%         
%             valid_indices = find(labels>0);
%             data_without_outliers = data(valid_indices,:);
%             idx_without_outliers = labels(valid_indices);
%   
%             index(eps_ind) =  Calculate_DBCV_index(data_without_outliers, idx_without_outliers,length(find(labels<1)),0);
%             
%             title({['Figure: ' num2str(eps_ind)],['Epsilon is: ' num2str(eps) ' , MinNumPoints is: ' num2str(Nmins(i)) ', Index value: ' num2str(index(eps_ind))]})
%             toc
%         end
%     
% %         [~,best_order] = sort(index,'descend');
% %         disp(['3 best figures are: ' num2str(best_order(1:3))]);
%     end
% end
% 
% % save('C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\test_my_index_5_13_18.mat','all_labels','data')



%% Dataset = N*p matrix, N - number of data (observations), p - number of features
%% Cluster_ind = 1*N matric, cluster number for each observation 
%% link: https://sci-hub.se/https://doi.org/10.1007/BF00995502
%% index formula link: https://opus.bibliothek.uni-augsburg.de/opus4/frontdoor/deliver/index/docId/59471/file/%5bSause2010-1%5d-J.Nondest.Eval_preprint.pdf
function tou_index = Calc_Tou_Index(dataset, cluster_ind)
    cluster_ids = unique(cluster_ind);
    cluster_id_len = length(cluster_ids);

    %% 0) Seperate clusters into cluster_data
    %% 1) Compute the centroid for each of the initial clusters into cluster means
    %% 2) Compute the standard deviation vector for each of the initial clusters into cluster std
    %% and Compute means of std vectors for each cluster into cluster std mean 
    %% also Find the maximum component of each std 
    for id_ind = 1:cluster_id_len
        %% xk = vector of xij for certain cluster j
        cluster_data{id_ind} = dataset(cluster_ind==cluster_ids(id_ind),:);
        %% zj - mean value fot certain cluster j
        cluster_means{id_ind} = mean(cluster_data{id_ind},1);
        %% oij - std value fot certain cluster j for feature i
        cluster_stds{id_ind} = std(cluster_data{id_ind},1);
        %% oj_mean- mean value of oij for certain j
        cluster_std_mean{id_ind} = mean(cluster_stds{id_ind});
        %% oj_max- max value of oij for certain j
        cluster_std_max{id_ind} = max(cluster_stds{id_ind});
        %% 4) Compute the intraset distance for each cluster, and find the maximum of these distances.
        %% Dj - intraset distance for each cluster
        cluster_intraset_distances{id_ind} = sqrt(2*sum(cluster_stds{id_ind}.^2));
%         sum_intra=0;
%         for feat_ind = 1:length(cluster_data{id_ind}(1,:))
%             intra_try(id_ind,feat_ind) = sqrt(sum((cluster_data{id_ind}(:,feat_ind)-cluster_means{id_ind}(feat_ind)).^2)/length(cluster_data{id_ind}(:,1)));
%         end
%         intradist{id_ind} = sqrt(2*sum(intra_try(id_ind,:).^2));
    end

    %% max Dj - maximum distance of intraset distance for each cluster
    max_cluster_intraset_distances = max(cell2mat(cluster_intraset_distances));

    %% Plots single cluster centroid to check
%     figure
%     hold on
%     scatter(dataset(:,3),dataset(:,2),4,'blue','filled','diamond')
%     plot(cluster_means{2}(3),cluster_means{2}(2),'rx','LineWidth',4,'MarkerSize',10)
%     grid on 

    %% 3) Compute the interset distances between clusters, and find the minimum of these distances
    %% Dij - i and j are cluster indices
    cluster_distances = pdist(cell2mat(cluster_means'));
    % Locate which distance pair is it
%     Z = squareform(cluster_distances);
    %% Check cluster distances
%     dist_12 = sqrt(sum((cluster_means{1}-cluster_means{2}).^2));
%     if dist_12 == Z(1,2)
%         disp('Correct calculaton');
%     end
    %% min Dij
    cluster_min_dist = min(cluster_distances);

    %% 4) Establish a performance index lambda(Nc) for determining optimal clusters
    tou_index = cluster_min_dist/max_cluster_intraset_distances;
end

%% ofiicial link: https://sci-hub.se/10.1109/TPAMI.1979.4766909
%% matlab link: https://se.mathworks.com/help/stats/clustering.evaluation.daviesbouldinevaluation.html#bt09e17
function db_index = Calc_DB_Index(dataset, cluster_ind)
    cluster_ids = unique(cluster_ind);
    cluster_id_len = length(cluster_ids);

    %% 0) Seperate clusters into cluster_data
    for id_ind = 1:cluster_id_len
        cluster_data{id_ind} = dataset(cluster_ind==cluster_ids(id_ind),:);
        %% Following the formula in https://sci-hub.se/10.1109/TPAMI.1979.4766909
        %% q = 1, p = 2
        cluster_centroids{id_ind} = mean(cluster_data{id_ind});
        cluster_intradist{id_ind} = mean(pdist2(cluster_data{id_ind}, cluster_centroids{id_ind}));
        %% Following the formula with q = 2?
%         cluster_intradis2{id_ind} = std(cluster_data{id_ind},1);
    end

    %% Plots single cluster centroid to check
%     figure
%     hold on
%     scatter(dataset(:,3),dataset(:,2),4,'blue','filled','diamond')
%     plot(cluster_means{2}(3),cluster_means{2}(2),'rx','LineWidth',4,'MarkerSize',10)
%     grid on 

    %% 3) Compute the interset distances between clusters, and find the minimum of these distances
    %% Dij - i and j are cluster indices
    cluster_interdist = pdist(cell2mat(cluster_centroids'));
    % Locate which distance pair is it
    cluster_interdist = squareform(cluster_interdist);
    %% Check cluster distances
%     dist_12 = sqrt(sum((cluster_means{1}-cluster_means{2}).^2));
%     if dist_12 == Z(1,2)
%         disp('Correct calculaton');
%     end

    db_matrix = zeros(cluster_id_len,cluster_id_len);
    %% 4) Establish a performance index lambda(Nc) for determining optimal clusters
    for i = 1:cluster_id_len
        for j = 1:cluster_id_len
            if i==j
                continue;
            end
            db_matrix(i,j) = (cluster_intradist{i}+cluster_intradist{j})/cluster_interdist(i,j);
        end
    end

    db_index = mean(max(db_matrix));

end

%% official link: 
function gamma_index = Calc_Gamma_Index(dataset, cluster_ind)
    cluster_ids = unique(cluster_ind);
    cluster_id_len = length(cluster_ids);

    all_dist = pdist(dataset);
    all_dist_bin = pdist(cluster_ind);
    all_dist_bin(all_dist_bin~=0) = 1;

    dist_same_cluster = all_dist(find(all_dist_bin==0));
%   Remove distance between same points
    dist_same_cluster(dist_same_cluster==0) = [];

    dist_diff_cluster = all_dist(find(all_dist_bin==1));

% s+ represents the number of times a distance between two points
% which belong to the same cluster (that is to say a pair for which the value of
% vector B is 0) is strictly smaller than the distance between two points not
% belonging to the same cluster (that is to say a pair for which the value of vector
% B is 1).
% 
% s- represents the number of times the opposite situation
% occurs, that is to say that a distance between two points lying in the same
% cluster (value 0 in B) is strictly greater than a distance between two points not
% belonging to the same cluster (value 1 in B).
    s_plus = 0;
    s_minus = 0;

    for same_ind = 1:length(dist_same_cluster)
        s_plus = s_plus + sum(dist_diff_cluster>dist_same_cluster(same_ind));
        s_minus = s_minus + sum(dist_diff_cluster<dist_same_cluster(same_ind));
    end

%     for same_ind = 1:length(dist_same_cluster)
%         for diff_ind = 1:length(dist_diff_cluster)
%             if dist_same_cluster(same_ind) < dist_diff_cluster(diff_ind)
%                 s_plus = s_plus + 1;
%             elseif dist_same_cluster(same_ind) > dist_diff_cluster(diff_ind)
%                 s_minus = s_minus + 1;
%             end
%         end
%     end

    gamma_index = (s_plus-s_minus)/(s_plus+s_minus);
end

function ch_index = Calc_CH_Index(dataset, cluster_ind)
    cluster_ids = unique(cluster_ind);
    cluster_id_len = length(cluster_ids);

    %% 0) Seperate clusters into cluster_data
    for id_ind = 1:cluster_id_len
        cluster_data{id_ind} = dataset(cluster_ind==cluster_ids(id_ind),:);
        %% Following the formula in https://sci-hub.se/10.1109/TPAMI.1979.4766909
        %% q = 1, p = 2
        cluster_centroids{id_ind} = mean(cluster_data{id_ind});
        cluster_intradist{id_ind} = mean(pdist2(cluster_data{id_ind}, cluster_centroids{id_ind}));
        %% Following the formula with q = 2?
%         cluster_intradis2{id_ind} = std(cluster_data{id_ind},1);
    end

    %% Plots single cluster centroid to check
%     figure
%     hold on
%     scatter(dataset(:,3),dataset(:,2),4,'blue','filled','diamond')
%     plot(cluster_means{2}(3),cluster_means{2}(2),'rx','LineWidth',4,'MarkerSize',10)
%     grid on 

    %% 3) Compute the interset distances between clusters, and find the minimum of these distances
    %% Dij - i and j are cluster indices
    cluster_interdist = pdist(cell2mat(cluster_centroids'));
    % Locate which distance pair is it
    cluster_interdist = squareform(cluster_interdist);
    %% Check cluster distances
%     dist_12 = sqrt(sum((cluster_means{1}-cluster_means{2}).^2));
%     if dist_12 == Z(1,2)
%         disp('Correct calculaton');
%     end

    db_matrix = zeros(cluster_id_len,cluster_id_len);
    %% 4) Establish a performance index lambda(Nc) for determining optimal clusters
    for i = 1:cluster_id_len
        for j = 1:cluster_id_len
            if i==j
                continue;
            end
            db_matrix(i,j) = (cluster_intradist{i}+cluster_intradist{j})/cluster_interdist(i,j);
        end
    end

    db_index = mean(max(db_matrix));
end

function dunn_index = Calc_Dunn_Index(dataset, cluster_ind)

    if unique(length(cluster_ind(cluster_ind>0))) < 2
        dunn_index = 0;
        return;
    end

    all_len = length(cluster_ind);
    outliers_len = length(cluster_ind(cluster_ind==-1));
    cluster_ind(cluster_ind==-1) = [];

    cluster_ids = unique(cluster_ind(cluster_ind~=-1));
    cluster_id_len = length(cluster_ids);

    %% 0) Seperate clusters into cluster_data
    for id_ind = 1:cluster_id_len
        cluster_data{id_ind} = dataset(cluster_ind==cluster_ids(id_ind),:);
        cluster_centroids{id_ind} = mean(cluster_data{id_ind});
        cluster_intradist{id_ind} = mean(pdist2(cluster_data{id_ind}, cluster_centroids{id_ind}));
    end

    %% Plots single cluster centroid to check
%     figure
%     hold on
%     scatter(dataset(:,3),dataset(:,2),4,'blue','filled','diamond')
%     plot(cluster_means{2}(3),cluster_means{2}(2),'rx','LineWidth',4,'MarkerSize',10)
%     grid on 

    %% 3) Compute the interset distances between clusters, and find the minimum of these distances
    %% Dij - i and j are cluster indices
    cluster_interdist = pdist(cell2mat(cluster_centroids'));
    % Locate which distance pair is it
%     cluster_interdist = squareform(cluster_interdist);
    %% Check cluster distances
%     dist_12 = sqrt(sum((cluster_means{1}-cluster_means{2}).^2));
%     if dist_12 == Z(1,2)
%         disp('Correct calculaton');
%     end
    
    dunn_index = max(cell2mat(cluster_intradist))/min(cluster_interdist);
    dunn_index = dunn_index * abs(all_len-outliers_len)/all_len;
end

function [max_dist,min_dist] = Calc_Distance_limits(data)
    max_dist = 0;
    min_dist = 0;
    data_len = length(data(:,1));
    distances = pdist2(data,data);
    [max_dist,max_ind] = max(distances,[],"all");
    [min_dist,min_ind] = min(distances,[],"all");


%     data_ind_one = floor(max_ind/data_len);
%     data_ind_two = max_ind - (data_ind_one*data_len);
% 
%     data_sel = [data_ind_one+1,data_ind_two];
% 
%     hold on
%     scatter3(data(:,1),data(:,2),data(:,3),20,'blue','filled','o')
%     plot3(data(data_sel,1)',data(data_sel,2)',data(data_sel,3)','Color','r','LineWidth',1.5)
    
end

function subsets = Remove_Math_Correlated_Subsets(subsets,correlated_feature_pairs)
    remove_subs = [];
    for sub_ind = 1:length(subsets)
        if 1 < sum(ismember(subsets{sub_ind},correlated_feature_pairs))
            remove_subs = [remove_subs, sub_ind];
        end
    end

    subsets(remove_subs) = [];
end

function subsets = Remove_Subsets_Without_Feature(subsets,feature)
    remove_subs = [];
    for sub_ind = 1:length(subsets)
        if 0 == sum(ismember(subsets{sub_ind},feature))
            remove_subs = [remove_subs, sub_ind];
        end
    end

    subsets(remove_subs) = [];
end

function show_subset_ranks(dataset,dataset_name,feat_names,saved_Nmin,saved_epsilon,scoring_limit,subsets,validity_indices,index_name,index_min)
    max_eps = strrep(num2str(max(saved_epsilon,[],"all")),'.','_');
    min_eps = strrep(num2str(min(saved_epsilon,[],"all")),'.','_');
    max_Nmin = num2str(max(saved_Nmin,[],"all"));
    min_Nmin = num2str(min(saved_Nmin,[],"all"));

    save([ dataset_name '_feature_selection_with_' index_name '_for_Nmin_' min_Nmin '_' max_Nmin '_Eps_' min_eps '_' max_eps ],'validity_indices')

    for ranks = 1:scoring_limit
        [best_index_val,best_index_ind] = max(validity_indices,[],"all");
        comb_len = length(validity_indices(1,:));
        best_subset_ind = floor((best_index_ind-1)/comb_len)+1;
        epsilon = saved_epsilon(best_index_ind);
        Nmin = saved_Nmin(best_index_ind);
        features = subsets{best_subset_ind};
        
        labels= optics_with_clustering(dataset(:,features),Nmin,epsilon);
        labels(labels<1) = -1;
    
        show_3D_clustering(dataset(:,features),labels);
        xlabel(feat_names{features(1)})
        ylabel(feat_names{features(2)})
        zlabel(feat_names{features(3)})
        title({['Rank: ' num2str(ranks)],['Epsilon is: ' num2str(epsilon) ' , MinNumPoints is: ' num2str(Nmin) ', Index value: ' num2str(best_index_val)]})
            
        saveas(gcf,['../figures/feature_selection/' dataset_name '_' index_name '_result/' index_name '_features_selected_for_Nmin_' min_Nmin '_' max_Nmin '_Eps_' min_eps '_' max_eps '_rank_' num2str(ranks) ],'fig')
    
        feat_str = ['(' feat_names{features(1)} ', ' feat_names{features(2)} ', ' feat_names{features(3)} ')'];
        disp([num2str(ranks) '. result: ' feat_str ', Epsilon: ' num2str(epsilon) ', MinNumPoints: ' num2str(Nmin) ', ' index_name ' index value: ' num2str(best_index_val)])
    
        %% Remove best selection
        validity_indices(best_subset_ind,max_ind) = index_min;
    end
end

%% link to link: https://towardsdatascience.com/machine-learning-clustering-dbscan-determine-the-optimal-value-for-epsilon-eps-python-example-3100091cfbc
%% link: https://iopscience.iop.org/article/10.1088/1755-1315/31/1/012012/pdf
function estimate_eps = Estimate_Epsilon(data,Nmin)
    distances = pdist2(data,data,'euclidean');
    sorted_distances = sort(distances,2);
    sorted_distances = sorted_distances(2:end,:); % distances
    knn_distances = sort(mean(sorted_distances(:,1:Nmin),2));
    x = 1:length(knn_distances);
    knn_distances_real = knn_distances;
    knn_distances = (knn_distances-min(knn_distances))/(max(knn_distances)-min(knn_distances));
    x = (x-min(x))/(max(x)-min(x));

    %% Calculate knee of curve as farthest point from line from start to end point
    points = [x',knn_distances];
    line_x_dist = points(end,1)-points(1,1);
    line_knn_dist = points(end,2)-points(1,2);
    numerator = abs( line_x_dist.*(points(1,2)-points(:,2)) - (points(1,1)-points(:,1)).*line_knn_dist );
    denominator = sqrt(line_x_dist ^ 2 + line_knn_dist ^ 2);
    distance = numerator ./ denominator;

    [~,eps_ind] = max(distance);
%     ind_90 = floor(length(knn_distances_real)*0.9);
    estimate_eps = knn_distances_real(eps_ind);

%     plot(x,knn_distances);
%     hold on
%     plot(x(eps_ind),knn_distances(eps_ind),'Marker','x','MarkerSize',10,'Color','r','LineWidth',2);
%     ind_90 = floor(length(knn_distances_real)*0.9);
%     plot(x(ind_90),knn_distances(ind_90),'Marker','x','MarkerSize',10,'Color','r','LineWidth',2);
%     disp(['Before knee: ' num2str(knn_distances_real(eps_ind)) ' , 10% knee: ' num2str(knn_distances_real(ind_90))])

end
