load(['../feature_selection/input_matrices/small_dataset_UAE_equ_features.mat']);
load feature_selection_knee_vars.mat


single_peak = find(equ_feature_matrix(:,20) == 1);
hold on
scatter(equ_emiss_max_t_hr,equ_feature_matrix(:,18),7,'b','filled','o');
scatter(equ_emiss_max_t_hr(single_peak),equ_feature_matrix(single_peak,18),7,'r','filled','o');

correlated_feature_pairs = [18,21];
remove_subs = [];
for sub_ind = 1:length(subsets)
    if 1 < sum(ismember(subsets{sub_ind},correlated_feature_pairs))
        remove_subs = [remove_subs, sub_ind];
    end
end

subsets(remove_subs) = [];
saved_epsilon(remove_subs,:) = [];
saved_Nmin(remove_subs,:) = [];
dbcv_indices(remove_subs,:) = [];

show_subset_ranks_2_0(feature_matrix,dataset_name,vbls,saved_Nmin,saved_epsilon,10,subsets,dbcv_indices,'DBCV',-1,equ_emiss_max_t_hr,equ_feature_matrix);