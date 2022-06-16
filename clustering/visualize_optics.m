clear all
close all
points = [3,1; 3,2; 3,3; 2,1; 2,2; 2,3; 1,1; 1,2; 1,3];
x = points(:,2);
y = points(:,1);

x = [x; x+5];
y = [y; y+5];

for point_ind = 1:length(x)
    labels{point_ind} = num2str(point_ind);
end
data = [x,y];
max_eps = Inf;
min_points = 20;
[order,reach_dist,core_dist] = my_optics(data, max_eps,min_points);

plot(reach_dist(order));
eps_lower = 3;
idx = my_extract_DBSCAN_clust(data,reach_dist(order),core_dist,eps_lower,min_points);
show_3D_clustering(data,idx);

figure;
grid on
scatter(x,y,10,"blue","filled","o");
% txt = text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
xlim([0,10]);
ylim([0,10]);
reach_dist(reach_dist==-1) = 10;

% bar(reach_dist(order))
origin_ind = 8;
for ind = 1:length(x) 
%     line([x_first,x_second],[y_first,y_second])
    xlab = x(origin_ind) - ((x(origin_ind)-x(ind))/2);
    ylab = y(origin_ind) - ((y(origin_ind)-y(ind))/2);
    text(x(ind),y(ind),num2str(calc_distance([x(origin_ind),y(origin_ind)],[x(ind),y(ind)])),"FontSize",7);
end

figure;
grid on
scatter(x,y,10,"blue","filled","o");
title("core distances")
origin_ind = 8;
for ind = 1:length(x) 
    text(x(ind),y(ind),num2str(core_dist(ind)),"FontSize",7);
end

data = [x,y];
data_ind = 1:length(x);
point_ind = 1;
while ~isempty(data_ind)
    distances = zeros(1,length(x));
    for other_ind = 1:length(x)
        if other_ind == point_ind
            distances(other_ind) = Inf;
        else
            distances(other_ind) = calc_distance(data(point_ind,:),data(other_ind,:));
        end
    end
    all_reach_dist = 0;
    cd = core_dist';
    all_reach_dist = max(distances,core_dist');
%     all_reach_dist(point_ind) = [];
%     all_reach_dist(point_ind+1:end) = [];
    [best_reach_dist, new_point_ind] = min(all_reach_dist(data_ind));
    if isempty(all_reach_dist)
        new_reach_dist(point_ind) = -1;
    else    
        new_reach_dist(point_ind) = best_reach_dist;
    end
    point_ind = new_point_ind;
    data_ind(point_ind) = [];
end

function distance = calc_distance(data1,data2)
    distance = sqrt(sum((data1-data2).^2));
end