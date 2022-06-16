
% must import data before using, either from dataclust2 or dataclust

%data=[dataclust2(:,1),dataclust2(:,2)];
data=[dataclust(2:end,1),dataclust(2:end,2)];

data=data{:,:};
%%
%index = dataclust2{:,3};
figure

%scatter(data(:,1), data(:,2), 8, index);
scatter(data(:,1), data(:,2), 8);

%%
Nmin = 15;
eps = 10;
[orderedList, reachDistList, coreDistList, procesList] = faster_optics(data, Nmin, eps);

 for i = 1:size(data,1)
     orderedReachList(i,1) = reachDistList(orderedList(i));
 end
% figure
% plot(orderedReachList);

%%
w = 1;
t = 160;
minMax = 2;

large_cluster_perc = 0.7;
merge_perc = 0.8;

[SetClusters, clustnum] = gradient_clustering( orderedReachList, Nmin, t, w, large_cluster_perc, merge_perc, minMax );

figure
hold on

 for i=1:clustnum

   index = (SetClusters(i,1):SetClusters(i,2));
   index_ordered = orderedList(index);

   scatter(data(index_ordered,1),data(index_ordered,2),8);
   %axis([ 0 35 0 35]);
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
 
%%
bla = data(:,1)';
csvwrite('data.txt',bla);
bla2 = data(:,2)';
csvwrite('data2.txt',bla2);