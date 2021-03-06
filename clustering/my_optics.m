%% Based on OPTICS algorithm described in: https://sci-hub.se/10.1145/304181.304187
function [order, reach_dist, core_dist] = my_optics(data,max_eps,min_points)
    data = OpticsData(data);
    for data_ind = 1:length(data.dataset(:,1))
        % If data point wasn't processed
        if data.processed(data_ind) == -1
            expand_cluster_order(data,data_ind,max_eps,min_points)
        end
    end
    order = data.ordered_list;
    reach_dist = data.reach_distances;
    %% Set reachability distance of undefined to bi bigger then other reachability distances
    reach_dist(reach_dist==-1) = max(reach_dist);
    core_dist = data.core_distances;
end

function expand_cluster_order(data,data_ind,max_eps,min_points)
arguments
    data OpticsData
    data_ind (1,1)
    max_eps (1,1)
    min_points (1,1)
end

    neighbors_ind = get_neighbours(data.dataset,data_ind,max_eps);
    data.processed(data_ind) = 1;
    

    %% If point Core distance was not already calculated
    if data.core_distances(data_ind) == -1
        calc_core_distance(data,data_ind,neighbors_ind,min_points);
    end

    data.ordered_count= data.ordered_count + 1;
    data.ordered_list(data.ordered_count) = data_ind;

    %% If point is a Core point
    if data.core_distances(data_ind) ~= -1
        data.ordered_seeds = [];
        data.seed_count = 0;
        update(data,neighbors_ind,data_ind)
        while(~isempty(data.ordered_seeds))
            %% Sort seeds by ascending reachability distance
            [~,sorted_seed_ind] = sort(data.reach_distances(data.ordered_seeds(1:data.seed_count)));
            data.ordered_seeds= data.ordered_seeds(sorted_seed_ind);
            
            %% Choose point with lowest reachability distance
            curr_data_ind = data.ordered_seeds(1);
            %% Remove processed point from seed list
            data.ordered_seeds = data.ordered_seeds(2:end);
            data.seed_count = data.seed_count - 1;
            
            curr_neighbors_ind = get_neighbours(data.dataset,curr_data_ind,max_eps);
            data.processed(curr_data_ind) = 1;
           
            %% If point Core distance was not already calculated
            if data.core_distances(curr_data_ind) == -1
                calc_core_distance(data,curr_data_ind,curr_neighbors_ind,min_points);
            end
            
            data.ordered_count= data.ordered_count + 1;
            data.ordered_list(data.ordered_count) = curr_data_ind;

            if data.core_distances(curr_data_ind) ~= -1
                update(data,curr_neighbors_ind,curr_data_ind)
            end
        end
    end
end

function update(data,neighbors_ind,data_ind)
    arguments
        data OpticsData
        neighbors_ind
        data_ind
    end
    data_point = data.dataset(data_ind,:);
    core_dist = data.core_distances(data_ind);
    %% Mo??e?? dodat od minpoinnts: 
    for neigh_ind = 1:length(neighbors_ind)
        %% If neighbour wasn't processed
        if data.processed(neighbors_ind(neigh_ind)) == -1
            neighbour_point = data.dataset(neighbors_ind(neigh_ind),:);
            new_reach_dist = max([core_dist, calc_distance(data_point,neighbour_point)]);
            %% If reachability distance wasn't defined
            if data.reach_distances(neighbors_ind(neigh_ind)) == -1
                data.reach_distances(neighbors_ind(neigh_ind)) = new_reach_dist;
                %% Insert reachability distance into seeds
                data.seed_count = data.seed_count + 1;
                data.ordered_seeds(data.seed_count) = neighbors_ind(neigh_ind);
            else
                %% If new reachability distance is lower
                if new_reach_dist < data.reach_distances(neighbors_ind(neigh_ind))
                    data.reach_distances(neighbors_ind(neigh_ind)) = new_reach_dist;
                    %% Update reachability distance from seeds
                    %%%%%%%%%%%%%%
                end
            end
        end

    end
end

function core_distance = calc_core_distance(data,data_ind,neighbors_ind,min_points)
arguments
    data OpticsData
    data_ind
    neighbors_ind
    min_points
end
    %% If point isn't a Core point then core distance is undefined (-1)
    if length(neighbors_ind) < min_points-1
        core_distance = -1;
    %% If point is Core point then core distance is distance from 
    else
        distances = zeros(1,length(neighbors_ind));
        for neigh_ind = 1:length(neighbors_ind)
            distances(neigh_ind) = calc_distance(data.dataset(data_ind,:),data.dataset(neighbors_ind(neigh_ind),:));
        end
        distances = sort(distances);
        data.core_distances(data_ind) = distances(min_points-1);
%         data.core_distances(data_ind) = calc_distance(data.dataset(data_ind,:),data.dataset(neighbors_ind(min_points-1),:));
    end
end

function [neighbors_ind] = get_neighbours(data,center_data_ind,distance_limit)
    neighbors_amount = 0;
    neighbors_distance = 0;
    neighbors_ind = 0;
    for data_ind = 1:length(data(:,1))
        %% Skip distance calculation between self
        if data_ind == center_data_ind
            continue;
        end
        distance = calc_distance(data(center_data_ind,:),data(data_ind,:));
        if  distance <= distance_limit
            neighbors_amount = neighbors_amount + 1;
            neighbors_distance(neighbors_amount) = distance;
            neighbors_ind(neighbors_amount) = data_ind;
        end
    end
    %% Sort neighbours by distance from center point in ascending order
%     [~,sorted_ind] = sort(neighbors_distance);
%     neighbors_ind = neighbors_ind(sorted_ind); 
end

%% Calculates euclidian distance between data1 and data2
function distance = calc_distance(data1,data2)
    distance = sqrt(sum((data1-data2).^2));
end