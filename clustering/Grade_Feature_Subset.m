function Grade_Feature_Subset(data,features,labels,Nmin,eps)
    arguments
        data
        features = []
        labels = []
        Nmin = 10
        eps = 0
    end

    if ~isempty(features)
        vbls = {'rise_time','counts_to','counts_from','duration',...
        'peak_amplitude','average_frequency','rms','asl','reverbation_frequency',...
        'initial_frequency', 'signal_strength', 'absolute_energy', 'pp1','pp2',...
        'pp3','pp4','centroid_frequency','peak_frequency','amp_of_peak_frequency','num_of_freq peaks','weighted_peak_frequency',...
        'total_counts','fall_time'};
        data = data(:,features);
    else
        vbls = {'x','y','z'};
    end

    if eps == 0
        eps = Estimate_Epsilon(data,Nmin);
    end

    if isempty(labels)
        labels = optics_with_clustering(data,Nmin,eps);
%         labels = optics_by_block(data,Nmin,eps);
        show_3D_clustering(data,labels);
    end

    
    if length(unique(labels)) > 10 || length(unique(labels)) < 2
       index(eps_ind) = -1;
       disp('To many or to little cluster!');
       return;
    end

    labels(labels<1) = -1;
    show_3D_clustering(data,labels);
    xlabel(strrep(vbls{features(1)},'_',' '))
    ylabel(strrep(vbls{features(2)},'_',' '))
    zlabel(strrep(vbls{features(3)},'_',' '))

    valid_indices = find(labels>0);
    data_without_outliers = data(valid_indices,:);
    idx_without_outliers = labels(valid_indices);
    global check_holes
    check_holes = 1;
    index =  Calculate_DBCV_index(data_without_outliers, idx_without_outliers,length(find(labels<1)),1);

    title({['Epsilon is: ' num2str(eps) ' , MinNumPoints is: ' num2str(Nmin) ', Index value: ' num2str(index)]})
end