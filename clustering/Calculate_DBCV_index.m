%% Function to calculate validity index for density-based clustering algorithms called Density-Based Clustering Validity (DBCV) 
%% Reference: [1] Moulavi, D., Jaskowiak, P. A., Campello, R. J. G. B., Zimek, A., & Sander, J. (2014). 
%%            Density-Based Clustering Validation. Proceedings of the 2014 SIAM International Conference on Data Mining,
%%            839–847. doi:10.1137/1.9781611973440.96 
%% link: https://sci-hub.se/10.1137/1.9781611973440.96
function DBCV_index = Calculate_DBCV_index(data,labels,outliers_len,check_holes)
%% Arguments:
%% data - NxP data matrix (dataset) with N observations (points) and P features that describe each point 
%%      - doesn't contain outliers only valid points
%% labels - 1xN vector containing cluster labels for each data observation (point)
%% outliers_len - integer describing number of outliers (data points that lie outside of most of the other values in the dataset)
    %% If valid data is empty return lowest index value.
    arguments
        data
        labels
        outliers_len
        check_holes = 0
    end
    
    global check_holes
    if isempty(data)
        DBCV_index = -1;
        return;
    end

    [data_len,feat_len] = size(data); % Calculate number of points and features in the dataset
    unique_labels = unique(labels); % Get all unique cluster labels
    clust_num = length(unique_labels); % Calculate number of clusters in the dataset

    %% 1)-5) Calculate density sparseness for each cluster clust_i
    for clust_i = 1:clust_num
        clust_indices = find(unique_labels(clust_i)==labels); % Get data indices of cluster clust_i
        data_clust{clust_i} = data(clust_indices,:); % Get data points of cluster clust_i
        clust_len = length(data_clust{clust_i}(:,1)); % Get number of points in cluster clust_i

        %% 1) Calculate all-points-Core-distance for each point in clust_i
        %%    All-points-core-distance is defined with regards to all other points in the same cluster.
        clust_distances = pdist2(data_clust{clust_i},data_clust{clust_i},'euclidean'); % Calculates distance between each point in cluster clust_i
        for data_ind = 1: clust_len
            %% Get distance from data_ind to all other points in cluster clust_i and sort by ascending value
            all_dist_sorted = sort(clust_distances(data_ind,:));
            %% Remove distance to self
            all_dist_sorted(all_dist_sorted==0) = []; % all_dist_sorted(1) = [];
            %% Calculate all-points-core-distance of point clust_i based on DEFINITION 1 from [1]
            a_pts_core_dist{clust_i}(data_ind) = (sum((1./all_dist_sorted).^feat_len)/(clust_len-1))^(-1/feat_len);
        end

        %% 2) Calculate Mutual Reachability distances for each point pair in cluster clust_i
        % Calculate matrix which rows are vectors od core distances of points from cluster clust_i from first point to last
        core_dist_row_par = repmat(a_pts_core_dist{clust_i}, clust_len,1);
        % Calculate matrix which columns are vectors od core distances of points from cluster clust_i from first point to last
        core_dist_col_par = repmat(a_pts_core_dist{clust_i}',1, clust_len);
        % Calculates maximum of core distances for each point pair in clust_i
        core_dist_pair_max = max(core_dist_row_par,core_dist_col_par);
        %% Remove diagonal data if necessary
%         core_dist_pair_max(core_dist_pair_max==0) = [];

        % Calculates maximum of distance between point pair and maximum of
        % core distances of point pair for each point pair in cluster clust_i
        % Based on DEFINITION 2 from [1]
        % Gets mutual reachability distance matrix in which rows and columns represent each point from first to last
        mutual_reach_dist= max(core_dist_pair_max,clust_distances);

        %% 3) Calculate Mutual Reachability Distance Graph as graph with data point as vertices (nodes) and
        %%    the mutual reachability distance between the respective pair of points as the weight of each edge
        % Based on DEFINITION 3 from [1]
        tree = graph(mutual_reach_dist,string([1:clust_len])); % Name each node as it's index

        %% 4) Calculate Minimum spanning tree for Mutual Reachability distances graph of cluster clust_i
        % Based on DEFINITION 4 from [1]
        [MST_mrd,~] = minspantree(tree);

        %% Get internal nodes and edges of MST - internal nodes are nodes connected on both sides or nodes with degree bigger than 1
        MST_mrd_internal{clust_i} = rmnode(MST_mrd, string(find(degree(MST_mrd)<2))); % Remove leaf nodes from MST_mrd
       

        %% If there are no internal nodes, keep all the leaf nodes
        if MST_mrd_internal{clust_i}.numedges < 1
            MST_mrd_internal{clust_i} = MST_mrd;
        end
        

        % Show minimum spanning tree graph
        if clust_len/data_len >= 0.8 && 0
            internal_nodes = str2double(table2array( MST_mrd_internal{clust_i}.Nodes))';
            figure;
            hold on
            scatter3(data(:,1),data(:,2),data(:,3),5,'green','filled')
            scatter3(data_clust{clust_i}(:,1),data_clust{clust_i}(:,2),data_clust{clust_i}(:,3),5,'blue','filled')
            scatter3(data_clust{clust_i}(internal_nodes,1),data_clust{clust_i}(internal_nodes,2),data_clust{clust_i}(internal_nodes,3),5,'red','filled')
            p = plot( MST_mrd_internal{clust_i}, 'XData',data_clust{clust_i}(internal_nodes,1),'YData',data_clust{clust_i}(internal_nodes,2),'ZData',data_clust{clust_i}(internal_nodes,3)); 
    %         plot( MST_mrd, 'XData',data_clust{clust_i}(:,1),'YData',data_clust{clust_i}(:,2),'ZData',data_clust{clust_i}(:,3)); 
            p.EdgeColor = [1.0,0.0,0.0];
            p.NodeColor = [1.0,0.0,0.0];
            p.LineWidth = 2;
        end
        % Show DSC calc
