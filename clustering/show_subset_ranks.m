function show_subset_ranks(dataset,dataset_name,feat_names,Nmins,epsilons,scoring_limit,subsets,validity_indices,index_name,index_min)
    max_eps = strrep(num2str(max(epsilons)),'.','_');
    min_eps = strrep(num2str(min(epsilons)),'.','_');
    max_Nmin = num2str(max(Nmins));
    min_Nmin = num2str(min(Nmins));

    save([ dataset_name '_feature_selection_with_' index_name '_for_Nmin_' min_Nmin '_' max_Nmin '_Eps_' min_eps '_' max_eps ],'validity_indices')

    for ranks = 1:scoring_limit
        [index_sorted,index_sort_ind] = max(validity_indices,[],1);
        [max_val, max_ind] = max(index_sorted);
        best_subset_ind = index_sort_ind(max_ind);
        eps_ind = floor((max_ind-1)/length(Nmins))+1;
        Nmin_ind = max_ind-((eps_ind-1)*length(Nmins));
        epsilon = epsilons(eps_ind);
        Nmin = Nmins(Nmin_ind);
        features = subsets{best_subset_ind};
        
        labels= optics_with_clustering(dataset(:,features),Nmin,epsilon);
        labels(labels<1) = -1;
    
        show_3D_clustering(dataset(:,features),labels);
        xlabel(feat_names{features(1)})
        ylabel(feat_names{features(2)})
        zlabel(feat_names{features(3)})
        title({['Rank: ' num2str(ranks)],['Epsilon is: ' num2str(epsilon) ' , MinNumPoints is: ' num2str(Nmin) ', Index value: ' num2str(max_val)]})
            
        saveas(gcf,['../figures/feature_selection/' dataset_name '_' index_name '_result/' index_name '_features_selected_for_Nmin_' min_Nmin '_' max_Nmin '_Eps_' min_eps '_' max_eps '_rank_' num2str(ranks) ],'fig')
    
        feat_str = ['(' feat_names{features(1)} ', ' feat_names{features(2)} ', ' feat_names{features(3)} ')'];
        disp([num2str(ranks) '. result: ' feat_str ', Epsilon: ' num2str(epsilon) ', MinNumPoints: ' num2str(Nmin) ', ' index_name ' index value: ' num2str(max_val)])
    
        %% Remove best selection
        validity_indices(best_subset_ind,max_ind) = index_min;
    end
end