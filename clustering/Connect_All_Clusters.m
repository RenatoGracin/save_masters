function [new_connected_clusters,searched_clusters] = Connect_All_Clusters(searched_clusters,clust_id,sameClusts)
    connected_clusters = find(sameClusts(clust_id,:)==1);
    searched_clusters = [searched_clusters,clust_id];
    new_connected_clusters = connected_clusters;
    for conn_clust_ind = 1:length(connected_clusters)
        conn_clust_id = connected_clusters(conn_clust_ind);
        if ~ismember(searched_clusters,conn_clust_id) 
            [ret_connected_clusters,searched_clusters] = Connect_All_Clusters(searched_clusters,conn_clust_id,sameClusts);
            new_connected_clusters = unique([new_connected_clusters,ret_connected_clusters]);
        end
    end
end