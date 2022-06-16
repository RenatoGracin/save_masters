
clear all

[data, cp, idx] = generateData(1, 0.5, 4, 30, 30, 5, 1, 2, 1000);
data = data(:,:) + 50;



%%

figure
scatter(data(:,1), data(:,2), 8, idx);

Nmin = 50;
eps = 10;
[orderedList, reachDistList, coreDistList, procesList] = optics(data, Nmin, eps);

 for i = 1:size(data,1)
     orderedReachList(i,1) = reachDistList(orderedList(i));
 end
% figure
% plot(orderedReachList);

%%
w = 0.5;
t = 160;

large_cluster_perc = 0.7;
merge_perc = 0.5;

[SetClusters, clustnum] = gradient_clustering( orderedReachList, Nmin, t, w, large_cluster_perc, merge_perc, 2 );

figure
hold on

 for i=1:clustnum

   index = (SetClusters(i,1):SetClusters(i,2));
   index_ordered = orderedList(index);

   scatter(data(index_ordered,1),data(index_ordered,2),8);
   axis([ 0 120 0 120]);
   set(gca,'Box','on');
 end   


%%
figure
plot(orderedReachList);
hold on

 for i=1:clustnum

    first = SetClusters(i,1);
    last = SetClusters(i,2);
    line([first;last],[orderedReachList(first);orderedReachList(last)],'color',rand(1,3));

 end 
 
%% ispis podataka
% bla = data(:,1)';
% csvwrite('data.txt',bla);
% bla2 = data(:,2)';
% csvwrite('data2.txt',bla2);