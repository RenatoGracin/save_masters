clear all

vbls2 = {'rise time','counts to','counts from','duration',...
        'peak amplitude','average frequency','rms','asl','reverbation frequency',...
        'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',...
        'pp3','pp4','centroid frequency','peak frequency','amplitude of peak frequency','num of freq peaks','weighted peak frequency',...
        'total counts','fall time'};

load('c:/Users/bujak/Desktop/FER/5. godina/DIPLOMSKI PROJEKT/DILPOMSKI RAD/plant_AE_classification/clustering/input_matrices/small_dataset_stand_feature_matrix.mat')
load('c:/Users/bujak/Desktop/FER/5. godina/DIPLOMSKI PROJEKT/DILPOMSKI RAD/plant_AE_classification/clustering/input_matrices/optics_result.mat')
features = [18,1,2];
subset = dataset(:,features);
% plot subset in 3D
% scatter3(subset(:,1),subset(:,2),subset(:,3),4,'blue','filled',Marker='o')

K = 1;
minPoints = length(features)*K;
calculate_clusters(subset,1,{'peak freq' 'rise time' 'counts to'},minPoints);

clusterDBSCAN.discoverClusters(subset,0.5656,5);
[order, reach_dist] = clusterDBSCAN.discoverClusters(subset,0.5656,3);


% diff with python
hmm = max(reach_dist-reach_dist_py);
order_py = double(order_py);
hmm2 = order-(order_py+1);


ylim([min(reach_dist) max(reach_dist)])
gca.LineWidth=10;
clust_limiters = [find(reach_dist>=0.5656),length(reach_dist)];

for limit_ind = 1:length(clust_limiters)-1
    clust_indices{limit_ind} = order(clust_limiters(limit_ind):clust_limiters(limit_ind+1));
end
% colors = {'magenta','black','blue','yellow','red','green','magenta'};
colors = jet(length(clust_limiters)); % more different colors.
figure
grid on
for id_ind = 1:length(clust_indices)
    scatter3(subset(clust_indices{id_ind},1),subset(clust_indices{id_ind},2),subset(clust_indices{id_ind},3),10,colors(id_ind,:),'filled')
    hold on
end
[idx,clusterids] = calculate_clusters(subset, 1, {vbls2{features}});


clear all
close all
%% Test OPTICS algorithm
load('input_matrices\small_dataset_stand_feature_matrix.mat')
dataset = dataset(:,[14,17,18]);
% [emiss_num,feat_num] = size(dataset);
scatter3(dataset(:,1),dataset(:,2),dataset(:,3),5,'blue','filled')
xlabel('pp2')
ylabel('centroid freq')
zlabel('peak frequency')

load('dataClusterDBSCAN.mat');
[emiss_num,feat_num] = size(x);

% scatter(x(:,1),x(:,2),4,'blue','filled')

k = feat_num*3;

