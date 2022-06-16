% clc
close all
clear all

%% UNSUPERVISED LEARNING
% dataset_name = 'small_dataset';
dataset_name = 'big_dataset';

load(['input_matrices/' dataset_name '_feature_selection.mat']);
path = ['../figures/clustering/' , dataset_name ];

% 0) DBSCAN and OPTICS algorithm
err_rows = [];

for feat_ind = 1:length(equ_feature_matrix(1,:))
    x = equ_feature_matrix(:,feat_ind);
    err_ele_ind = find(isinf(x) | isnan(x))';
    if ismember(err_ele_ind,err_rows) == 0
        err_rows = [err_rows,err_ele_ind];
    end
end

equ_feature_matrix(err_rows,:) = [];
equ_emiss_max_t_hr(err_rows,:) = [];

downsample_size = 2;
X = downsample(stand_feature_matrix,downsample_size);
time = downsample(equ_emiss_max_t_hr,downsample_size);
equ_downsampled = downsample(equ_feature_matrix,downsample_size);

peak_freqs = equ_downsampled(:,18);
peak_200k_ind = find((peak_freqs >  1.8e5) & (peak_freqs < 2.1e5));
peak_else_ind = find(~((peak_freqs >  1.8e5) & (peak_freqs < 2.1e5)));
% figure
% hold on
% scatter(time(peak_200k_ind),X(peak_200k_ind,18),'red','filled','SizeData',4);
% scatter(time(peak_else_ind),X(peak_else_ind,18),'blue','filled','SizeData',4);

choose_features = [1, 10,18];

X = [X(:,choose_features)];

%% Hierachical clustering
% T1 = clusterdata(X,3);
% 
% scatter3(X(:,1),X(:,2),X(:,3),4,T1,'filled')
% title('Result of Clustering');

[emiss_num,feat_num] = size(X);
k = feat_num*3;

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

clusterer = clusterDBSCAN('MinNumPoints',k,'Epsilon',0.2,'MaxNumPoints',k*2);

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


%% 1) Find number of natural clusters

% eva_calinski = evalclusters(stand_feature_matrix,'kmeans','CalinskiHarabasz','KList',[1:10]);

% X = score(:,1:number_of_principals);
X = stand_feature_matrix;
% [idx, c, sumd] = kmeans(equ_feature_matrix,2,'Start',opa);
% pc1 = score(:,1);
% pc2 = score(:,2);
% pc3 = score(:,3);
% 
% figure;
% gscatter(pc1,pc2,idx)

kmeans_dist_algs = [ {'sqeuclidean'}; {'cityblock'};{'cosine'};{'correlation'};{'hamming'}];
kmeans_dist_algs = char(kmeans_dist_algs);
evals_crit = [];
evals_K = [];

for alg_ind = 1:length(kmeans_dist_algs)
    idx_all = [];
    alg_name = kmeans_dist_algs(alg_ind,:);
    for num_clust = 1:10
        opts = statset('Display','final');
        [idx,C] = kmeans(X,num_clust,'Distance',alg_name,...
            'MaxIter',1000,'Replicates',5,'Options',opts);
        
        idx_all = [idx_all,idx];
    end
    
    eva_calinski = evalclusters(X,idx_all,'CalinskiHarabasz');
    evals_crit = [evals_crit;eva_calinski.CriterionValues];
    evals_K = [evals_K;eva_calinski.OptimalK];
end


optimalK = Calc_Optimal_Clust_Num(X,idx_all);

disp(["Calculated number of optimal clusters: " num2str(optimalK)]);


idx_neg = idx(1:ind_negativ_end);
idx_mix = idx(ind_negativ_end:end);
figure;
hold on
% plot(X(idx_mix==1,1),X(idx_mix==1,2),'g.','MarkerSize',5)
% plot(X(idx_neg==1,1),X(idx_neg==1,2),'r.','MarkerSize',5)
% plot(X(idx_neg==2,1),X(idx_neg==2,2),'b.','MarkerSize',5)
% plot(X(idx_mix==2,1),X(idx_mix==2,2),'y.','MarkerSize',5)
% scatter3(X(idx==1,1),X(idx==1,2),X(idx==1,3), 'red', 'filled')
% scatter3(X(idx==2,1),X(idx==2,2),X(idx==2,3), 'yellow', 'filled')
%% Mixed and cluster 1
% plot(equ_emiss_max_t_hr(idx_mix==1,1),stand_feature_matrix(idx_mix==1,18),'g.','MarkerSize',5)
%% Negative and cluster 1
% plot(equ_emiss_max_t_hr(idx_neg==1,1),stand_feature_matrix(idx_neg==1,18),'r.','MarkerSize',5)
%% Negative and cluster 2
% plot(equ_emiss_max_t_hr(idx_neg==2,1),stand_feature_matrix(idx_neg==2,18),'b.','MarkerSize',5)
%% Mixed and cluster 2
plot(equ_emiss_max_t_hr(idx_mix==2,1),stand_feature_matrix(idx_mix==2,18),'y.','MarkerSize',5)
% plot(C(:,1),C(:,2),'kx','MarkerSize',15,'LineWidth',3) 
legend('Cluster 1 negative','Cluster 1 mixed','Cluster 2 negative','Cluster 2 mixed', 'Centroids',...
       'Location','NW')
title(['Cluster Assignments and Centroids']);
hold off

saveas(gcf,[path '_k-means_clusters'] , 'fig')
%     T = clusterdata(score(:,1:3),'maxclust',5);

disp("Unsupervised learning finished!");
