clear all
close all
%% Taken from https://sci-hub.se/10.1137/1.9781611973440.96

dataset_num = 0;

%% 1) Import all Real Datasets referenced in the paper


%% 2) Create similar Synthetic 2D Datasets shown in paper

%% First dataset
circle_dataset = [create_circle_data(2,1500,-0.1,0.04);create_circle_data(1,1000,-0.1,0.02)];
    
%% Remove first and fourth quadrant of circle
circle_dataset(circle_dataset(:,1).*circle_dataset(:,2) < 0,:) = [];

range = [floor(min(circle_dataset(:,1))),floor(max(circle_dataset(:,1)))];
% noise_dataset =  create_noise_data(1000,range);
noise_dataset = create_noise_data(300,[-2,2]);
circle_dataset = [ circle_dataset; noise_dataset];

% hold on
% scatter(circle_dataset(:,1),circle_dataset(:,2),10,'blue','filled','o')
% scatter(noise_dataset(:,1),noise_dataset(:,2),10,'red','filled','o')

clusterer = clusterDBSCAN("Epsilon",0.08,'MinNumPoints',10);
[idx,~] = clusterer(circle_dataset);

% show_3D_clustering(circle_dataset,idx);

dataset_num = dataset_num + 1;
density_based_datasets{dataset_num} = circle_dataset;
goal_idxes{dataset_num} = idx;
epsilons{dataset_num} = [0.01:0.01:0.5];

%% Second dataset
square_filled_1_dataset = create_square_full_data(100,7,0)+120;
square_empty_dataset = create_square_empty_data(1000,50,10,0)+120;

square_filled_2_dataset = create_square_full_data(60,7,0);
square_empty_turned_dataset = create_square_empty_data(2000,50,10,40);

noise_dataset = create_noise_data(400,[-100,200]);

dataset_2 = [square_filled_1_dataset;square_empty_dataset;square_filled_2_dataset;square_empty_turned_dataset;noise_dataset];

% hold on
% scatter(dataset_2(:,1),dataset_2(:,2),5,'blue','filled','o')

clusterer = clusterDBSCAN("Epsilon",9,'MinNumPoints',10);
[idx,~] = clusterer(dataset_2);

% show_3D_clustering(dataset_2,idx);

dataset_num = dataset_num + 1;
density_based_datasets{dataset_num} = dataset_2;
goal_idxes{dataset_num} = idx;
epsilons{dataset_num} = [1:0.5:25.5];

%% Third dataset

spiral_data = twospirals();
noise_dataset = create_noise_data(500,[-11,11]);

spiral_data = [spiral_data;noise_dataset];

% scatter(spiral_data(:,1),spiral_data(:,2),5,"blue","filled","o") ; % nturns crossings, including end point

clusterer = clusterDBSCAN("Epsilon",0.65,'MinNumPoints',10);
[idx,~] = clusterer(spiral_data);

% show_3D_clustering(spiral_data,idx);

dataset_num = dataset_num + 1;
density_based_datasets{dataset_num} = spiral_data;
goal_idxes{dataset_num} = idx;
epsilons{dataset_num} = [0.05:0.05:2.5];

%% Fourth dataset

first_circle = create_circle_data(40,1000,-0.5,2);

first_circle(first_circle(:,1) > 0,:) = [];

first_circle(:,1) = first_circle(:,1) + 350;
first_circle(:,2) = first_circle(:,2) + 400;


% create_circle_data(75,1000,-3.5,0.02)

noise_dataset = create_noise_data(50,[-5,5]);
noise_dataset(:,1) = noise_dataset(:,1) + 350;
noise_dataset(:,2) = noise_dataset(:,2) + 400;


second_circle = create_circle_data(25,500,-0.25,1);

second_circle(second_circle(:,1) < -5,:) = [];

second_circle(:,1) = second_circle(:,1) + 425;
second_circle(:,2) = second_circle(:,2) + 450;

noise_dataset2 = create_noise_data(200,[-4,4]);
noise_dataset2(:,1) = noise_dataset2(:,1) + 425;
noise_dataset2(:,2) = noise_dataset2(:,2) + 450;

