%% Normalize features
[~,dataset_names,feature_matrix_paths] = Get_Dataset_Paths();
fig_folder = 'C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\figures\preprocessing\';
addpath 'C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\clustering\Word_support'
mins = zeros(1,23);
maxs = zeros(1,23);

mins(7) = -0.36e-6;
maxs([1,4,23]) = 515e-6;
maxs([2,3,22]) = 350;
maxs(5) = 100e-3;
maxs([6,17,18,21,9]) = 1e6;
maxs(7) = 20e-3;
maxs(8) = -0.126e-6;
maxs(10) = 4e6;
maxs(11) = 2.4e-6;
maxs(12) = 3.7e-12;
maxs([13:16]) = 1;
maxs(19) = 4.35e-3;
maxs(20) = 10;

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

    feat_units = {'s','#','#','s',...
        'V','Hz','V','dB','Hz',...
        'Hz', 'Vs', 'aJ', '%','%',...
        '%','%','Hz','Hz','V','#','Hz',...
         '#', 's'};


Style='Naslov 2';
title_str='Distribucije u svim skupovima podataka nakon normalizacije:';

WordFileName='Distribucije_skupova_podataka_nakon_normalizacije.doc';
CurDir=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\documentation\preprocessing'];
FileSpec = fullfile(CurDir,WordFileName);
[ActXWord,WordHandle]=StartWord(FileSpec);

WordText(ActXWord,title_str,Style,[0,1]);%enter after text

Style = 'Normal';


for dataset_ind = 1:length(dataset_names)
    dataset_path = feature_matrix_paths{dataset_ind};
    clearvars equ_feature_matrix equ_emiss_max_t_hr equ_emiss_max_t
    load(feature_matrix_paths{dataset_ind},'equ_feature_matrix','equ_emiss_max_t');
    equ_emiss_max_t_hr = equ_emiss_max_t./3600;
    
    data_len = length(equ_feature_matrix(:,1));
    norm_equ_feature_matrix = equ_feature_matrix;
    for feat_ind = 1:length(equ_feature_matrix(1,:))
        feature = equ_feature_matrix(:,feat_ind);
        
        %% Plot and save normalized distributions
        Style= 'Naglašeno';   
        end_out_str = ['Distribucija za skup podatak ' dataset_names{dataset_ind}  ' :'];
        WordText(ActXWord,end_out_str,Style,[0,1]);%enter after tex

        sorted_feat_data = sort(equ_feature_matrix(:,feat_ind));
        perc5 = sorted_feat_data(floor(0.02*data_len));
        perc95 = sorted_feat_data(ceil(0.98*data_len));
        perc50 = sorted_feat_data(floor(0.5*data_len));
        cut_off = (perc95 - perc5)*1.5;
        outliers_thresh_high = perc95+cut_off;
        outliers_thresh_low = perc5-cut_off;
        
        figure;
        subplot(2,2,1);
        hold on
        scatter3(equ_emiss_max_t_hr, equ_feature_matrix(:,feat_ind),1:length(equ_emiss_max_t_hr), 8, 'blue', 'filled');
        yline(perc50,'Color','k','LineStyle','--','LineWidth',2)
        yline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
        yline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
