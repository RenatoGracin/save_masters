%% link to link: https://towardsdatascience.com/machine-learning-clustering-dbscan-determine-the-optimal-value-for-epsilon-eps-python-example-3100091cfbc
%% link: https://iopscience.iop.org/article/10.1088/1755-1315/31/1/012012/pdf
function estimate_eps = My_Estimate_Epsilon(data,Nmin)
    distances = pdist2(data,data);
    sorted_distances = sort(distances,2);
    sorted_distances = sorted_distances(2:end,:); % distances
    knn_distances = sort(mean(sorted_distances(:,1:Nmin),2));
    
    norm_knn_dist = normalize(knn_distances,1,"range");
    norm_x = normalize([1:length(knn_distances)]',1,"range");

    figure;
    plot(norm_x,norm_knn_dist)
    figure;
    plot(1:length(knn_distances),knn_distances)
    
    slopes = [];
    for i = 1:length(knn_distances)-1
        x1 = norm_x(i);
        y1 = norm_knn_dist(i);
        x2 = norm_x(i+1);
        y2 = norm_knn_dist(i+1);
    
        slope = (y2-y1)/(x2-x1);
    
        slopes = [slopes,slope];
    end
    figure;
    plot(slopes);
    estimate_eps= knn_distances(min(find(slopes > max(slopes)*0.01)));
end