third_circle = create_circle_data(25,500,-0.25,1);

third_circle(third_circle(:,1) > 5,:) = [];

third_circle(:,1) = third_circle(:,1) + 425;
third_circle(:,2) = third_circle(:,2) + 400;

noise_dataset3 = create_noise_data(100,[-4,4]);
noise_dataset3(:,1) = noise_dataset3(:,1) + 425;
noise_dataset3(:,2) = noise_dataset3(:,2) + 400;

noise_dataset4 = create_noise_data(200,[-6,6]);
noise_dataset4(:,1) = noise_dataset4(:,1) + 385;
noise_dataset4(:,2) = noise_dataset4(:,2) + 360;

noise_dataset5 = create_noise_data(400,[-80,80]);
noise_dataset5(:,1) = noise_dataset5(:,1) + 385;
noise_dataset5(:,2) = noise_dataset5(:,2) + 415;

dataset4 = [ first_circle; noise_dataset; second_circle; third_circle; noise_dataset2; noise_dataset3; noise_dataset4; noise_dataset5];

% hold on
% scatter(dataset4(:,1),dataset4(:,2),5,'blue','filled','o')

clusterer = clusterDBSCAN("Epsilon",3.1,'MinNumPoints',10);
[idx,~] = clusterer(dataset4);

% show_3D_clustering(dataset4,idx);

dataset_num = dataset_num + 1;
density_based_datasets{dataset_num} = dataset4;
goal_idxes{dataset_num} = idx;
epsilons{dataset_num} = [1.5:0.25:13.75];

%% Save datasets

save('density_based_datasets.mat',"density_based_datasets");

disp('Done!');

%% Add 10 more datasets
load 'input_matrices/classified_data.mat'

dataset_num = length(density_based_datasets);
new_dataset_ind = 0;
for ind=1:length(datasets)
    new_dataset_ind = new_dataset_ind+1;
    density_based_datasets{dataset_num+new_dataset_ind} = datasets{new_dataset_ind};
    goal_idxes{dataset_num+new_dataset_ind} = labels{new_dataset_ind};
    epsilons{dataset_num+new_dataset_ind} = epsilon_range{new_dataset_ind};
end

save('goal_density_clust.mat','goal_idxes');

% for i=1:length(epsilons)
%     disp(num2str(length(epsilons{i})))
% end

%% Compute idxes for feature selection

save_fig_path = '../figures/clustering/test_validity_indices_matlab/';
dataset_num = length(density_based_datasets);

for dataset_ind = 1:dataset_num
%     dataset_ind = 3;
    for eps_ind = 1:length(epsilons{dataset_ind})
%         eps_ind = 5;
        data = density_based_datasets{dataset_ind};
%         data(:,1) = (data(:,1)-min(data(:,1)))/(max(data(:,1))-min(data(:,1)));
%         data(:,2) = (data(:,2)-min(data(:,2)))/(max(data(:,2))-min(data(:,2)));
%     
        % 0.1244, 10.9181, 0.6863, 4.5038
%         epsilon = clusterDBSCAN.estimateEpsilon(data,10,10*3);
        epsilon = epsilons{dataset_ind}(eps_ind);
        clusterer = clusterDBSCAN("Epsilon",epsilon,'MinNumPoints',10);
        [idx,~] = clusterer(data);
%         idx = optics_with_clustering(data,10,0.05);
        
        idx(idx==0) = -1;

        idxes{dataset_ind,eps_ind} = idx;

