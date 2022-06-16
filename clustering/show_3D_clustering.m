function show_3D_clustering(dataset,idx,figure_exist)
arguments
    dataset
    idx
    figure_exist = 0
end
    clust_ids = unique(idx);

    colors = parula(length(clust_ids*3)); % more different colors. %jet
    %% Randomize colors
    colors = colors(randperm(length(colors(:,1))),:);
    colors = [[1,0,0];[0.2,0.8,1.00];[1,1,0];[0,1,0];[1,0,1];[0,0,0];[0,1,1];[0.64,0.08,0.18];[1.00,0.41,0.16];[0.93,0.69,0.13];...
        [0.8,0.3,0.5];[0.8,0.1,0];[0.4,1,0.4];[0.23,0,0.23];[1,0.55,0];[0.5,0.9,0.9];[0.1,0.3,0.5];[0.3,0.2,1]];
    %% Remove red color beacuse it is reserved for outliers
%     for row_ind = 1:length(colors(:,1))
%         if colors(row_ind,:) == [1,0,0]
%             colors(row_ind,:) = [0.5,0.5,0.5];
%         end
%     end
     
    if figure_exist == 0
       figure;
    end
    grid on

    for id_ind = 1:length(clust_ids)
        cluster_data = dataset(idx==clust_ids(id_ind),:);
%         Color outliers red
        if clust_ids(id_ind) == -1
            colors(id_ind,:) = [1,0,0];
        end
        feat_len = length(dataset(1,:));
        if feat_len == 3
            scatter3(cluster_data(:,1),cluster_data(:,2),cluster_data(:,3),10,colors(mod(id_ind,length(colors)+1),:),'filled','Tag',['cluster' num2str(clust_ids(id_ind))])
        elseif feat_len == 2
            scatter(cluster_data(:,1),cluster_data(:,2),10,colors(mod(id_ind,length(colors)),:),'filled','Tag',['cluster' num2str(clust_ids(id_ind))])
        else
            disp('Error: Number of features is invalid!')
        end
        legend_str{id_ind} = ['cluster' num2str(clust_ids(id_ind))];
        hold on
    end
    legend(legend_str);
end

