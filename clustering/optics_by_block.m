function [labels,final_ellipsoids] = optics_by_block(labels,data_all,Nmin,eps,boxSize,crosPointNum)
    arguments
        labels
        data_all
        Nmin
        eps
        boxSize = 500
        crosPointNum = 250
    end
    %% Columns represent each clustering step and Rows represent clusters in each step
    %% Values are global cluster ids, if they are the same in different steps it means that their are part of same global cluster
    clustersMatrix = zeros(50,50);
    colorMatrix = zeros(50,50);
    prevCluster = zeros(crosPointNum,1);
    newClustInd=0;
    
    % podesavanje zadnjeg intervala
    if size(data_all,1) <= crosPointNum
        totalStages = 1;
    else
        totalStages = floor((size(data_all,1)-crosPointNum)/(boxSize-crosPointNum));
    end
    %totalStages =9;
    
    firstStage = 0;
    iter=0;
%     labels = [];
    data_cumul = [];
    colors = [[1,0,0];[0.2,0.8,1.00];[1,1,0];[0,1,0];[1,0,1];[0,0,0];[0,1,1];[0.64,0.08,0.18];[1.00,0.41,0.16];[0.93,0.69,0.13];...
        [0.8,0.3,0.5];[0.8,0.1,0];[0.4,1,0.4];[0.23,0,0.23];[1,0.55,0];[0.5,0.9,0.9];[0.1,0.3,0.5];[0.3,0.2,1]];
%     figure;
%     hold on
%     ylabel('peak amp');
%     xlabel('time')
%     totalStages = 10;
%     colors_ind = 0;
    for step = firstStage:totalStages-1
    
        % iter= 0 -> 1:1000
        % iter= 1 -> 751:1750
        % iter= 3 -> 1751:2500
%         data = data_all(step*(boxSize-crosPointNum)+1:(step+1)*(boxSize)-step*crosPointNum,:);    
        if iter>0
            prev_data = data(prevClust_ind,:);
            clust_ellipsoids_prev = final_ellipsoids;
            clustnum_prev = length(clust_ellipsoids_prev(:,1));
        else
            prevClust_ind = [];
            prev_data =  [];
            clust_ellipsoids_prev = [];
            clustnum_prev = 0;
            plotElips = [];
        end

         %% Take first boxSize data point but then take crosPointNum starting from middle of prev data points
         data_start_ind = step*(boxSize-length(prevClust_ind))+1;
         data_end_ind = min([length(data_all),(step+1)*(boxSize-length(prevClust_ind))]);
         data = [prev_data;data_all(data_start_ind:data_end_ind,:)];
            
%          show_3D_clustering(data,[labels(prevClust_ind),labels(data_start_ind:data_end_ind)]);
%          disp('hm');
%         colors_ind = colors_ind+2;
%         scatter(data(1:crosPointNum,1),data(1:crosPointNum,2),5,colors(colors_ind-1,:),'filled');
%         scatter(data(crosPointNum:end,1),data(crosPointNum:end,2),5,colors(colors_ind,:),'filled');
%         scatter3(data(:,1),data(:,2),data(:,3),5,colors(step+1,:),'filled');
%         continue;
       
        
        % figure
        % scatter( data(:,2), data(:,1), 'b','.');
        % title('Input data');
        % ylabel('frequency, kHz');
        % xlabel('time, h');
        % axis([ min(data(:,2)) max(data(:,2)) 50 350]);
        % set(gca,'Box','on');
        
        clusterIndices = optics_with_clustering(data,Nmin,eps);

%          figure;
%         show_3D_clustering(data,clusterIndices);
        if iter>0
            delete(plotElips);
        else
            plotElips = [];
        end

        u_labels = unique(clusterIndices(clusterIndices>0));
        clustnum_curr = length(u_labels);

        %% Calculate ellipsoid without rotation of each cluster
        
        clust_ellipsoids_curr = zeros(clustnum_curr,9);
        hold on
%         show_3D_clustering(data,clusterIndices);
        for clust_ind = 1:clustnum_curr
            clust_data = data(clusterIndices==u_labels(clust_ind),:);
