function clust_intersection_perc = Intersect_All_Labels(all_labels)
    for labels_i_ind = 1:length(all_labels)
        labels_i = all_labels{labels_i_ind};
        u_labels_i = unique(labels_i);
        for clust_i_id = 1:length(u_labels_i)
            clusters_i{clust_i_id} = find(labels_i==u_labels_i(clust_i_id));
        end

        for labels_j_ind = labels_i_ind+1:length(all_labels)
            labels_j = all_labels{labels_j_ind};

            disp(['Intersection between rank ' num2str(labels_i_ind) ' and rank ' num2str(labels_j_ind) ' :']);

            clust_intersection_perc{labels_i_ind,labels_j_ind} =  [];
            u_labels_j = unique(labels_j);
            for clust_i_id = 1:length(u_labels_i)
                clust_i_intersect = [];
                for clust_j_id = 1:length(u_labels_j)
                    clusters_j = find(labels_j==u_labels_j(clust_j_id));
                    clust_i_len = length(clusters_i{clust_i_id});
                    clust_j_len = length(clusters_j);

                    larger_len = max([clust_i_len,clust_j_len]);
                    clust_i_intersect = [clust_i_intersect, length(intersect(clusters_i{clust_i_id},clusters_j))/larger_len];
                end
                clust_intersection_perc{labels_i_ind,labels_j_ind} = [clust_intersection_perc{labels_i_ind,labels_j_ind}; clust_i_intersect];
            end
            disp(clust_intersection_perc{labels_i_ind,labels_j_ind});
        end
    end

end