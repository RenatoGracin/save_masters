% load ..\feature_selection\input_matrices\big_dataset_UAE_equ_features.mat

%  Remove rows that have element with inf value
err_rows = [];
equ_emiss_max_t_hr = equ_emiss_max_t./3600;
feature_matrix = equ_feature_matrix;
for feat_ind = 1:length(feature_matrix(1,:))
    x = feature_matrix(:,feat_ind);
    err_ele_ind = find(isinf(x) | isnan(x))';
    if ismember(err_ele_ind,err_rows) == 0
        err_rows = [err_rows,err_ele_ind];
    end
end

%% Find specific emissions based on feature values
feature_matrix(err_rows,:) = [];
equ_feature_matrix(err_rows,:) = [];
equ_emiss_max_t_hr(err_rows) = [];
equ_emiss_max_t(err_rows) = [];

feat_names = {'rise time','counts to','counts from','duration',...
        'peak amplitude','average frequency','rms','asl','reverbation frequency',...
        'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',...
        'pp3','pp4','centroid frequency','peak frequency','amp of peak frequency','num of freq peaks','weighted peak frequency',...
        'total counts','fall time'};

% Standardization
for feat_ind = 1:length(feature_matrix(1,:))
    % Standardization with z-score using formula x_norm = (x-mean(x))/std(x);
    % link: https://www.indeed.com/career-advice/career-development/how-to-calculate-z-score
    x = feature_matrix(:,feat_ind);
    feature_matrix(:,feat_ind) = (x-mean(x))/std(x);
%     feature_matrix(:,feat_ind) = (x-min(x))/(max(x)-min(x));
end
for feat_ind = 1:23
    figure
    grid on
    histogram(feature_matrix(:,feat_ind),'Normalization','probability');
    %         feat_mean = mean(equ_feature_matrix(:,feat_ind));
    %         feat_std_3 = 3*std(equ_feature_matrix(:,feat_ind));
    data_len = length(feature_matrix(:,1));
    sorted_feat_data = sort(feature_matrix(:,feat_ind));
    perc50 = sorted_feat_data(floor(0.5*data_len));
    perc10 = sorted_feat_data(floor(0.10*data_len));
    perc90 = sorted_feat_data(ceil(0.90*data_len));
    cut_off = (perc90 - perc10)*1.25;
    outliers_thresh_high = perc90+cut_off;
    outliers_thresh_low = perc10-cut_off;
    xline(perc50,'Color','k','LineStyle','--','LineWidth',2)
    xline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
    xline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
    legend('',['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low) ' , ' num2str(outliers_thresh_high) ']'],'');
    title(['Histogram of zscore ' feat_names{feat_ind} ' distribution']);
    xlabel(feat_names{feat_ind})
    ylabel('Percentage of feature points / 100')
end