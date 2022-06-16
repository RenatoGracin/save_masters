function [clustersMatrix, prevCluster, newClustInd, newClustTest, colorMatrix, prevClust_ind] = optics_merging(clusterIndices, clustersMatrix, prevCluster,  crosPointNum, clustnum, newClustInd, iter, step, colorMatrix,boxSize )

newClustTest = zeros(clustnum,1);

if iter>0   
    currCluster = zeros(crosPointNum,1);
    simMatrix = zeros(100,100);
%     simMatrix = zeros(10,10);
 
% labeling first "crosPointNum" amount of points depending on their cluster 
% Because first "crosPointNum" are the same points as prevCluster

    for i=1:crosPointNum    
        currCluster(i) = clusterIndices(i);
    end
         

%filling simmilarity matrix
    for i=1:crosPointNum
        if prevCluster(i)~=0 && currCluster(i)~=0
            simMatrix(prevCluster(i), currCluster(i))=simMatrix(prevCluster(i), currCluster(i))+1;    
        end
    end 
     

% combining clusters
    if clustnum>0
        for i=1:clustnum  
                % Get row of cluster for current clustering labels
                pom = simMatrix(:,i);          
                [value, index] = max(pom);
                pom2 = simMatrix(index,:);
                
%                 if value >= 0.8*sum(pom) && value >= 0.8*sum(pom2) && value~=0
%                     clustersMatrix(i,step+1)=clustersMatrix(index,step);
%                     colorMatrix(i,step+1)=colorMatrix(index,step);
%                 elseif value >= 0.8*sum(pom) && value~=0
%                     clustersMatrix(i, step+1)=newClustInd;
%                     colorMatrix(i,step+1)=clustersMatrix(index,step);
%                     newClustInd=newClustInd+1;
%                     newClustTest(i)=1;
%                 else
%                     clustersMatrix(i, step+1)=newClustInd;
%                     if value==0
%                         colorMatrix(i,step+1)=newClustInd;
%                     else
%                         colorMatrix(i,step+1)=colorMatrix(index,step);
%                     end
%                     newClustInd=newClustInd+1;
%                     newClustTest(i)=1;
%                     
%                 end
               
                % Current cluster must match more than 70% of all his matches with previous cluster to be a valid match
                % Also previous cluster must match more than 70% of all his matches with current cluster to be a valid match
                perc_limit = 0.7; % 0.7
                if (value >= perc_limit*sum(pom) && value >= perc_limit*sum(pom2)) && value~=0
                    clustersMatrix(i,step+1)=clustersMatrix(index,step);
                else               
                    clustersMatrix(i, step+1)=newClustInd;
                    newClustInd=newClustInd+1;
                    newClustTest(i)=1;
                end
        end
    end
end

if iter==0
    for i=1:clustnum
        clustersMatrix(i, 1)=i;
        colorMatrix(i,1)=i;
        newClustTest(i)=1;
    end
    newClustInd = clustnum+1;
    

end

% saving "crosPointNum" amount of cluster labels

 prevCluster = zeros(crosPointNum,1);

%  for i=1:crosPointNum     
%      prevCluster(i)= clusterIndices(i+length(clusterIndices)-crosPointNum);
%  end
    prevCluster = [];
    prevClust_ind = [];
%% Take random points of each cluster
    for clust_ind = 1:clustnum
        valid_data_len =  sum(clusterIndices>0);
        clust_len = sum(clusterIndices==clust_ind);   
        clust_save_ind = randsample(find(clusterIndices==clust_ind),round(clust_len*crosPointNum/valid_data_len)')';
        prevClust_ind = [prevClust_ind,clust_save_ind];
        prevCluster = [prevCluster,clusterIndices(clust_save_ind)'];
    end
    if length(prevCluster) < crosPointNum
        needed_points_len = crosPointNum-length(prevCluster);
        not_used_points = setdiff([1:length(clusterIndices)],prevClust_ind);
        prevClust_ind = [prevClust_ind,not_used_points(1:needed_points_len)];
        prevCluster = [prevCluster,clusterIndices(not_used_points(1:needed_points_len))];
    elseif length(prevCluster) > crosPointNum
        prevClust_ind = prevClust_ind(1:crosPointNum);
        prevCluster = prevCluster(1:crosPointNum);
    end
end