load '../clustering/input_matrices/small_dataset_stand_feature_matrix.mat'

data = dataset(:,[11,18,19]);
writematrix(data,'..\C_code\input_data.txt')

Nmin = 14;
eps = 0.02;

idx = optics_with_clustering(data,Nmin,eps);
idx(idx==0) = -1;
show_3D_clustering(data,idx);

% optics_by_block(data,Nmin,eps,boxSize,crosPointNum)
clust_ids = unique(idx(idx>0));
hold on;
for clust_num = 1:length(clust_ids)
    clust_data = data(idx==clust_ids(clust_num),:);
%     scatter3(clust_data(:,1),clust_data(:,2),clust_data(:,3),5,"black","filled",'o');
    x_r = abs(max(clust_data(:,1))-min(clust_data(:,1)))/2;
    y_r = abs(max(clust_data(:,2))-min(clust_data(:,2)))/2;
    z_r = abs(max(clust_data(:,3))-min(clust_data(:,3)))/2;

    x_c = min(clust_data(:,1))+x_r;
    y_c = min(clust_data(:,2))+y_r;
    z_c = min(clust_data(:,3))+z_r;
    
    plot3(x_c,y_c,z_c,'x','Color','r','LineWidth',1.5)

    [X,Y,Z] = ellipsoid(x_c,y_c,z_c,x_r,y_r,z_r);
    s = surf(X,Y,Z);
    origin = [x_c,y_c,z_c];
    rotate(s,origin,45)
    
end
[X,Y,Z] = ellipsoid(xc,yc,zc,xr,yr,zr);
optics_by_block(data,Nmin,eps,300,200)
idx(idx==0) = -1;
show_3D_clustering(data,idx);

idx_other=importdata('labels.txt');
idx_other(idx_other==0) = -1;
show_3D_clustering(data,idx_other);

disp('Done')