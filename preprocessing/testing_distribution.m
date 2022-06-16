close all
feat_names_conn = {'rise_time','counts_to','counts_from','duration',...
    'peak_amplitude','average_frequency','rms','asl','reverbation_frequency',...
    'initial_frequency', 'signal_strength', 'absolute_energy', 'PP1','PP2',...
    'PP3','PP4','centroid_frequency','peak_frequency','amplitude_of_peak_frequency','num_of_freq peaks','weighted_peak_frequency', ...
     'total_counts', 'fall_time'};

feat_names = {'rise time','counts to','counts from','duration',...
    'peak amplitude','average frequency','rms','asl','reverbation frequency',...
    'initiation frequency', 'signal strength', 'absolute energy', 'PP1','PP2',...
    'PP3','PP4','centroid frequency','peak frequency','amplitude of peak frequency','num of freq peaks','weighted peak frequency',...
     'total counts', 'fall time'};

feat_units = {'[s]','[#]','[#]','[s]',...
    '[V]','[Hz]','[V]','[dB]','[Hz]',...
    '[Hz]', '[Vs]', '[aJ]', '[%]','[%]',...
    '[%]','[%]','[Hz]','[Hz]','[V]','[#]','[Hz]',...
     '[#]', '[s]'};
feat_ind = 16;
%% FEATURES WITH TRUE OUTLIERS
%% RISE TIME, COUNTS TO, DURATION, INITIATION FREQUENCY,PP1,CENTROID FREQUENCY, TOTAL COUNTS, FALL TIME
% features_with_outs = [1,2,4,10,13,17,22,23];
features_with_outs = [1,2,4,6,13,20,22,23];
% features_with_outs = [1:23];
all_out_ind = [];
data_len = length(equ_feature_matrix(:,1));
for i= 1:length(features_with_outs)
    feat_ind = features_with_outs(i);
%     outliers_thresh_high =mean(equ_feature_matrix(:,feat_ind)+3*std(equ_feature_matrix(:,feat_ind)));
%     outliers_thresh_low =mean(equ_feature_matrix(:,feat_ind)-3*std(equ_feature_matrix(:,feat_ind)));
    sorted_feat_data = sort(equ_feature_matrix(:,feat_ind));
    perc10 = sorted_feat_data(floor(0.10*data_len));
    perc90 = sorted_feat_data(ceil(0.90*data_len));
    cut_off = (perc90 - perc10)*1.25;
    outliers_thresh_high = perc90+cut_off;
    outliers_thresh_low = perc10-cut_off;
    disp(outliers_thresh_high)
    feature_matrix = equ_feature_matrix;
    emiss_max_t_hr = equ_emiss_max_t_hr;
    outliers_ind = find(feature_matrix(:,feat_ind)>=outliers_thresh_high | feature_matrix(:,feat_ind)<=outliers_thresh_low);
    all_outliers_ind{i} = outliers_ind;
    all_out_ind  = unique([all_out_ind, outliers_ind']);
    global emissions
%     for ind = 1:length(outliers_ind)
%         figure;
%         plot(emissions{outliers_ind(ind),8},emissions{outliers_ind(ind),7});
%     %     figure;
%     %     plot(emissions{outliers_ind(ind),6},emissions{outliers_ind(ind),5});
%         title([feat_names{feat_ind} ' = ' num2str(feature_matrix(outliers_ind(ind),feat_ind)) ' ' feat_units{feat_ind}]);
%     end
    disp([upper(feat_names{feat_ind}) ' outliers are emissions with value more than ' num2str(outliers_thresh_high) ' ' feat_units{feat_ind}]);
    disp(['Percentage of oultiers for ' upper(feat_names{feat_ind}) ': ' num2str(length(outliers_ind)) '/' num2str(length(emiss_max_t_hr)) ' = ' num2str(100*length(outliers_ind)/length(emiss_max_t_hr)) ' %'])
end

disp(['Percentage of total outliers in dataset: ' num2str(length(all_out_ind)) '/' num2str(length(emiss_max_t_hr)) ' = ' num2str(100*length(all_out_ind)/length(emiss_max_t_hr)) ' %'])

feature_matrix(outliers_ind,:) = [];
emiss_max_t_hr(outliers_ind) = [];

% % % % % % feature_matrix(:,feat_ind) = db(feature_matrix(:,feat_ind));
close all

figure;
hold on
scatter3(emiss_max_t_hr, feature_matrix(:,feat_ind),1:length(emiss_max_t_hr), 8, 'blue', 'filled');
legend(['equalized ' feat_names{feat_ind}])
grid on
xlabel('time [h]')
ylabel_str = [feat_names{feat_ind} ' ' feat_units{feat_ind}];
ylabel_str(1) = upper(ylabel_str(1));
ylabel(ylabel_str)
xlim([0 max([max(emiss_max_t_hr), max(emiss_max_t_hr)])])
box on
title(['Distr. of ' feat_names{feat_ind} ' through time']);
saveas(gcf, ['../figures/preprocessing/features_calculation_results/' log_UAE_fname '_equalized_' feat_names_conn{feat_ind} '_in_time_removed_outliers'], 'fig')

%% Show distribution per 10% of samples and statistical properties: mean, std, perc10, perc 90
figure
grid on
histogram(feature_matrix(:,feat_ind),'Normalization','probability');
feat_mean = mean(feature_matrix(:,feat_ind));
% feat_std_3 = 3*std(feature_matrix(:,feat_ind));
xline(feat_mean,'Color','k','LineStyle','--','LineWidth',2)
xline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
xline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
legend('',['Mean of signal = ' num2str(feat_mean)],['Low and High Tresholds = [' num2str(outliers_thresh_high) ' , ' num2str(outliers_thresh_low) ']'],'');
title(['Histogram of ' feat_names{feat_ind} ' distribution']);
xlabel(ylabel_str)
ylabel('Percentage of feature points / 100')
saveas(gcf, ['../figures/preprocessing/features_calculation_results/' log_UAE_fname '_equalized_' feat_names_conn{feat_ind} '_histogram_removed_outliers'], 'fig')