%         show_3D_clustering(data,idx);

        valid_indices = find(idx>0);
        valid_data = data(valid_indices,:);
        valid_idx = idx(valid_indices);
        outliers_len = length(find(idx<1));
        if length(unique(valid_idx)) > 1
            DBCV_index{dataset_ind}(eps_ind) = Calculate_DBCV_index(valid_data,valid_idx,outliers_len);
           
            data_len = length(data(:,1));
            outlier_factor = (data_len-outliers_len)/data_len;
    
            eva_silhouette = evalclusters(valid_data,valid_idx,'silhouette');
            Silhouette_index{dataset_ind}(eps_ind) = eva_silhouette.CriterionValues * outlier_factor;
        
            % The Davies–Bouldin index.
            eva_davies_bouldin = evalclusters(valid_data,valid_idx,'DaviesBouldin');
            DB_index{dataset_ind}(eps_ind) = eva_davies_bouldin.CriterionValues * outlier_factor.^-1;
        
            % The Calinski-Harabasz index
            eva_calinski = evalclusters(valid_data,valid_idx,'CalinskiHarabasz');
            CH_index{dataset_ind}(eps_ind) = eva_calinski.CriterionValues * outlier_factor;
        
            % The Dunn indexC
            Dunn_index{dataset_ind}(eps_ind) = Calc_Dunn_Index(valid_data,valid_idx) * outlier_factor;
    %         show_3D_clustering(data,idx);
        else
            DBCV_index{dataset_ind}(eps_ind) = -1;
            Silhouette_index{dataset_ind}(eps_ind) = -1;
            DB_index{dataset_ind}(eps_ind) = 1;
            CH_index{dataset_ind}(eps_ind) = -1;
            Dunn_index{dataset_ind}(eps_ind) = -1;
        end
        disp(['Done epsilon iteration: ' num2str(eps_ind) '/' num2str(length(epsilons{dataset_ind}))])
    end
    [max_val,max_ind] = max(DBCV_index{dataset_ind},[],"all");
    info_str = ['For dataset' num2str(dataset_ind) ' clustering was best for epsilon =' num2str(epsilons{dataset_ind}(max_ind)) ' and DBCV_index =' num2str(max_val)];
    disp(info_str);
    show_3D_clustering(data,idxes{dataset_ind,max_ind});
    title(info_str)
    saveas(gcf, [save_fig_path 'dataset' num2str(dataset_ind) '_best_clustering_for_DBCV'], 'fig')
    close all

    [max_val,max_ind] = max(Silhouette_index{dataset_ind},[],"all");
    info_str = ['For dataset' num2str(dataset_ind) ' clustering was best for epsilon =' num2str(epsilons{dataset_ind}(max_ind)) ' and Silh_index =' num2str(max_val)];
    disp(info_str);
    show_3D_clustering(data,idxes{dataset_ind,max_ind});
    title(info_str)
    saveas(gcf, [save_fig_path 'dataset' num2str(dataset_ind) '_best_clustering_for_Silh'], 'fig')
    close all

    [min_val,min_ind] = min(DB_index{dataset_ind},[],"all");
    info_str = ['For dataset' num2str(dataset_ind) ' clustering was best for epsilon =' num2str(epsilons{dataset_ind}(min_ind)) ' and DB_index =' num2str(min_val)];
    disp(info_str);
    show_3D_clustering(data,idxes{dataset_ind,max_ind});
    title(info_str)
    saveas(gcf, [save_fig_path 'dataset' num2str(dataset_ind) '_best_clustering_for_DB'], 'fig')
    close all

    [max_val,max_ind] = max(CH_index{dataset_ind},[],"all");
    info_str = ['For dataset' num2str(dataset_ind) ' clustering was best for epsilon =' num2str(epsilons{dataset_ind}(max_ind)) ' and CH_index =' num2str(max_val)];
    disp(info_str);
    show_3D_clustering(data,idxes{dataset_ind,max_ind});
    title(info_str)
    saveas(gcf, [save_fig_path 'dataset' num2str(dataset_ind) '_best_clustering_for_CH'], 'fig')
    close all

    [max_val,max_ind] = max(Dunn_index{dataset_ind},[],"all");
    info_str = ['For dataset' num2str(dataset_ind) ' clustering was best for epsilon =' num2str(epsilons{dataset_ind}(max_ind)) ' and Dunn_index =' num2str(max_val)];
    disp(info_str);
    show_3D_clustering(data,idxes{dataset_ind,max_ind});
    title(info_str)
    saveas(gcf, [save_fig_path 'dataset' num2str(dataset_ind) '_best_clustering_for_Dunn'], 'fig')
    close all

end

save('saved_idx.mat','idxes','density_based_datasets','goal_idxes') 

