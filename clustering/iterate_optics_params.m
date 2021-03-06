function [labels,eps,Nmin,index] = iterate_optics_params(data)

    Nmin = 30;
    eps_min = 0;
    eps_max = 1;

    for steps = 1:3
        
        eps_step = (eps_max-eps_min/4);
        eps_array = [eps_min+eps_step:eps_step:eps_max];

        dbcv_indices = zeros(1,length(eps_array));

        for eps_ind = 1:length(eps_array)
            epsilon = eps_array(eps_ind);

            labels= optics_with_clustering(data,Nmin,epsilon);
            labels(labels<1) = -1;

            if 2 > length(unique(labels(labels~=-1))) || 10 < length(unique(labels(labels~=-1)))
                 disp(['Skipped local comb']);
            else
                valid_indices = find(labels>0);
                data_without_outliers = data(valid_indices,:);
                labels_without_outliers = labels(valid_indices);
                dbcv_indices(eps_ind) = Calculate_DBCV_index(data_without_outliers, labels_without_outliers,length(find(labels<1)));
            end
        end

        [sorted_db, sorted_db_ind] = sort(dbcv_indices,'descend');
        eps_max = eps_array(sorted_db_ind(1));
        eps_second = eps_array(sorted_db_ind(2));     
    end
     



    labels= optics_with_clustering(feature_subset,Nmin,epsilon);
            labels(labels<1) = -1;
     
    
end

