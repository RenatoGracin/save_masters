% clear all
%close all

% data_all=importdata('dataclust.txt')';

 %data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1)]/2e3;
 %data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr];

% data_all = data_all';
% data_all = sortrows(data_all(2:end,:),2);



% figure
% scatter( data_all(:,2), data_all(:,1), 'b','.');
% title('Ulazni podaci za grupiranje');
% ylabel('frequency, kHz');

%% razdvajanje uzoraka po zadanom broju

%parametri
boxSize = 1000; %block size
crosPointNum = 250;
Nmin = 3; % 5% ukupnih

eps = 10;
type = 2;
w = 0.5;
t = 160;


% data_all = [feature_matrix(sorted_ind,13),feature_matrix(sorted_ind,18)];
% [~,peak_freq_sort_ind] = sort(feature_matrix(:,18));
% data_all = [feature_matrix(peak_freq_sort_ind,13),feature_matrix(peak_freq_sort_ind,18)];
data_all = [feature_matrix(:,1),feature_matrix(:,18),feature_matrix(:,19)];
% [~,time_sorted_ind] = sort(time_norm,"descend"); 
% data_all = [time_norm(time_sorted_ind),feature_matrix(time_sorted_ind,18)];
Nmin = 10;
eps = Estimate_Epsilon(data_all,Nmin);
% labels = optics_with_clustering(data_all,Nmin,eps);

figure;
labels = optics_with_clustering(data_all,Nmin,eps);
show_3D_clustering(data_all,labels);
xlim([0,1])
ylim([0,1])
zlim([0,1])
[labels,final_ellipsoids] = optics_by_block(labels,data_all,Nmin,eps,500,300);
figure;
show_3D_clustering(data_all,labels);
hold on
for elips_ind = 1:length(final_ellipsoids(:,1))
    elips = final_ellipsoids(elips_ind,:);
    ellipsoid_create(elips(4),elips(5),elips(6),elips(1),elips(2),elips(3));
    title(['Found ' num2str(length(final_ellipsoids(:,1))) ' cluster ellipsoids' ]);
end
labels = optics_by_block(data_all,Nmin,eps,500,250);
labels = optics_with_clustering(data_all,Nmin,eps);
show_3D_clustering(data_all,labels);
[ center, radii, evecs, v, chi2 ] = ellipsoid_fit( data_all,'' );
% ellipsoid(center(1),center(2),center(3),radii(1),radii(2),radii(3))
u_labels = unique(labels(labels>0));
for clust_ind  = 1:length(u_labels)
    clust_data = data_all(labels==u_labels(clust_ind),:);
%     center = mean(clust_data);
%     %% Get limits of cluster
%     mins = min(clust_data);
%     maxs = max(clust_data);
%     radii = (maxs-mins)/2;

    [ center, radii, evecs, v, chi2 ] = ellipsoid_fit( clust_data,'' );

%     ellipsedata3(data_all,cov(data_all),20,1,5);

    hold on
    [x,y,z] = ellipsoid(center(1),center(2),center(3),radii(1),radii(2),radii(3));
    h = surf(x,y,z);
    hold on
    evecs
    direction = [1 0 0];

    rotate(h,direction,evecs(1,1)*180/pi,center)
end
% show_3D_clustering(data_all,labels);
labels = optics_by_block(data_all,Nmin,eps,500,250);
show_3D_clustering(data_all,labels);

figure

iter = 0;
clustersMatrix = zeros(50,50);
colorMatrix=zeros(50,50);
prevCluster=zeros(crosPointNum,1);
newClustInd=0;

% podesavanje zadnjeg intervala
totalStages = floor((size(data_all,1)-crosPointNum)/(boxSize-crosPointNum));
%totalStages =9;

firstStage = 0;
iter=0;

for step = firstStage:totalStages-1

% iter= 0 -> 1:1000
% iter= 1 -> 751:1750
% iter= 3 -> 1751:2500

data = data_all(step*(boxSize-crosPointNum)+1:(step+1)*(boxSize)-step*crosPointNum,:);    


