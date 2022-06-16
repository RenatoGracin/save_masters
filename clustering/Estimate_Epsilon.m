%% link to link: https://towardsdatascience.com/machine-learning-clustering-dbscan-determine-the-optimal-value-for-epsilon-eps-python-example-3100091cfbc
%% link: https://iopscience.iop.org/article/10.1088/1755-1315/31/1/012012/pdf
function estimate_eps = Estimate_Epsilon(data,Nmin)
    distances = pdist2(data,data);
    sorted_distances = sort(distances,2);
    sorted_distances = sorted_distances(2:end,:); % distances
    knn_distances = sort(mean(sorted_distances(:,1:Nmin),2));
    x = 1:length(knn_distances);
    knn_distances_real = knn_distances;
    knn_distances = (knn_distances-min(knn_distances))/(max(knn_distances)-min(knn_distances));
    x = (x-min(x))/(max(x)-min(x));

    points = [x',knn_distances];
    line_x_dist = points(end,1)-points(1,1);
    line_knn_dist = points(end,2)-points(1,2);
    numerator = abs( line_x_dist.*(points(1,2)-points(:,2)) - (points(1,1)-points(:,1)).*line_knn_dist );
    denominator = sqrt(line_x_dist ^ 2 + line_knn_dist ^ 2);
    distance = numerator ./ denominator;

    [~,eps_ind] = max(distance);
    estimate_eps = knn_distances_real(eps_ind);

%     plot(x,knn_distances);
%     hold on
%     plot(x(eps_ind),knn_distances(eps_ind),'Marker','x','MarkerSize',10,'Color','r','LineWidth',2);
end