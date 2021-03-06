
close all
clear all

dataset_name = 'small_dataset';
% dataset_name = 'big_dataset';
load(['../feature_selection/input_matrices/' dataset_name '_UAE_equ_features.mat']);

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

feature_matrix(err_rows,:) = [];

% Standardization
for feat_ind = 1:length(feature_matrix(1,:))
    % Standardization with z-score using formula x_norm = (x-mean(x))/std(x);
    % link: https://www.indeed.com/career-advice/career-development/how-to-calculate-z-score
    x = feature_matrix(:,feat_ind);
%     feature_matrix(:,feat_ind) = (x-mean(x))/std(x);
    feature_matrix(:,feat_ind) = (x-min(x))/(max(x)-min(x));
end
dataset = feature_matrix;

use_examples = [2];
%% ARTIFICIAL DATA
if ismember(1,use_examples)
    %% 1) Circles - link: https://www.analyticsvidhya.com/blog/2020/09/how-dbscan-clustering-works/
    circle_dataset = [create_circle_data(500,1000); create_circle_data(300,700); create_circle_data(100,300)];
    
    range = [floor(min(circle_dataset(:,1))),ceil(max(circle_dataset(:,1)))];
    noise_dataset =  create_noise_data(300,range);
    circle_dataset = [ circle_dataset; noise_dataset];
    
%     scatter(circle_dataset(:,1),circle_dataset(:,2),10,'blue','filled','o')
    % hold on
    % scatter(noise_dataset(:,1),noise_dataset(:,2),10,'red','filled','o')
    
    min_points = 4;
    max_points = min_points*2;
    epsilon = clusterDBSCAN.estimateEpsilon(circle_dataset,min_points,max_points);
    [order, reach_dist] = clusterDBSCAN.discoverClusters(circle_dataset,Inf,min_points);
    reach_dist(isinf(reach_dist)) = max(reach_dist(~isinf(reach_dist)));
    plot(reach_dist(order),'LineWidth',2);
    clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',epsilon);
    [idx,clusterids] = clusterer(circle_dataset);
    figure;
%     subplot(2,1,1)
    show_3D_clustering(circle_dataset,idx,1);
%     title(['Epsilon is: ' num2str(epsilon)])
    
    % epsilon = clusterDBSCAN.estimateEpsilon(circle_dataset,min_points,max_points);
%     epsilon = 30;
    idx= optics_with_clustering(circle_dataset,min_points,epsilon);
    figure;
%     epsilon = epsilon +2;
%     clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',1000);
%     [idx,clusterids] = clusterer(circle_dataset);
%     subplot(2,1,2)
    show_3D_clustering(circle_dataset,idx,1);
%     title(['Epsilon is: ' num2str(epsilon)])
end

%% 2) All simple structures
if ismember(2,use_examples)
    load 'input_matrices/optics_artficial_data.mat'
    load 'input_matrices/classified_data.mat'
    load class_validation.mat
    
    data_all=importdata('dataclust.txt')';

     %data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
     %data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];
    
    data_all = data_all';
    data_all = sortrows(data_all(2:end,:),2);

%     data_all(:,1)= (data_all(:,1)-min(data_all(:,1)))./(max(data_all(:,1))-min(data_all(:,1)));
%     data_all(:,2)= (data_all(:,2)-min(data_all(:,2)))./(max(data_all(:,2))-min(data_all(:,2)));
    
    data = data_all;
    load '../clustering/input_matrices/small_dataset_stand_feature_matrix.mat'
    data = feature_matrix(:,[3,17,18]);
