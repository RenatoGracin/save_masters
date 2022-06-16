def optics_clustering(data,Nmin,eps):

    [orderedList, reachDistList, coreDistList, procesList] = faster_optics(data, Nmin, eps);

    for i = 1:size(data,1)
         orderedReachList(i,1) = reachDistList(orderedList(i));
    end
     
    w = 0.5;
    t = 160;
    
    large_cluster_perc = 1;
    merge_perc = 0.8;

#     SetClusters (final result, each row presents a cluster, first number is     
#                the cluster start point, second number cluster end point, 
#                third number cluster size)

    [SetClusters, clustNum] = gradient_clustering( orderedReachList, Nmin, t, w, large_cluster_perc, merge_perc, 2);
    
    
    return getClusterIndices(orderedList, SetClusters, clustNum);