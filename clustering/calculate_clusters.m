function [idx, clusterids]= calculate_clusters(dataset,plotClusters,feat_labels,min_points,max_points)
arguments
    dataset
    plotClusters = 0
    feat_labels = 0
    min_points = 0
    max_points = 0
end
    [~,feat_num] = size(dataset);
    if min_points==0
        min_points = feat_num;
    end

    if max_points==0
        max_points = min_points*2;
    end
%     clusterDBSCAN.estimateEpsilon(dataset,min_points,min_points*2);
    epsilon = clusterDBSCAN.estimateEpsilon(dataset,min_points,max_points);
    clusterer = clusterDBSCAN('MinNumPoints',min_points,'Epsilon',epsilon);
    [idx,clusterids] = clusterer(dataset);

    % Plot result of clustering
    if plotClusters == 1 && ~isnumeric(feat_labels)
        feat_len = length(dataset(1,:));
        if feat_len > 3
            colors = {'red','green','blue','magenta','black','cyan'};
            if feat_len == 4
                feat_combs = [[1,2,3];[1,2,4];[2,3,4];[3,4,1]];
            else
                feat_combs = [[1,2,3];[1,2,4];[2,3,4];[3,4,1];[1,2,5];[1,3,5];[1,4,5];[3,4,5]];
            end
            for comb_ind = 1:length(feat_combs(:,1))
                feat_ind = feat_combs(comb_ind,:);
                figure
                grid on
                for id_ind = 1:length(unique(idx(idx~=-1)))
                    scatter3(dataset(find(id_ind==idx),feat_ind(1)),dataset(find(id_ind==idx),feat_ind(2)),dataset(find(id_ind==idx),feat_ind(3)),5,colors{id_ind},'filled')
                    xlabel(feat_labels{feat_ind(1)})
                    ylabel(feat_labels{feat_ind(2)})
                    zlabel(feat_labels{feat_ind(3)})
                    hold on
                end
                hold off
            end
            % create a 4 x 4 matrix of plots
        else
            plot(clusterer,dataset,idx)
        end
    end
end