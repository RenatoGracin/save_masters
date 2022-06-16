% Brief Demo to Visualise Optics Results

% Written by Alex Kendall
% University of Cambridge
% 18 Feb 2015
% http://mi.eng.cam.ac.uk/~agk34/

% This software is licensed under GPLv3, see included glpv3.txt.

% ::IMPORTANT:: load your data to 'points'. Here is some example data:
% load('example_data.mat');
dataset_name = 'small_dataset';
load(['../input_matrices/' dataset_name '_stand_feature_matrix.mat']);
addpath('../');
points = dataset(:,[11,18,19]);
minpts = 11;
epsilon = Inf;

% epsilon = clusterDBSCAN.estimateEpsilon(points,minpts,minpts*3);
[ SetOfClusters, RD, CD, order ] = cluster_optics(points, minpts, epsilon);

bar(RD(order));
figure;
labels = zeros(1,length(points(:,1)));
for i=1:length(SetOfClusters)
    labels(SetOfClusters(i).start:SetOfClusters(i).end) = i;
end

show_3D_clustering(points,labels);


% Cycle through all clusters
for i=2:length(SetOfClusters)
    bar(RD(order(SetOfClusters(i).start:SetOfClusters(i).end)));
%     pause(0.5)
end