%         legend(['equalized ' feat_names{feat_ind}],['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'')
        grid on
        xlabel('time [h]')
        ylabel_str = [feat_names{feat_ind} ' [' feat_units{feat_ind} ']'];
        ylabel_str(1) = upper(ylabel_str(1));
        ylabel(ylabel_str)
        ylim([min([outliers_thresh_low,sorted_feat_data(1)])*1.1,max([outliers_thresh_high,sorted_feat_data(end)])*1.1]);
        xlim([0 max([max(equ_emiss_max_t_hr), max(equ_emiss_max_t_hr)])])
        
        title(['Distr. of ' feat_names{feat_ind} ' through time']);
        saveas(gcf, [fig_folder dataset_names{dataset_ind} '_equalized_' feat_names_conn{feat_ind} '_in_time_removed_outliers'], 'fig')

        %% Show distribution per 10% of samples and statistical properties: mean, std, perc10, perc 90
        subplot(2,2,2);
        grid on
        histogram(equ_feature_matrix(:,feat_ind),'Normalization','probability');
        xline(perc50,'Color','k','LineStyle','--','LineWidth',2)
        xline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
        xline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
%         legend('',['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'');
        title(['Histogram of ' feat_names{feat_ind} ' distribution']);
        xlabel(ylabel_str)
        xlim([min([outliers_thresh_low,sorted_feat_data(1)])*1.1,max([outliers_thresh_high,sorted_feat_data(end)])*1.1]);
        ylabel('Percentage of feature points / 100')
        saveas(gcf, [fig_folder dataset_names{dataset_ind} '_equalized_' feat_names_conn{feat_ind} '_histogram_with_outliers'], 'fig')

        %% Normalizing
        over_max_ind = find(feature > maxs(feat_ind));
        under_min_ind = find(feature < mins(feat_ind));
        equ_feature_matrix(over_max_ind,feat_ind) = maxs(feat_ind);
        equ_feature_matrix(under_min_ind,feat_ind) = mins(feat_ind);
        equ_feature_matrix(:,feat_ind) = (feature-mins(feat_ind))/(maxs(feat_ind)-mins(feat_ind));
        outliers_thresh_high = (outliers_thresh_high-mins(feat_ind))/(maxs(feat_ind)-mins(feat_ind));
        outliers_thresh_low = (outliers_thresh_low-mins(feat_ind))/(maxs(feat_ind)-mins(feat_ind));
        perc50 = (perc50-mins(feat_ind))/(maxs(feat_ind)-mins(feat_ind));

        subplot(2,2,3);
        hold on
        scatter3(equ_emiss_max_t_hr, equ_feature_matrix(:,feat_ind),1:length(equ_emiss_max_t_hr), 8, 'blue', 'filled');
        yline(perc50,'Color','k','LineStyle','--','LineWidth',2)
        yline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
        yline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
%         legend(['equalized ' feat_names{feat_ind}],['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'')
        grid on
        xlabel('time [h]')
        ylabel_str = [feat_names{feat_ind} ' [' feat_units{feat_ind} ']'];
        ylabel_str(1) = upper(ylabel_str(1));
        ylabel(ylabel_str)
        ylim([0,1.1]);
        xlim([0 max([max(equ_emiss_max_t_hr), max(equ_emiss_max_t_hr)])])
        
        title(['Norm. distr. of ' feat_names{feat_ind} ' through time']);
        saveas(gcf, [fig_folder dataset_names{dataset_ind} '_equalized_' feat_names_conn{feat_ind} '_in_time_removed_outliers'], 'fig')
        

        %% Show distribution per 10% of samples and statistical properties: mean, std, perc10, perc 90
        subplot(2,2,4);
        grid on
        histogram(equ_feature_matrix(:,feat_ind),'Normalization','probability');
        xline(perc50,'Color','k','LineStyle','--','LineWidth',2)
        xline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
        xline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
%         legend('',['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'');
        title(['Norm. histogram of ' feat_names{feat_ind} ' distribution']);
        xlabel(ylabel_str)
%         xlim([min([outliers_thresh_low,sorted_feat_data(1)])*1.1,max([outliers_thresh_high,sorted_feat_data(end)])*1.1]);
        ylabel('Percentage of feature points / 100')
        saveas(gcf, [fig_folder dataset_names{dataset_ind} '_equalized_' feat_names_conn{feat_ind} '_histogram_with_outliers'], 'fig')
   
        FigureIntoWord(ActXWord); %% Write figure
    end
    
    norm_dataset_path = [dataset_path(1:end-4) '_normalized.mat'];
    save(norm_dataset_path,'norm_equ_feature_matrix','equ_emiss_max_t','equ_emiss_max_t_hr');
end

CloseWord(ActXWord,WordHandle,FileSpec);    
close all;
disp('Sucessfully normalized!')