%     figure
%     scatter( data_all(:,2), data_all(:,1), 'b','.');
%     title('Ulazni podaci za grupiranje');
%     ylabel('frequency, kHz');

    epsilons_array = [9,9.5,10,10.5,11];
    min_points_array = [5:20];
    all_tests_num = length(epsilons_array)*length(min_points_array);
    test_num = 0;
    for min_points_ind = 1:length(min_points_array)
        for epsilons_ind = 1:length(epsilons_array)
            test_num = test_num+1;
            epsilon = epsilons_array(epsilons_ind);
            min_points = min_points_array(min_points_ind);
    
            idx = optics_with_clustering(data,12,0.03);
            idx(idx==0) = -1;
            show_3D_clustering(data,idx);

            valid_indices = find(idx>0);
            data_without_outliers = data(valid_indices,:);
            idx_without_outliers = idx(valid_indices);
            DBCV(min_points_ind,epsilons_ind) = Calculate_DBCV_index(data_without_outliers,idx_without_outliers,length(find(idx<1)));
            disp(['Finished test : ' num2str(test_num) '/' num2str(all_tests_num)]);
        end
    end

    
    idx = optics_with_clustering(data_all,15,5);
    idx(idx==0) = -1;
    show_3D_clustering(data_all,idx);

    outlier_indices = find(idx==-1);
    data_all(outlier_indices,:) = [];
    idx(outlier_indices,:) = [];

    disp(['DBCV index: ' num2str(Calculate_DBCV_index(data_all,idx,length(outlier_indices)))])

    epsilons_array = [0:0.01:1];
    min_points_array = [5:20];
    min_point_density = ((epsilons_array.^2).*pi)./min_points_array';

    data = datasets{1};
    labels_goal = labels{1};

    idx = optics_with_clustering(data,10,0.2);
    idx(idx==0) = -1;

    show_3D_clustering(data,idx);
    show_3D_clustering(data,labels_goal);
    

    alg_title = {'Official OPTICS','New Optics'};
    for alg_ind = 1:2
        figure;
        hold on;
        title(alg_title{alg_ind})
        for dataset_ind = 1:length(artificial_dataset(:,1))
        %     epsilon = artificial_dataset(dataset_ind,3);
        %     epsilon = epsilon{1};
            min_points = artificial_dataset(dataset_ind,2);
            min_points = double(min_points{1});
            dataset = cell2mat(artificial_dataset(dataset_ind,1));
            min_points = 15;


            epsilon = clusterDBSCAN.estimateEpsilon(dataset,min_points,min_points*2);
            epsilon = epsilon*0.5;
%             epsilon = Inf;

%             [orderedList, reachDistList] = my_optics(dataset,epsilon,min_points);
%             reachDistList(isinf(reachDistList)) = -1;
        
%             figure
%             plot(reachDistList(orderedList), 'linewidth', 1);
%             title('optics')
%             grid on

            if alg_ind == 1
                clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',epsilon);
                [idx,~] = clusterer(dataset);
            elseif alg_ind == 2
                idx= optics_with_clustering(dataset,min_points,Inf);
            end
            subplot(3,2,dataset_ind)
            show_3D_clustering(dataset,idx,1);
            title(['Dataset num: ' num2str(dataset_ind) '/' num2str(length(artificial_dataset(:,1)))])
        end
    end
end
%% 3) GMM
if ismember(3,use_examples)
    mu1 = [1 2];          % Mean of the 1st component
    sigma1 = [1 0; 0 1]; % Covariance of the 1st component
    mu2 = [20 20];        % Mean of the 2nd component
    sigma2 = [10 0; 0 10];  % Covariance of the 2nd component

    r1 = mvnrnd(mu1,sigma1,1000);
    r2 = mvnrnd(mu2,sigma2,400);
    X = [r1; r2];

    figure;
    subplot(2,2,1)
    scatter(r1(:,1),r1(:,2),4,"blue","filled");
    hold on
    scatter(r2(:,1),r2(:,2),4,"red","filled");
    hold off

    subplot(2,2,2)
    scatter(r1(:,1),r1(:,2),4,"blue","filled");
    hold on
    scatter(r2(:,1),r2(:,2),4,"red","filled");
    hold off


    figure;
    min_points = 20;
    epsilon = clusterDBSCAN.estimateEpsilon(X,min_points,min_points*2);
    [order,reach_dist] = clusterDBSCAN.discoverClusters(X,15,min_points);
    plot(reach_dist(order),'LineWidth',2);
%     subplot(2,2,3)
    clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',15);
    [idx,~] = clusterer(X);
    show_3D_clustering(X,idx);
%     title('Offical OPTICS')
%     subplot(2,2,4)
    idx= optics_with_clustering(X,min_points,Inf);
    show_3D_clustering(X,idx);
%     title('New OPTICS')

end

%% 4) Prove why data is wrong
if ismember(4,use_examples)

    maxEpsilon = 2;
    minNumPoints = 20;
    
    X = [randn(100,2) + [11.5,11.5]; randn(200,2) + [25,15]; randn(200,2) + [8,20]; 10*rand(100,2) + [20,20]];
    plot(X(:,1),X(:,2),'.')
    axis equal
    grid
%     mu1 = [1 2];          % Mean of the 1st component
%     sigma1 = [1 0; 0 1]; % Covariance of the 1st component
%     mu2 = [1 2];        % Mean of the 2nd component
%     sigma2 = [10 0; 0 10];  % Covariance of the 2nd component
% 
%     r1 = mvnrnd(mu1,sigma1,1000);
%     r2 = mvnrnd(mu2,sigma2,400);
%     X = [r1; r2];
    eps=0.02;
    eps2=Inf;
