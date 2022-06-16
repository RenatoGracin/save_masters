% load '../clustering/input_matrices/small_dataset_stand_feature_matrix.mat'
% 
% data = dataset(:,[11,18,19]);

num_of_points = 400;
data1 = rand(ceil(num_of_points/3),3)*3+14;
data2 = rand(floor(num_of_points/3),3)*3+7;
data3 = rand(floor(num_of_points/3),3)*3;

hold on
scatter3(data1(:,1),data1(:,2),data1(:,3),5,"black","filled",'o');
scatter3(data2(:,1),data2(:,2),data2(:,3),5,"green","filled",'o');
scatter3(data3(:,1),data3(:,2),data3(:,3),5,"blue","filled",'o');

data = [data1; data2; data3];

scatter3(data(:,1),data(:,2),data(:,3),5,"blue","filled",'o');

% writematrix(data(:,1),'..\C_code_testing\feat1.txt')
% writematrix(data(:,2),'..\C_code_testing\feat2.txt')
% writematrix(data(:,3),'..\C_code_testing\feat3.txt')

pathToScript = fullfile(pwd,'reafactor_feats.sh');  % assumes script is in curent directory
system(pathToScript);

Nmin = 3;
eps = 1.1;
idx = optics_with_clustering(data,Nmin,eps);
idx(idx==0) = -1;
show_3D_clustering(data,idx);


idx_other=importdata('labels.txt');
idx_other(idx_other==0) = -1;
show_3D_clustering(data,idx_other);

disp("Done");