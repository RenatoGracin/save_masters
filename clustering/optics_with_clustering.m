function [clusterIndices] = optics_with_clustering(data,Nmin,eps,w,t,twoD)
    arguments
        data
        Nmin
        eps
        w = 0.5;
        t = 160; %160
        twoD = 0;
    end
    if twoD == 0
        [orderedList, reachDistList, coreDistList, procesList] = faster_optics(data, Nmin, eps);
    else
        [orderedList, reachDistList, coreDistList, procesList] = optics(data, Nmin, eps);
    end

%     [orderedList, reachDistList] = my_optics(data,eps,Nmin);
%     reachDistList(isinf(reachDistList)) = -1;
%     reachDistList(reachDistList==-1) = max(reachDistList);

%     figure
%     plot(reachDistList(orderedList), 'linewidth', 1);
%     title('optics')
%     grid on
% 
%     figure
%     plot(reach_dist(order), 'linewidth', 1);
%     title('my optics')
%     grid on

     for i = 1:size(data,1)
         orderedReachList(i,1) = reachDistList(orderedList(i));
     end
     
%      reach_dist=importdata('reach_dist.txt');
%      orderedReachList = reach_dist;

%      figure
%      plot(orderedReachList, 'linewidth', 1);
%      grid on
%      title('Rezultat OPTICS algoritma','fontSize' ,20);
    %  ylabel('dohvatna udaljenost','fontSize' , 16);
    %  xlabel('redoslijed obrađivanih točaka','fontSize' , 16);
    %  set(gca,'FontSize',14)
%      xlim([0 3000]);
       
%     w = 0.5; % 0.5;
%     t = 160;

    large_cluster_perc = 1; % 0.9
    merge_perc = 0.8;

%     SetClusters (final result, each row presents a cluster, first number is     
%                the cluster start point, second number cluster end point, 
%                third number cluster size)
%     Nmin = 30; %% Min length of cluster
    [SetClusters, clustNum] = gradient_clustering( orderedReachList, Nmin, t, w, large_cluster_perc, merge_perc, 2);
    
%     figure
%     plot(orderedReachList);
%     hold on
%     axis([0 size(reachDistList,1) 0 max(reachDistList(reachDistList~=1024))*3]);
%     set(gca,'Box','on');
%     ylim([0 max(reachDistList)]);
%     grid on
%     title('Dohvatna krivlulja, konačne otkrivene grupacije');
%     ylabel('dohvatna udaljenost');
%     xlabel('redoslijed obrađivanih točaka');
%     
%      for i=1:clustNum
%         first = SetClusters(i,1);
%         last = SetClusters(i,2);
%         line([first;last],[orderedReachList(first);orderedReachList(last)],'color',rand(1,3));
%      end 
    
    clusterIndices=getClusterIndices(orderedList, SetClusters, clustNum);
end

