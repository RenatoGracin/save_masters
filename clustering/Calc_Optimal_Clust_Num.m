function [OptimalK] = Calc_Optimal_Clust_Num(dataset,cluster_indices)
%OPTIMALNUMOFCLUSTERS Summary of this function goes here
%   Detailed explanation goes here
eval_Ks = [];
eva_calinski = evalclusters(dataset,cluster_indices,'CalinskiHarabasz');
eval_Ks = [eval_Ks,eva_calinski.OptimalK];

eva_silh = evalclusters(dataset,cluster_indices,'Silhouette');
eval_Ks = [eval_Ks,eva_silh.OptimalK];

eva_gap = evalclusters(dataset,cluster_indices,'gap');
eval_Ks = [eval_Ks,eva_gap.OptimalK];

eva_davies = evalclusters(dataset,cluster_indices,'DaviesBouldin');
eval_Ks = [eval_Ks,eva_davies.OptimalK];

disp(['Eval Ks: ' num2str(eval_Ks)] )
OptimalK = ceil(mean(eval_Ks));
end