%     [order,reach_dist] = clusterDBSCAN.discoverClusters(X,eps,minNumPoints);
%     [order2,reach_dist2] = clusterDBSCAN.discoverClusters(X,eps2,minNumPoints);
    X = dataset(:,[13,17,18]);
    [order,reach_dist, coreDistList, procesList] = optics(X, minNumPoints, eps);
    [order2,reach_dist2, coreDistList, procesList] = optics(X, minNumPoints, eps2);

%     clusterDBSCAN.discoverClusters(X,maxEpsilon,minNumPoints);
    
    figure;
%     bar(order,reach_dist,1.1);
    subplot(2,1,1)
    plot(reach_dist(order))
    title(['Epsilon was: ' num2str(eps)])
	subplot(2,1,2)
    plot(reach_dist2(order2))
    title(['Epsilon was: ' num2str(eps2)])

    idx = zeros(1,length(X(:,1)));
    show_3D_clustering(X,idx);

    ranges = [0,100,300,500,600];


    idx= optics_with_clustering(X,minNumPoints,Inf);
    show_3D_clustering(X,idx);
    title('New OPTICS')

    ordered_reach_dist = reach_dist(order);
    cluster_limit = 2;
    dilims = [find(ordered_reach_dist>cluster_limit),length(ordered_reach_dist)];
    dilims(find(diff(dilims)==1)) = [];
    colors = jet(length(dilims)-1);
    dilims = [1,1100,length(ordered_reach_dist)];
    figure;
    for dilim_ind = 1:length(dilims)-1
        cluster_range = dilims(dilim_ind):dilims(dilim_ind+1);
        hold on
        scatter(X(cluster_range,1),X(cluster_range,2),4,colors(dilim_ind,:),'filled','o')
    end
     
end

%% REAL DATA
if ismember(5,use_examples)
    features = [14,15,17];
    feature_subset = dataset(:,features);
%     feature_subset = dataset(:,[1,2,7]);
    [data_len, feat_len] = size(feature_subset);

    vbls = {'rise time','counts to','counts from','duration',...
    'peak amplitude','average frequency','rms','asl','reverbation frequency',...
    'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',...
    'pp3','pp4','centroid frequency','peak frequency','amplitude of frequency','num of freq peaks','weighted peak frequency',....
    'total counts','fall time'};

    param_comb = [ 9,0.02;  9,0.03;  9,0.04;  9,0.05;
                  10,0.02; 10,0.03; 10,0.04; 10,0.05;
                  11,0.02; 11,0.03; 11,0.04; 11,0.05;
                  12,0.02; 12,0.03; 12,0.04; 12,0.05;];

    for comb_ind = 1:length(param_comb(:,1))
        min_points = param_comb(comb_ind,1);
        epsilon = param_comb(comb_ind,2);
        idx= optics_with_clustering(feature_subset,min_points,epsilon);
%         clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',epsilon);
%         [idx,~] = clusterer(feature_subset);
        idx(idx==0) = -1;
        show_3D_clustering(feature_subset,idx);
        xlabel(vbls{features(1)})
        ylabel(vbls{features(2)})
        zlabel(vbls{features(3)})
        title(['Epsilon is: ' num2str(epsilon) ' , MinNumPoints is: ' num2str(min_points)])
        feature_str = [vbls{features(1)} '_' vbls{features(2)} '_' vbls{features(3)} '/'];
        saveas(gcf, ['../figures/clustering/test_optics_params/' vbls{features(1)}  dataset_name '_eps_' num2str(epsilon)], 'fig')
    end

    close all

    %% gusto??a je 15 to??aka unutar radiusa 0.005*

    eps_estimate = clusterDBSCAN.estimateEpsilon(feature_subset,min_points,min_points*2);

%     for i = 3:8
%         eps = epsilon*i;
%         clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',eps);
%         [idx,~] = clusterer(feature_subset);
%     %     subplot(2,1,1)
%         show_3D_clustering(feature_subset,idx);
%         title(['Epsilon is: ' num2str(eps)]);% ' , was estimated: ' num2str(eps_estimate)])
%     end

    for min_points = 15:20
        eps_estimate = clusterDBSCAN.estimateEpsilon(feature_subset,min_points,min_points*2);
        clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',eps_estimate);
        [idx,~] = clusterer(feature_subset);
    %     subplot(2,1,1)
        show_3D_clustering(feature_subset,idx);
        title(['Epsilon is: ' num2str(eps_estimate) ' , MinNumPoints is: ' num2str(min_points)])
    end

    clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',eps_estimate);
    [idx,~] = clusterer(feature_subset);
%     subplot(2,1,1)
    show_3D_clustering(feature_subset,idx);
    title(['Epsilon estimated at: ' num2str(eps_estimate)])



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

function add_num(data,ele)
arguments
    data OpticsData
    ele
end
    data.dataset(1) = ele;
%     data.addNum(data);
end