[m,n]=size(x);
CD=zeros(1,m);
k_dist=zeros(1,m);
% Calculate optimal epsilon for set min num points
for i=1:m	
    D=sort(sqrt(sum((((ones(m,1)*x(i,:))-x).^2)')));
    k_dist(i) = mean(D(1:k+1));
end
knee_val = find_knee_of_curve(sort(k_dist)); 
% scatter(1:length(k_dist),sort(k_dist),'blue','filled');
plot(1:length(k_dist),sort(k_dist),Color='b');

epsilon = clusterDBSCAN.estimateEpsilon(x,k,k*2);


% Core point = has to have a minimum of MinNumPoints points inside radius of Epsilon
% EnableDisambiguation - connectes dimension limits like their distance is zero
% Core distance - farthest neighbour of point that is closer than minEpsilon
% All distances only work for Core points
% Core distance - describes the minimum value for epsilon in order to keep the point a core point.
% Reachability distance - expresses the distance which is reachable from a core point.
%                       - it is defined for every pair of points from Core point
%                       - minmum value is Core distance for points closer
%                       than Core distance, else it is distance between
%                       points
% clusterer = clusterDBSCAN('MinNumPoints',3,'Epsilon',2,'EnableDisambiguation',true,'AmbiguousDimension',[1 2]);
% amblims = [0 20; -30 30];
% [idx,clusterids] = clusterer(x,amblims);
% 
% plot(clusterer,x,idx)

clear all
clc
close all
% x = [rand(20,2)+12; rand(20,2)+10; rand(20,2)+15];
load('test_dataset.mat','x')
plot(x(:,1),x(:,2),'.')

clusterer = clusterDBSCAN('Epsilon',1,'MinNumPoints',3);
idx1 = clusterer(x);
clusterer.Epsilon = 2;
idx = clusterer(x);

hAx1 = subplot(1,2,1);
plot(clusterer,x,idx1, ...
    'Parent',hAx1,'Title','Epsilon = 1')
hAx2 = subplot(1,2,2);
plot(clusterer,x,idx, ...
    'Parent',hAx2,'Title','Epsilon = 3')
hold on

cluster_ids = unique(idx);
cluster_id_len = length(cluster_ids);

for id_ind = 1:cluster_id_len
    %% xk = vector of xij for certain cluster j
    cluster_data{id_ind} = x(idx==cluster_ids(id_ind),:);
    %% zj - mean value fot certain cluster j
    cluster_means{id_ind} = mean(cluster_data{id_ind});
    scatter(cluster_means{id_ind}(1),cluster_means{id_ind}(2),10,'black','LineWidth',2,Marker='x',MarkerEdgeColor='flat',Parent=hAx2)
    
end

[order, reach_dist] = clusterDBSCAN.discoverClusters(x,10,6);

clust_limiters = [find(reach_dist>1),length(reach_dist)];

for limit_ind = 1:length(clust_limiters)-1
    clust_indices{limit_ind} = order(clust_limiters(limit_ind):clust_limiters(limit_ind+1));
end
colors = {'magenta','black','blue','yellow','red','green','magenta'};
figure
for id_ind = 1:length(clust_indices)
    hold on
    scatter(x(clust_indices{id_ind},1),x(clust_indices{id_ind},2),4,colors{id_ind},'filled')
end


disp(['distance between clusters:' num2str(pdist([cluster_means{1};cluster_means{2}],'euclidean'))])


function knee_val = find_knee_of_curve(curve)
    %# get coordinates of all the points
    nPoints = length(curve);
    allCoord = [1:nPoints;curve]';              %'# SO formatting
    
    %# pull out first point
    firstPoint = allCoord(1,:);
    
    %# get vector between first and last point - this is the line
    lineVec = allCoord(end,:) - firstPoint;
    
    %# normalize the line vector
    lineVecN = lineVec / sqrt(sum(lineVec.^2));
    
    %# find the distance from each point to the line:
    %# vector between all points and first point
    vecFromFirst = bsxfun(@minus, allCoord, firstPoint);
    
    %# To calculate the distance to the line, we split vecFromFirst into two 
    %# components, one that is parallel to the line and one that is perpendicular 
    %# Then, we take the norm of the part that is perpendicular to the line and 
    %# get the distance.
    %# We find the vector parallel to the line by projecting vecFromFirst onto 
    %# the line. The perpendicular vector is vecFromFirst - vecFromFirstParallel
    %# We project vecFromFirst by taking the scalar product of the vector with 
    %# the unit vector that points in the direction of the line (this gives us 
    %# the length of the projection of vecFromFirst onto the line). If we 
    %# multiply the scalar product by the unit vector, we have vecFromFirstParallel
    scalarProduct = dot(vecFromFirst, repmat(lineVecN,nPoints,1), 2);
    vecFromFirstParallel = scalarProduct * lineVecN;
    vecToLine = vecFromFirst - vecFromFirstParallel;
    
    %# distance to line is the norm of vecToLine
    distToLine = sqrt(sum(vecToLine.^2,2));
    
    %# plot the distance to the line
    figure('Name','distance from curve to line'), plot(distToLine)
    
    %# now all you need is to find the maximum
    [maxDist,idxOfBestPoint] = max(distToLine);
    
    %# plot
    figure, plot(curve)
    hold on
    plot(allCoord(idxOfBestPoint,1), allCoord(idxOfBestPoint,2), 'or')
    knee_val = allCoord(idxOfBestPoint,2);
end