%         [~,conn_ind] = max(MST_mrd_internal{clust_i}.Edges.Weight);
%         max_end_nodes =  MST_mrd_internal{clust_i}.Edges.EndNodes(conn_ind,:);
%         first_node = str2num(max_end_nodes{1});
%         second_node = str2num(max_end_nodes{2});
%         show_3D_clustering(data,labels);
%         hold on;
%         scatter3(data_clust{clust_i}(first_node,1),data_clust{clust_i}(first_node,2),data_clust{clust_i}(first_node,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%         scatter3(data_clust{clust_i}(second_node,1),data_clust{clust_i}(second_node,2),data_clust{clust_i}(second_node,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')

        %% 5) Calculate density sparseness of cluster (DSC) clust_ind
        % Based on DEFINITION 5 from [1]
        % The density sparseness of a single cluster is defined as the maximum edge of its corresponding MST_mrd_internal,
        % which can be interpreted as the area with the lowest density inside the cluster
%         DSC(clust_i) = max(MST_mrd_internal{clust_i}.Edges.Weight);

        %% 6) Find holes in dataset that indicate bad clustering
        hole_punish = 0; %% Value to add to DSC of cluster tu punsih it when it contains holes

        % Find holes only for clusters that contain more than 50% of points in dataset
        if clust_len/(data_len+outliers_len) >= 0.8
            %% Calculate density sparseness of cluster by finding least dens points between internal node
            %% Points between each start and end pair of connected internal nodes are called mid points.
            %% Density of mid point is calculated as mean distance to 10 nearest neighbor points in cluster
           
            %% Remove leaf nodes because they interfere when finding holes
            internal_nodes = str2double(table2array( MST_mrd_internal{clust_i}.Nodes))';
            MST_mrd_deep = rmnode(MST_mrd_internal{clust_i}, string(internal_nodes(find(degree(MST_mrd_internal{clust_i})<2)))); % Remove leaf nodes from MST_mrd
       
            %% If there are no internal nodes, keep all the leaf nodes
            if MST_mrd_deep.numedges < 1
                MST_mrd_deep = MST_mrd_internal{clust_i};
            end

            MST_mrd_deep = MST_mrd_internal{clust_i};

            %% Plot new MST
            if check_holes || 1
                internal_nodes = str2double(table2array( MST_mrd_deep.Nodes))';
                figure;
                hold on
                scatter3(data(:,1),data(:,2),data(:,3),5,'green','filled')
                scatter3(data_clust{clust_i}(:,1),data_clust{clust_i}(:,2),data_clust{clust_i}(:,3),5,'blue','filled')
                scatter3(data_clust{clust_i}(internal_nodes,1),data_clust{clust_i}(internal_nodes,2),data_clust{clust_i}(internal_nodes,3),5,'red','filled')
                p = plot( MST_mrd_deep, 'XData',data_clust{clust_i}(internal_nodes,1),'YData',data_clust{clust_i}(internal_nodes,2),'ZData',data_clust{clust_i}(internal_nodes,3)); 
        %         plot( MST_mrd, 'XData',data_clust{clust_i}(:,1),'YData',data_clust{clust_i}(:,2),'ZData',data_clust{clust_i}(:,3)); 
                p.EdgeColor = [1.0,0.0,0.0];
                p.NodeColor = [1.0,0.0,0.0];
                p.LineWidth = 2;
            end
    
            %% For 15 least dense mid points are potential holes that is a low density area souranded by high density area
            %% To measure if area around hole is high density it must be 65% more dense on all sides of cluster than midpoint density
            %% That means by making 5 steps thorugh nodes from both start and end node i must find a node on  65% more dense than mid point
            number_of_holes = 10; % Search 15 least densest mid points because it is regular minimum cluster size 
            [hole_start_nodes,hole_end_nodes,hole_points,hole_density] = Get_Hole_by_MidNodes(MST_mrd_deep,data_clust{clust_i},number_of_holes);
            
            if ~isempty(hole_end_nodes)
                %% Potential holes are then checked if they satisfy condition for holes in cluster:
                %% 1) Removing edge that connects start and end point of mid point od potential hole should split MST into 2 or more "large" trees.
                %%    If removing edge split MST on only one "large" tree it means it is an "outer" point on the edge of cluster.
                %%    "Large" trees are defined as trees with 15 or more nodes. Before calculating tree size the trees are expanded by all points not in tree so each non node point in cluster is connected to nearest node in MST. 
                %% 2) Impact of Hole should be 15 or more. Impact of hole is how many points it is closest to than internal nodes and mid points in cluster.
                %%
                %% Search for holes i limited to 10 holes beacuse clusters usually contain a lot less (1-4).
                [internal_neigh] = Get_Internal_Nodes_Impact(MST_mrd_deep,data_clust{clust_i});
                %% Calculates how many points are closest to hole point than other internal nodes
                [hole_neigh] = Get_Hole_Nodes_Impact(MST_mrd_deep,data_clust{clust_i},hole_start_nodes,hole_end_nodes,hole_points);
        
                %% Detect hole points
                search_num_of_points = 10;
                hole_count = 0;
                for i = 1:length(hole_points(:,1))
                    hole_start_node = hole_start_nodes(i);
                    hole_end_node = hole_end_nodes(i);
        
                    %% Calculate impact of removing edge/node
                    trees = rmedge(MST_mrd_deep,num2str(hole_start_node),num2str(hole_end_node));
                    [tree_ids,min_tree_sizes] = conncomp(trees);
        
                    %% Add impact of all connected nodes in tree
                    u_tree_ids = unique(tree_ids);
                    for tree_id = 1:length(u_tree_ids)
                        tree_bin_mask = u_tree_ids(tree_id)==tree_ids;
                        tree_nodes = find(tree_bin_mask>0);
                        tree_sizes(tree_id) = sum(internal_neigh(tree_nodes));
                    end
                    
                    if check_holes
                        disp('Tree sizes: ');
                        disp(tree_sizes);
                    end

                    %% If potenitial hole splits cluster into multiple trees each with more than 15 points it is a HOLE
                    %% Also impact of Hole should be less than 15
                    if sum(tree_sizes>15) > 1 && hole_neigh(i) < 15
                        hole_count = hole_count+1;
                        scatter3(hole_points(i,1),hole_points(i,2),hole_points(i,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
                        %% Nodes in cluster that belong to the longest tree - represents valid part of cluster
                        %% Nodes in cluster that don't belong to the longest tree (split from node) - invalid part of cluster
                        %% Calculate percentage of invalid part of cluster in cluster
                        discarded_perc = ((clust_len-1)-max(tree_sizes))/(clust_len-1);
                        %% Punish factor is percentage of valid part of cluster in cluster
                        %% multiplied by 2 that many times as invalid percentage of cluster contains 5% of data
                        %% also multiplied by hole density
                        hole_punish = hole_punish + hole_density(i) * ((clust_len-1)/max(tree_sizes)) * 2^floor(discarded_perc/0.05);
                        %% Punish more bigger splits of clusters by adding invalid part of cluster divided by 200 
                        %% Which means for every 200 points in invalid part of cluster a punish factor is incremented by 1
                        hole_punish = hole_punish + floor(((clust_len-1)-max(tree_sizes))/200);
                        %% When limit number od hole points are found, stop the search
                        if search_num_of_points == hole_count
                            break;
                        end
                    else
                        scatter3(hole_points(i,1),hole_points(i,2),hole_points(i,3),100,'red','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
                    end
                end
            end
        end

        %% DSC with no holes inside cluster uses mean of all internal nodes density so low density outliers don't affect result.
        %% DSC with holes just adds hole punishment to previous calculation.
        [lowest_density_nodes_clust_i,lowest_density_points,lowest_densities] = Get_Hole_by_Nodes(MST_mrd_internal{clust_i},data_clust{clust_i});
        lowest_density_nodes{clust_i} = lowest_density_nodes_clust_i; %% Save 1% of lowest density internal nodes
        DSC(clust_i) = mean(lowest_densities) + hole_punish;
    end

    % Index cannot calculate density separation if it has only 1 cluster
    if clust_num < 2
        DBCV_index = -1*(DSC(1))*(outliers_len./(clust_len+outliers_len)); % set index to density sparseness of cluster
        return;
    end


    %% 6) Calculate density separation for each cluster pair (DSPC) clust_i and clust_j
    % Based on DEFINITION 6 from [1]
    DSPC = zeros(clust_num,clust_num); % Density separation matrix
    % Calculates for each node pair only once
    for clust_i_ind = 1:clust_num
        for clust_j_ind = clust_i_ind+1:clust_num
            %% Find internal MST nodes of both clusters
            internal_nodes_i = str2double(table2array(MST_mrd_internal{clust_i_ind}.Nodes))';
            internal_nodes_j = str2double(table2array(MST_mrd_internal{clust_j_ind}.Nodes))';

            %% Remove lowest density nodes because they might be outliers and influence results
            for remove_node_ind = 1:length(lowest_density_nodes{clust_i_ind})
                internal_nodes_i(internal_nodes_i == lowest_density_nodes{clust_i_ind}(remove_node_ind)) = [];
            end
            for remove_node_ind = 1:length(lowest_density_nodes{clust_j_ind})
                internal_nodes_j(internal_nodes_j == lowest_density_nodes{clust_j_ind}(remove_node_ind)) = [];
            end

            %% Get cluster data for both clusters
            clust_i = data_clust{clust_i_ind};
            clust_j = data_clust{clust_j_ind};
           
            %% Get internal MST_mrd nodes of cluster data for both clusters
            internal_clust_i = clust_i(internal_nodes_i,:);
            internal_clust_j = clust_j(internal_nodes_j,:);

            %% Get core distances for both clusters and distances between different cluster point pairs
            clust_i_j_distances = pdist2(internal_clust_i,internal_clust_j,'euclidean'); % Get distance between each internal point pair of differenet clusters clust_i and clust_j 
            core_dist_i = a_pts_core_dist{clust_i_ind}(internal_nodes_i);  % Get core distance for each internal point in clust_i
            core_dist_j = a_pts_core_dist{clust_j_ind}(internal_nodes_j);  % Get core distance for each internal point in clust_j

            %% Calculate Mutual Reachability distances matrix for each point pair (i,j) in clust_i and clust_j
            core_dist_cols_i = repmat(core_dist_i',1 ,length(internal_clust_j(:,1)));
            core_dist_rows_j = repmat(core_dist_j,length(internal_clust_i(:,1)),1);
            core_dist_clust_i_j_max = max(core_dist_cols_i,core_dist_rows_j);
            %% Remove diagonal data if necessary
%           core_dist_pair_max(core_dist_pair_max==0) = [];

            mutual_reach_dist_clust_i_j= max(core_dist_clust_i_j_max,clust_i_j_distances);

            %% Show min DSPC
%             [~,clust_i_point_ind] = min(min(mutual_reach_dist_clust_i_j,[],2));
%             [~,clust_j_point_ind] = min(min(mutual_reach_dist_clust_i_j,[],1));
% 
%             real_i_ind = internal_nodes_i(clust_i_point_ind);
%             real_j_ind = internal_nodes_j(clust_j_point_ind);
% 
%             show_3D_clustering(data,labels);
%             hold on
%             scatter3(gca,clust_i(real_i_ind,1),clust_i(real_i_ind,2),clust_i(real_i_ind,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%             scatter3(gca,clust_j(real_j_ind,1),clust_j(real_j_ind,2),clust_j(real_j_ind,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
% %            
            %% Calculate Density Separation of a Pair of Clusters (DSPC) - minimum mutual reachability distance between internal nodes
            % Density Separation is defined as the minimum reachability distance between the internal nodes of the MST MRD s of clusters clust_i and clust_j.
            % Based on DEFINITION 6 from [1]
            % Density separation of a cluster with regards to another cluster is the minimum MRD between its points
            % and the points from the other cluster, which can be seen as the maximum density area between the cluster and the other cluster. 
            % DSPC(clust_i_ind,clust_j_ind) = min(mutual_reach_dist_clust_i_j,[],"all");
            %% Calculate DSPC as mean of 1% of min distance between points of differenet clusters in case outliers affect results.
            row_MRD_clust_i_j = min(clust_i_j_distances,[],2); %% take distinct node distances
%             row_MRD_clust_i_j = reshape(mutual_reach_dist_clust_i_j.',1,[]);
            sorted_DSPC = sort(row_MRD_clust_i_j);
            % Get length of bigger cluster
            max_clust_node_len = max([length(internal_clust_i(:,1)),length(internal_clust_j(:,1))]);
            DSPC(clust_i_ind,clust_j_ind) = mean(sorted_DSPC(1:ceil(max_clust_node_len*0.1)));
        end
    end

%   Make square matric from DSPC
    DSPC = DSPC'+DSPC;

    %% 7) Calculate Validity Index of a Cluster
    % Based on DEFINITION 7 from [1]
    for clust_i = 1:clust_num
        %% Get minimum all DSPC for cluster clust_i
        DSPC_row_i = DSPC(clust_i,:);
        min_DSPC = min(DSPC_row_i(DSPC_row_i~=0));

        %% Calculate validity index of cluster
        max_density = max([min_DSPC,DSC(clust_i)]);
        % If a cluster has better density compactness than density separation we obtain positive values of the validity index.
        % If the density inside a cluster is lower than the density that separates it from other clusters, the index is negative.
        VC_index(clust_i) = (min_DSPC-DSC(clust_i))/max_density;
        %% Get first node with degree 1
%         nodes = table2array(MST_mrd_internal{clust_i}.Nodes);
%         one_degree_nodes = find(degree(MST_mrd_internal{clust_i})==1);
%         SPTree = shortestpathtree(MST_mrd_internal{clust_i},str2num(nodes{one_degree_nodes(1)}));
%         sp_nodes = str2double(table2array(SPTree.Nodes))';
%         plot(SPTree,'XData',cluster(sp_nodes,1),'YData',cluster(sp_nodes,2),'ZData',cluster(sp_nodes,3));
        % Calculate number of points in each cluster for later use
        clust_i_len(clust_i) = length(data_clust{clust_i}(:,1));     
    end

    disp('DSC: ');
    disp(DSC);
    disp('DSPC: ');
    disp(DSPC);
    disp('VC_index: ');
    disp(VC_index);
    disp('clust_i_len: ');
    disp(clust_i_len);

    %% 8) Calculate Validity Index of a Clustering - should be value from -1 to 1
    % Based on DEFINITION 8 from [1]
    %% Multiply by data percentage as many as feature length times to reward bigger clusters and punish smaller.
    all_data_len = data_len+outliers_len;
    DBCV_index = sum((VC_index.*((clust_i_len./all_data_len).^1)));

    %% Used to punish data with more outliers.
    outlier_factor = (data_len/all_data_len); % percentage of noise in the dataset
    if DBCV_index>0
        DBCV_index = DBCV_index * outlier_factor;
    else
        DBCV_index = DBCV_index / outlier_factor;
    end

    disp('DB_index: ');
    disp(DBCV_index);
end



function [hole_nodes,hole_points,sorted_val] = Get_Hole_by_Nodes(MST,data_clust)
        internal_nodes = str2double(table2array(MST.Nodes))';
        internal_points = data_clust(internal_nodes,:);
        internal_point_distances = sort(pdist2(internal_points,data_clust),2,'ascend');

        result_dist = zeros(1,length(internal_points(:,1)));
        
        for point_id = 1:length(internal_points(:,1))
            close_distances = internal_point_distances(point_id,1:min([length(internal_point_distances),15+1])); %% first element is zero
            result_dist(point_id) = mean(close_distances);
        end

        [sorted_val,sorted_point_ind] = sort(result_dist,'descend');
%         sorted_val = sorted_val(1:min([length(internal_nodes),number_of_holes]));
        %% Choose  10% of nodes
        number_of_holes = ceil(length(internal_nodes)*0.1);
        sorted_point_ind = sorted_point_ind(1:number_of_holes);
        hole_nodes = internal_nodes(sorted_point_ind);
        hole_points = internal_points(sorted_point_ind,:);

%         scatter3(hole_points(sorted_point_ind,1),hole_points(sorted_point_ind,2),hole_points(sorted_point_ind,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%         for i=sorted_point_ind
%             scatter3(hole_points(i,1),hole_points(i,2),hole_points(i,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%         end

end

function [hole_start_nodes,hole_end_nodes,hole_points] = Get_Hole_by_HighestEdge_MidNodes(MST,data_clust,number_of_holes)
        [largest_weigths, weights_ind]= sort(MST.Edges.Weight,'descend');
        %% Get 10 nodes with largest edge weights
        start_nodes = str2double(MST_mrd_deep.Edges.EndNodes(weights_ind(1:number_of_holes),1))';
        end_nodes = str2double(MST_mrd_deep.Edges.EndNodes(weights_ind(1:number_of_holes),2))';
        start_points = data_clust(start_nodes,:);
        end_points = data_clust(end_nodes,:);
        mid_points = (start_points+end_points)./2;

        point_distances = sort(pdist2(mid_points,data_clust),2,'ascend');

        result_dist = zeros(1,length(mid_points(:,1)));
        
        for point_id = 1:length(mid_points(:,1))
            close_distances = point_distances(point_id,1:min([length(point_distances),15+1])); %% first element is zero
            result_dist(point_id) = mean(close_distances);
        end

        %% Sort nodes by density from lowest to highes (numerically from highest to lowest)
        [sorted_val,sorted_point_ind] = sort(result_dist,'descend');

        sorted_point_ind = sorted_point_ind(1:number_of_holes);
        hole_start_nodes = start_nodes(sorted_point_ind);
        hole_end_nodes = end_nodes(sorted_point_ind);
        hole_points = mid_points(sorted_point_ind,:);

%         scatter3(mid_points(sorted_point_ind,1),mid_points(sorted_point_ind,2),mid_points(sorted_point_ind,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%         for i=sorted_point_ind
%             scatter3(mid_points(i,1),mid_points(i,2),mid_points(i,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%         end
end

function [result_dist] = Get_Points_Density(points,data_clust)

    point_distances = sort(pdist2(points,data_clust),2,'ascend');

    result_dist = zeros(1,length(points(:,1)));
    
    for point_id = 1:length(points(:,1))
        close_distances = point_distances(point_id,min([length(point_distances),15+1])); %% first element is zero
        result_dist(point_id) = mean(close_distances);
    end

end

function [hole_start_nodes,hole_end_nodes,hole_points,hole_density] = Get_Hole_by_MidNodes(MST,data_clust,number_of_holes)
        start_nodes = str2double(MST.Edges.EndNodes(:,1))';
        end_nodes = str2double(MST.Edges.EndNodes(:,2))';
        start_points = data_clust(start_nodes,:);
        end_points = data_clust(end_nodes,:);
        mid_points = (start_points+end_points)./2;

        result_dist = Get_Points_Density(mid_points,data_clust);

        %% Sort nodes by density from lowest to highes (numerically from highest to lowest)
        [sorted_val,sorted_point_ind] = sort(result_dist,'descend');
        
        sorted_val = sorted_val(1:min([length(sorted_point_ind),number_of_holes]));
        sorted_point_ind = sorted_point_ind(1:min([length(sorted_point_ind),number_of_holes]));
        
        hole_ind = [];
        for mid_node_ind = 1:length(sorted_point_ind)
            start_node = start_nodes(sorted_point_ind(mid_node_ind));
            end_node = end_nodes(sorted_point_ind(mid_node_ind));

            searched_nodes_start = Get_Neigh_Nodes(MST,start_node,5,[end_node]);

            searched_nodes_end = Get_Neigh_Nodes(MST,end_node,5,[start_node]);

            closest_points_start = data_clust(searched_nodes_start,:);
            closest_points_end = data_clust(searched_nodes_end,:);

            min_density_point_start =  min(Get_Points_Density(closest_points_start,data_clust));

            min_density_point_end =  min(Get_Points_Density(closest_points_end,data_clust));


            dens_factor_start = min_density_point_start./sorted_val(mid_node_ind);
            dens_factor_end = min_density_point_end./sorted_val(mid_node_ind);

            color = 'red';
            if dens_factor_start < 0.65 &&  dens_factor_end < 0.65

                over_factor = max([dens_factor_start,dens_factor_end]);
%                 h = get(gca,'XLabel');
%                 origxlabel = get(h,'String');
%                 origxlabel{length(origxlabel)+1} = num2str(over_factor);
%                 set(h,'String',[origxlabel])
%                 disp('Found hole point')
                hole_ind = [hole_ind,mid_node_ind];

               color = 'black';
            end
            global check_holes
            if check_holes
                i = sorted_point_ind(mid_node_ind);
                scatter3(mid_points(i,1),mid_points(i,2),mid_points(i,3),100,color,'filled','x','LineWidth',4,'MarkerEdgeColor','flat')
                over_factor = max([dens_factor_start,dens_factor_end]);
                disp(over_factor);
            end
        end



        %% Find holes based on start and end nodes density
%         start_result_dist = Get_Points_Density(start_points,data_clust);
%         end_result_dist = Get_Points_Density(end_points,data_clust);
% 
%         start_result_dist = start_result_dist(sorted_point_ind);
%         end_result_dist = end_result_dist(sorted_point_ind);
% 
%         min_around_dist = min([start_result_dist;end_result_dist]);
% 
%         density_coeff  = sorted_val(1:number_of_holes)./min_around_dist;
% 
%         [real_val,real_ind] = sort(density_coeff,'ascend');
% 
%         h = get(gca,'XLabel');
%         origtitle = get(h,'String');
%         origtitle{length(origtitle)+1} = num2str(real_val);
%         set(h,'String',[origtitle])
% 
%         %% Remove mid points that have close to 60% density as nodes that make them
%         %% Beacause holes are seperated by dens areas
%         hole_ind = sorted_point_ind(real_ind(find(real_val<0.6)));
%         hole_density = sorted_val(real_ind(find(real_val<0.6)));

        hole_start_nodes = start_nodes(sorted_point_ind(hole_ind));
        hole_end_nodes = end_nodes(sorted_point_ind(hole_ind));
        hole_points = mid_points(sorted_point_ind(hole_ind),:);
        hole_density = sorted_val(hole_ind);

%         scatter3(mid_points(hole_ind,1),mid_points(hole_ind,2),mid_points(hole_ind,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%         for i=hole_ind
%             scatter3(mid_points(i,1),mid_points(i,2),mid_points(i,3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%         end
end

function [internal_neigh] = Get_Internal_Nodes_Impact(MST,data_clust)
    internal_nodes = str2double(table2array(MST.Nodes))';
    internal_points = data_clust(internal_nodes,:);
    %% Create new tree from internal internal nodes by connecting points to closest node
    node_bw_distances = pdist2(internal_points,data_clust);
    [conn_edges,connected_nodes]= min(node_bw_distances,[],1);

    neighbor_pairs = internal_nodes(connected_nodes);
    for internal_node = 1:length(internal_nodes)
        internal_neigh(internal_node) = sum(neighbor_pairs==internal_nodes(internal_node));
    end
end

function [hole_neigh] = Get_Hole_Nodes_Impact(MST,data_clust,hole_start_nodes,hole_end_nodes,hole_points)
    internal_nodes = str2double(table2array(MST.Nodes))';
%     internal_nodes_without_holes = setdiff(setdiff(internal_nodes,hole_start_nodes),hole_end_nodes);
    internal_points = [hole_points; data_clust(internal_nodes,:)];

    node_bw_distances = pdist2(internal_points,data_clust);
    [conn_edges,connected_nodes]= min(node_bw_distances,[],1);

    for hole_node =  1:length(hole_end_nodes)
        hole_neigh(hole_node) = sum(connected_nodes==hole_node);
    end

%     [~,sorted_ind] = sort(hole_neigh);
%     for i = 1:length(sorted_ind)
%         scatter3(hole_points(sorted_ind(i),1),hole_points(sorted_ind(i),2),hole_points(sorted_ind(i),3),100,'black','filled','x','LineWidth',4,'MarkerEdgeColor','flat')
%     end
end

function [searched_nodes] = Get_Neigh_Nodes(G,center_node,step,searched_nodes)

        if step == 0
            return;
        end

        neigh_nodes_cell = neighbors(G,num2str(center_node));
        neigh_nodes = str2double(neigh_nodes_cell)';
        solo_nodes = neigh_nodes(find(degree(G,neigh_nodes_cell)<2));

        searched_nodes = [searched_nodes,center_node];
        if step == 1
            return        
        end
        searched_nodes = [searched_nodes,solo_nodes];
        neigh_nodes = setdiff(neigh_nodes,searched_nodes);

        for neigh_ind = 1:length(neigh_nodes)
            searched_neigh_nodes = Get_Neigh_Nodes(G,neigh_nodes(neigh_ind),step-1,searched_nodes);
            searched_nodes = unique([searched_neigh_nodes,searched_nodes]);
        end
end