% figure
% scatter( data(:,2), data(:,1), 'b','.');
% title('Input data');
% ylabel('frequency, kHz');
% xlabel('time, h');
% axis([ min(data(:,2)) max(data(:,2)) 50 350]);
% set(gca,'Box','on');


tic
[orderedList, reachDistList, coreDistList, procesList] = optics(data, Nmin, eps);
toc

 for i = 1:size(data,1)
     orderedReachList(i,1) = reachDistList(orderedList(i));
 end
 

% figure
% plot(orderedReachList);
% title('Ordered reachability-distance list');
% ylabel('Reachability distance');
% xlabel('Ordered index');


large_cluster_perc = 0.9;
merge_perc = 0.8;

tic
[SetClusters, clustnum] = gradient_clustering( orderedReachList, Nmin, t, w, large_cluster_perc, merge_perc, type );
toc

clusterIndices=getClusterIndices(orderedList, SetClusters, clustnum);

[clustersMatrix, prevCluster, newClustInd, newClustTest, colorMatrix] = optics_merging(clusterIndices, clustersMatrix, prevCluster,  crosPointNum, clustnum, newClustInd, iter, step, colorMatrix);
iter=1;


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

[timeMin, timeMax, yMinStart, yMinEnd, yMaxStart, yMaxEnd] = feature_extraction(data, clusterIndices, clustnum, timeStampEnd, timeStampStart, crosPointNum, newClustTest, prevClustVect, currClustVect, prevyMaxEnd, prevyMinEnd, Nmin);
prevyMaxEnd = yMaxEnd;
prevyMinEnd = yMinEnd;

timeStampStart = timeStampEnd;

colors = ['b','r','g','y','c','m','k'];

colormaps = ['Blues','BuGn','BuPu','GnBu','Greens','Reds','OrRd','Oranges','PuBu'];
cstart = [1,6,10,14,18,24,28,32,39];
cend = [5,9,13,17,23,27,31,38,42];

if clustnum ~=0 
       %line([data(boxSize,2) data(boxSize,2)],[50 350],'Color','red','LineStyle','--');
       %line([data(1,2) data(1,2)],[50 350],'Color','blue','LineStyle','--');
       %line([timeStampEnd timeStampEnd],[50 350],'Color','blue','LineStyle','--');
       %line([timeStampStart timeStampStart ],[50 350],'Color','red','LineStyle','--');
     for i=1:clustnum 
        index = clusterIndices(:)==i;
        ylim([ 0 700]);        
        %scatter(data(index,2),data(index,1),'.',colors(mod(clustersMatrix(i,step+1)-1,7)+1)); 
        %scatter(data(index_ordered,2),data(index_ordered,1),'.');
        
        hold on
        
        %line([timeMin(i) timeMax(i)], [yMinStart(i) yMinEnd(i)], 'color', colors(mod(clustersMatrix(i,step+1)-1,7)+1));
        %line([timeMin(i) timeMax(i)], [yMaxStart(i) yMaxEnd(i)], 'color', colors(mod(clustersMatrix(i,step+1)-1,7)+1));
        %fill([timeMin(i) timeMax(i) timeMax(i) timeMin(i) ],[yMinStart(i) yMinEnd(i) yMaxEnd(i) yMaxStart(i) ], colors(mod(colorMatrix(i,step+1)-1,7)+1));
        fill([timeMin(i) timeMax(i) timeMax(i) timeMin(i) ],[yMinStart(i) yMinEnd(i) yMaxEnd(i) yMaxStart(i) ], colors(mod(clustersMatrix(i,step+1)-1,7)+1));
        %colors2 = brewermap(max(SetClusters(:,3)),colormaps(cstart(clustersMatrix(i,step+1)):cend(clustersMatrix(i,step+1))));
        %fill(x,y,colors2(numel(index)-1,:));
        %colormap(brewermap(256,colormaps(cstart(i):cend(i))));
     end    
end

%  
end 


 