%             maxs = max(clust_data);
%             mins = min(clust_data);
%             radii = (maxs-mins)/2;
%             center = mean([maxs;mins]);
%             ellipsoid_create(center(1),center(2),center(3),radii(1),radii(2),radii(3));

            [A ,center] = MinVolEllipse(clust_data', 0.001);

            [U, Q, V] = svd(A);

            %% V is rotation...

            radii = [0,0,0];
            
            radii(1) = 1/sqrt(Q(1,1));
            radii(2) = 1/sqrt(Q(2,2));
            radii(3) = 1/sqrt(Q(3,3));

            clust_ellipsoids_curr(clust_ind,:) = [radii, center(1:3)', [0, 0, 0]];
%             ellipsoid_create(center(1),center(2),center(3),radii(1),radii(2),radii(3));
        end

        clust_ellipsoids_all = [clust_ellipsoids_prev;clust_ellipsoids_curr];
        clustnum_all = length(clust_ellipsoids_all(:,1));
        
        sameClusts = zeros(clustnum_all,clustnum_all);
        %% Check if ellipsoids of previous cluster and current cluster overlap
        for clust_all_i = 1:clustnum_all
            for clust_all_j = 1:clustnum_all
                % https://se.mathworks.com/matlabcentral/fileexchange/71709-check-ellipsoids-overlapping
                if overlap(clust_ellipsoids_all(clust_all_i,:),clust_ellipsoids_all(clust_all_j,:))
                    sameClusts(clust_all_i,clust_all_j) = 1;
                end
            end
        end

        %% Calculate all connections that make same cluster
        group_ind = 0;
        grouped_clusters = [];
        final_cluster_groups = {};
        for clust_all_i = 1:clustnum_all 
            if ~ismember(clust_all_i,grouped_clusters)
                group_ind = group_ind +1;
                final_cluster_groups{group_ind} = Connect_All_Clusters([],clust_all_i,sameClusts);
                grouped_clusters = [grouped_clusters,final_cluster_groups{group_ind}];
            end
        end

        final_ellipsoids = zeros(length(final_cluster_groups),9);
        %% Combine intersecting ellispoids
        for clust_final_i = 1:length(final_cluster_groups)
            %% Change labels based on ellipsoids
            inside_clust_ids = final_cluster_groups{clust_final_i};
            for inside_clust_ind = 1:length(inside_clust_ids)
                clusterIndices(clusterIndices==inside_clust_ids(inside_clust_ind)) = clust_final_i;
            end
            try
                clust_final_i_ellipsoids = clust_ellipsoids_all(inside_clust_ids,:);
            catch
                warning('Problem using function.  Assigning a value of 0.');
                disp('why');
            end
            
            if length(clust_final_i_ellipsoids(:,1)) == 1
                final_ellipsoids(clust_final_i,:) = clust_final_i_ellipsoids;
            else
                %% Calculate new max and min limits
                maxs = max(clust_final_i_ellipsoids(:,4:6)+clust_final_i_ellipsoids(:,1:3));
                mins = min(clust_final_i_ellipsoids(:,4:6)-clust_final_i_ellipsoids(:,1:3));
                radii = (maxs-mins)/2;
                center = mean([maxs;mins]);
%                 ellipsoid_create(center(1),center(2),center(3),radii(1),radii(2),radii(3));
                final_ellipsoids(clust_final_i,:) = [radii, center, [0, 0, 0]];
            end
        end

        %% Maybe change outliers to labels if inside elipsoids without rotation
        for elips_ind = 1:length(final_ellipsoids(:,1))
            ellipsoid_i = final_ellipsoids(elips_ind,:); 
            center = ellipsoid_i(4:6);
            radii = ellipsoid_i(1:3);
            elips_cond = ((data(:,1)-center(1)).^2)/(radii(1)^2) + ((data(:,2)-center(2)).^2)/(radii(2)^2) + ((data(:,3)-center(3)).^2)/(radii(3)^2);
            labels_inside_elips_ind = find(elips_cond<1);
            labels_inside_elips = clusterIndices(labels_inside_elips_ind);
            clusterIndices(labels_inside_elips_ind) = mode(labels_inside_elips(labels_inside_elips>0));
        end

        prevCluster = [];
        prevClust_ind = [];
    %% Take random points of each cluster
        sample_points_len = crosPointNum;
        valid_data_len =  sum(clusterIndices>0);
        if sample_points_len > valid_data_len || 1
            valid_data_len = length(clusterIndices);
            clust_len = sum(clusterIndices<1);
            clust_save_ind = randsample(find(clusterIndices<1),round(clust_len*crosPointNum/valid_data_len)')';
            %% Take all outliers
%             sample_points_len = crosPointNum - clust_len;
%             clust_save_ind = find(clusterIndices<1)';
            prevClust_ind = [prevClust_ind,clust_save_ind];
            prevCluster = [prevCluster,clusterIndices(clust_save_ind)'];
        end
        for clust_ind = 1:length(unique(clusterIndices(clusterIndices>0)))
            clust_len = sum(clusterIndices==clust_ind);
            clust_save_ind = randsample(find(clusterIndices==clust_ind),round(clust_len*sample_points_len/valid_data_len)')';
            prevClust_ind = [prevClust_ind,clust_save_ind];
            prevCluster = [prevCluster,clusterIndices(clust_save_ind)'];
        end
        if length(prevCluster) < crosPointNum
            needed_points_len = crosPointNum-length(prevCluster);
            not_used_points = setdiff([1:length(clusterIndices)],prevClust_ind);
            prevClust_ind = [prevClust_ind,not_used_points(1:needed_points_len)];
            try
                prevCluster = [prevCluster,clusterIndices(not_used_points(1:needed_points_len))'];
            catch
                disp('sa');
            end
        elseif length(prevCluster) > crosPointNum
            prevClust_ind = prevClust_ind(1:crosPointNum);
            prevCluster = prevCluster(1:crosPointNum);
        end

%         figure;
%         show_3D_clustering(data,clusterIndices);
        iter=1;
%         scatter3(data_all(:,1),data_all(:,2),data_all(:,3),5,"black","filled");
        for elips_ind = 1:length(final_ellipsoids(:,1))
            elips = final_ellipsoids(elips_ind,:);
            hold on
%            plotElips = [plotElips,ellipsoid_create(elips(4),elips(5),elips(6),elips(1),elips(2),elips(3))];
        end

        disp(step);
        continue;
        
        [clustersMatrix, prevCluster, newClustInd, newClustTest, colorMatrix,prevClust_ind] = optics_merging(clusterIndices, clustersMatrix, prevCluster,  crosPointNum, clustnum_curr, newClustInd, iter, step, colorMatrix,boxSize);
        iter=1;

        if step == 0
            labels = [clusterIndices];
            data_cumul = [data];
%             show_3D_clustering(data_cumul,labels);
        else
            for clust_id = 1:clustnum_curr
                clusterIndices(clusterIndices==clust_id) = clustersMatrix(clust_id,step);
            end
%             labels = [labels;clusterIndices(crosPointNum+1:end)];
%             data_cumul = [data_cumul;data(crosPointNum+1:end,:)];
            labels = [labels(1:length(labels)-crosPointNum);clusterIndices];
            data_cumul = [data_cumul;data(crosPointNum+1:end,:)];
            show_3D_clustering(data,clusterIndices);
%             show_3D_clustering(data_cumul,labels);
%             disp('Najs');
        end
        
        if step == 0
            timeStampStart = 0;
             prevClustVect = 0;
             currClustVect = 0;
             prevyMaxEnd = 0; 
             prevyMinEnd = 0;
         else
        %     %timeStampStart = data(round(crosPointNum/2),2);
        %     timeStampStart = data(crosPointNum,2);
        %     
            prevClustVect = clustersMatrix(:,step);
            currClustVect = clustersMatrix(:,step+1);
        end
        
        %timeStampEnd = data(boxSize-round(crosPointNum/2),2);
        timeStampEnd = data(boxSize,2);
        
%         [timeMin, timeMax, yMinStart, yMinEnd, yMaxStart, yMaxEnd] = feature_extraction(data, clusterIndices, clustnum, timeStampEnd, timeStampStart, crosPointNum, newClustTest, prevClustVect, currClustVect, prevyMaxEnd, prevyMinEnd, Nmin);
%         prevyMaxEnd = yMaxEnd;
%         prevyMinEnd = yMinEnd;
        
        timeStampStart = timeStampEnd;
        
%         colors = ['b','r','g','y','c','m','k'];
%         
%         colormaps = ['Blues','BuGn','BuPu','GnBu','Greens','Reds','OrRd','Oranges','PuBu'];
%         cstart = [1,6,10,14,18,24,28,32,39];
%         cend = [5,9,13,17,23,27,31,38,42];
%         
%         if clustnum ~=0 
%                %line([data(boxSize,2) data(boxSize,2)],[50 350],'Color','red','LineStyle','--');
%                %line([data(1,2) data(1,2)],[50 350],'Color','blue','LineStyle','--');
%                %line([timeStampEnd timeStampEnd],[50 350],'Color','blue','LineStyle','--');
%                %line([timeStampStart timeStampStart ],[50 350],'Color','red','LineStyle','--');
%              for i=1:clustnum 
%                 index = clusterIndices(:)==i;
% %                 ylim([ 0 700]);        
%                 %scatter(data(index,2),data(index,1),'.',colors(mod(clustersMatrix(i,step+1)-1,7)+1)); 
%                 %scatter(data(index_ordered,2),data(index_ordered,1),'.');
%                 
%                 hold on
%                 
%                 %line([timeMin(i) timeMax(i)], [yMinStart(i) yMinEnd(i)], 'color', colors(mod(clustersMatrix(i,step+1)-1,7)+1));
%                 %line([timeMin(i) timeMax(i)], [yMaxStart(i) yMaxEnd(i)], 'color', colors(mod(clustersMatrix(i,step+1)-1,7)+1));
%                 %fill([timeMin(i) timeMax(i) timeMax(i) timeMin(i) ],[yMinStart(i) yMinEnd(i) yMaxEnd(i) yMaxStart(i) ], colors(mod(colorMatrix(i,step+1)-1,7)+1));
%                 fill([timeMin(i) timeMax(i) timeMax(i) timeMin(i) ],[yMinStart(i) yMinEnd(i) yMaxEnd(i) yMaxStart(i) ], colors(mod(clustersMatrix(i,step+1)-1,7)+1));
%                 fill([timeMin(i) timeMax(i) timeMax(i) timeMin(i) ],[yMinStart(i) yMinEnd(i) yMaxEnd(i) yMaxStart(i) ],'b');
%                 %colors2 = brewermap(max(SetClusters(:,3)),colormaps(cstart(clustersMatrix(i,step+1)):cend(clustersMatrix(i,step+1))));
%                 %fill(x,y,colors2(numel(index)-1,:));
%                 %colormap(brewermap(256,colormaps(cstart(i):cend(i))));
%              end    
%         end

    end

    labels = zeros(length(data_all(:,1)),1);
    figure;
    hold on;
    show_3D_clustering(data_all,labels)
    %% Create labels as points inside ellipsoids
    for elips_ind = 1:length(final_ellipsoids(:,1))
        ellipsoid_i = final_ellipsoids(elips_ind,:);
        center = ellipsoid_i(4:6);
        radii = ellipsoid_i(1:3);
        elips_cond = ((data_all(:,1)-center(1)).^2)/(radii(1)^2) + ((data_all(:,2)-center(2)).^2)/(radii(2)^2) + ((data_all(:,3)-center(3)).^2)/(radii(3)^2);
        labels_inside_elips_ind = find(elips_cond<1);
        labels(labels_inside_elips_ind) = elips_ind;
        hold on
        scatter3(data_all(labels_inside_elips_ind,1),data_all(labels_inside_elips_ind,2),data_all(labels_inside_elips_ind,3),5,'blue','filled');
        h = ellipsoid_create(ellipsoid_i(4),ellipsoid_i(5),ellipsoid_i(6),ellipsoid_i(1),ellipsoid_i(2),ellipsoid_i(3));
        delete(h);
    end
end

