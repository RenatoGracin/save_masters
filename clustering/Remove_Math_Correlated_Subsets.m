function subsets = Remove_Math_Correlated_Subsets(subsets,correlated_feature_pairs)
    remove_subs = [];
    for sub_ind = 1:length(subsets)
        if 1 < sum(ismember(subsets{sub_ind},correlated_feature_pairs))
            remove_subs = [remove_subs, sub_ind];
        end
    end

    subsets(remove_subs) = [];

end
