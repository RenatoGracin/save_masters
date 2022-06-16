function dunn_index = Calc_Dunn_Index(dataset, cluster_ind)
    all_len = length(cluster_ind);
    outliers_len = length(cluster_ind(cluster_ind==-1));
%     cluster_ind(cluster_ind==-1) = [];

    cluster_ids = unique(cluster_ind(cluster_ind~=-1));
    cluster_id_len = length(cluster_ids);

    if cluster_id_len < 2
        dunn_index = 0;
        return;
    end

    
    feat_len = length(dataset(1,:));
    cluster_centroids = zeros(cluster_id_len,feat_len);
    cluster_intradist = zeros(cluster_id_len,1);

    %% 0) Seperate clusters into cluster_data
    for id_ind = 1:cluster_id_len
        cluster_data = dataset(cluster_ind==cluster_ids(id_ind),:);
        cluster_centroids(id_ind,:) = mean(cluster_data);
        cluster_intradist(id_ind) = mean(pdist2(cluster_data, cluster_centroids(id_ind,:)));
    end

    %% Plots single cluster centroid to check
%     figure
%     hold on
%     scatter(dataset(:,3),dataset(:,2),4,'blue','filled','diamond')
%     plot(cluster_means{2}(3),cluster_means{2}(2),'rx','LineWidth',4,'MarkerSize',10)
%     grid on 
    
    %% 3) Compute the interset distances between clusters, and find the minimum of these distances
    %% Dij - i and j are cluster indices

    cluster_interdist = pdist(cluster_centroids);
    % Locate which distance pair is it
%     cluster_interdist = squareform(cluster_interdist);
    %% Check cluster distances
%     dist_12 = sqrt(sum((cluster_means{1}-cluster_means{2}).^2));
%     if dist_12 == Z(1,2)
%         disp('Correct calculaton');
%     end
    
    dunn_index = max((cluster_intradist))/min(cluster_interdist,[],"all");
%     dunn_index = dunn_index * abs(all_len-outliers_len)/all_len;
end