disp('Done 2/2');

%% Helper functions

function circle_dataset = create_circle_data(radius,N,mean,std)
    circle_dataset = zeros(N,2);
    for data_ind = 1:N
        circle_dataset(data_ind,:) = [cos(2*pi/N*data_ind)*radius+normrnd(mean,std),sin(2*pi/N*data_ind)*radius+normrnd(mean,std)];
    end
end

function square_empty_dataset = create_square_empty_data(N,a,square_width,angle)
    square_empty_dataset = (rand(N,2)*(2*a))-a;
    lim_low = -a+square_width;
    lim_high = a-square_width;
    dim1_cond = square_empty_dataset(:,1) > lim_low & square_empty_dataset(:,1) < lim_high;
    dim2_cond = square_empty_dataset(:,2) > lim_low & square_empty_dataset(:,2) < lim_high;
    square_empty_dataset(dim1_cond & dim2_cond,:) = [];

    %% https://se.mathworks.com/matlabcentral/answers/432322-rotate-a-2d-plot-around-a-specific-point-on-the-plot
    Xs = square_empty_dataset(:,1);
    Ys = square_empty_dataset(:,2);

    Xsr =  Xs*cos(angle) + Ys*sin(angle);    % shifted and rotated data
    Ysr = -Xs*sin(angle) + Ys*cos(angle);    %

    square_empty_dataset(:,1) =  Xsr; 
    square_empty_dataset(:,2) =  Ysr;
end

function square_full_dataset = create_square_full_data(N,a,angle)
    square_full_dataset = (rand(N,2)*(2*a))-a;

    %% https://se.mathworks.com/matlabcentral/answers/432322-rotate-a-2d-plot-around-a-specific-point-on-the-plot
    Xs = square_full_dataset(:,1);
    Ys = square_full_dataset(:,2);

    Xsr =  Xs*cos(angle) + Ys*sin(angle);    % shifted and rotated data
    Ysr = -Xs*sin(angle) + Ys*cos(angle);    %

    square_full_dataset(:,1) =  Xsr; 
    square_full_dataset(:,2) =  Ysr;
end

% function spiral = create_spiral(start_point,end_point,nturns)
%     % given values
%     pos = [start_point;    % startpoint
%             end_point] ;  % endpoint
%     % engine
%     dp = diff(pos,1,1) ;
%     R = hypot(dp(1), dp(2)) ;
%     phi0 = atan2(dp(2), dp(1)) ;
%     phi = linspace(0, nturns*2*pi, 10000) ; % 10000 = resolution
%     r = linspace(0, R, numel(phi)) ;
%     x = pos(1,1) + r .* cos(phi + phi0) ;
%     y = pos(1,2) + r  .* sin(phi + phi0) ;
%     spiral = [x',y'];
% %     spiral(1:end/2,:) = [];
% %     spiral(1) = [];
% end

function data = twospirals(N, degrees, start, noise)
% Generate "two spirals" dataset with N instances.
% degrees controls the length of the spirals
% start determines how far from the origin the spirals start, in degrees
% noise displaces the instances from the spiral. 
%  0 is no noise, at 1 the spirals will start overlapping

    if nargin < 1
        N = 2500;
    end
    if nargin < 2
        degrees = 570;
    end
    if nargin < 3
        start = 90;
    end
    if nargin < 5
        noise = 0.3;
    end  
    
    deg2rad = (2*pi)/360;
    start = start * deg2rad;

    N1 = floor(N/2);
    N2 = N-N1;
    
    n = start + sqrt(rand(N1,1)) * degrees * deg2rad;   
    d1 = [-cos(n).*n + rand(N1,1)*noise sin(n).*n+rand(N1,1)*noise];
    
    n = start + sqrt(rand(N1,1)) * degrees * deg2rad;      
    d2 = [cos(n).*n+rand(N2,1)*noise -sin(n).*n+rand(N2,1)*noise];
    
    data = [d1;d2];
end

function noise_dataset = create_noise_data(N,range)
    noise_dataset = (rand(N,2)*(range(2)-range(1)))+range(1);
end