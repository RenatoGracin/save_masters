function [cluster_ids] = my_extract_DBSCAN_clust(data,reach_dist,core_dist,eps_lower,min_points)
    cluster_id = 1;
    data_len = length(data(:,1));
    cluster_ids = zeros(1,data_len);
    for data_ind = 1:data_len
        data_point = data(data_ind,:);
        %% Undefined should be bigger than epsilon (Set Inf)
        if reach_dist(data_ind) > eps_lower
            if core_dist(data_ind) <= eps_lower
                cluster_id = cluster_id+1;
                cluster_ids(data_ind) = cluster_id;
            else
                cluster_ids(data_ind) = -1;
            end
        else
            cluster_ids(data_ind) = cluster_id;
        end
    end

end

