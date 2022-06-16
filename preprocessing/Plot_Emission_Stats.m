function Plot_Emission_Stats(only_stat,dataset_name,raw_feature_matrix,equ_feature_matrix,raw_emiss_max_t,equ_emiss_max_t,freq_of_fft_peaks)
    global stat_num_interf_LF
    global stat_num_interf_HF
    global all_emissions
    global emission_without_peak_count
    global stat_num_evts
    global dataset_name

    %% Open new word document to save feature distribution results
    addpath('..\clustering\Word_support\')
    WordFileName=[ dataset_name '_feature_distribution_results.doc'];
   
    %% Create folder for dataset figures if it doesn't exist
    dataset_fig_folder = ['../figures/preprocessing/features_calculation_results/' dataset_name '/'];
    if ~exist(dataset_fig_folder, 'dir')
       mkdir(dataset_fig_folder)
    end
    
    %% Create folder for dataset documentation if it doesn't exist
    dataset_doc_folder=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\documentation\preprocessing\' dataset_name ];
    if ~exist(dataset_doc_folder, 'dir')
       mkdir(dataset_doc_folder)
    end
    
    FileSpec = fullfile(dataset_doc_folder,WordFileName);
    %% Delete if Word document already exists
    if exist(FileSpec, 'file')==2
        delete(FileSpec);
    end
    [ActXWord,WordHandle]=StartWord(FileSpec);

    disp(['Saving word to:' FileSpec])

    %% Write headline
    Style='Naslov 1'; %NOTE! if you are using an English version of MSWord use 'Heading 1'. 
    TextString=['Feature statistics and emission type analysis for ' dataset_name];
    WordText(ActXWord,TextString,Style,[0,1]);%two enters after text
    ActXWord.Selection.Font.Size=9; 

    Style = 'Naglašeno';

    %% calculate neutral statistics
    disp(['Total number of emissions: ' num2str(length(equ_emiss_max_t))])

    stat_num_emis = length(equ_emiss_max_t);
    stat_perc_emis = (stat_num_emis ./ stat_num_evts) .* 100;
    stat_perc_interf_LF = (stat_num_interf_LF ./ stat_num_evts) .* 100; 
    stat_perc_interf_HF = (stat_num_interf_HF ./ stat_num_evts) .* 100;

    emiss_stat = ['emissions / events: ' num2str(stat_num_emis), ' / ', num2str(stat_num_evts), ' = ', num2str(stat_perc_emis), '%'];
    disp(emiss_stat);
    LF_stat = ['LF interferences / events: ' num2str(stat_num_interf_LF), ' / ', num2str(stat_num_evts), ' = ', num2str(stat_perc_interf_LF), '%'];
    disp(LF_stat);
    HF_stat = ['HF interferences / events: ' num2str(stat_num_interf_HF), ' / ', num2str(stat_num_evts), ' = ', num2str(stat_perc_interf_HF), '%'];
    disp(HF_stat);

    WordText(ActXWord,emiss_stat,Style,[0,1]);%two enters after text
    WordText(ActXWord,LF_stat,Style,[0,1]);%two enters after text
    WordText(ActXWord,HF_stat,Style,[0,1]);%two enters after text

    stat_perc_emis_without_peaks = (emission_without_peak_count./all_emissions).*100;
    
    emiss_without_peak_stat = ['emission_without_peak_count / all_emissions: ' num2str(emission_without_peak_count), ' / ', num2str(all_emissions), ' = ', num2str(stat_perc_emis_without_peaks), '%'];
    disp(emiss_without_peak_stat);

    WordText(ActXWord,emiss_without_peak_stat,Style,[0,1]);%two enters after text

    valid_emission_count = length(equ_feature_matrix(:,1));
    stat_perc_valid_emis = (valid_emission_count./all_emissions).*100;
    valid_emiss_stat = ['valid_emission_count / all_emissions: ' num2str(valid_emission_count), ' / ', num2str(all_emissions), ' = ', num2str(stat_perc_valid_emis), '%'];
    disp(valid_emiss_stat);
    
    WordText(ActXWord,valid_emiss_stat,Style,[0,1]);%two enters after text

    equ_emiss_max_t_hr = equ_emiss_max_t./3600;
    
    %% Plot distribution of frequency amplitude with single peaks in time
    figure;
    hold on
    multi_indices = find(equ_feature_matrix(:,20) > 1);
    scatter(equ_emiss_max_t_hr(multi_indices), equ_feature_matrix(multi_indices,18), 4, 'r', 'filled');
    broad_band_indices = find(equ_feature_matrix(:,20) == 0);
    scatter(equ_emiss_max_t_hr(broad_band_indices), equ_feature_matrix(broad_band_indices,18), 4, 'y', 'filled');
    single_indices = find((equ_feature_matrix(:,20) == 1));
    scatter(equ_emiss_max_t_hr(single_indices), equ_feature_matrix(single_indices,18), 4, 'k', 'filled');
    single_200k_num = sum(equ_feature_matrix(single_indices,18) > 175e3 & equ_feature_matrix(single_indices,18)<250e3);
    legend('multi peak emissions','broadband emissions','single peak emissions')
    grid on
    xlabel('time [h]')
    ylabel('peak frequency [Hz]')
    xlim([0 max(equ_emiss_max_t_hr)])
    box on
    title_str = 'Distr. of peak frequency of emission through time';
    title(title_str)
    saveas(gcf, [dataset_fig_folder dataset_name '_peak_freq_in_time_only_single'], 'fig')
    
    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure

    %% Plot distribution of frequency amplitude with single and multiple peaks in time
    figure;
    hold on
    multi_indices = find(equ_feature_matrix(:,20) > 1);
    mutiple_peak_first_freq = cellfun(@(v)v(1),freq_of_fft_peaks);
    mutiple_peak_second_freq = cellfun(@(v)v(2),freq_of_fft_peaks);
    mutiple_peak_third_freq = cellfun(@(v)v(3),freq_of_fft_peaks);
    scatter(equ_emiss_max_t_hr(multi_indices), mutiple_peak_third_freq(multi_indices), 4, 'g', 'filled');
    scatter(equ_emiss_max_t_hr(multi_indices), mutiple_peak_second_freq(multi_indices), 4, 'b', 'filled');
    scatter(equ_emiss_max_t_hr(multi_indices), mutiple_peak_first_freq(multi_indices), 4, 'r', 'filled');
    broad_band_indices = find(equ_feature_matrix(:,20) == 0);
    scatter(equ_emiss_max_t_hr(broad_band_indices), equ_feature_matrix(broad_band_indices,18), 4, 'y', 'filled');
    single_indices = find((equ_feature_matrix(:,20) == 1));
    scatter(equ_emiss_max_t_hr(single_indices), equ_feature_matrix(single_indices,18), 4, 'k', 'filled');
    single_200k_num = sum(equ_feature_matrix(single_indices,18) > 175e3 & equ_feature_matrix(single_indices,18)<250e3);
    legend('multi peak emissions - third peak','multi peak emissions - second peak','multi peak emissions - first peak','broadband emissions','single peak emissions')
    grid on
    xlabel('time [h]')
    ylabel('peak frequency [Hz]')
    xlim([0 max(equ_emiss_max_t_hr)])
    box on
    title_str = 'Distr. of peak frequency of emission through time with multi peaks marked';
    title(title_str)
    
    saveas(gcf, [dataset_fig_folder dataset_name '_peak_freq_in_time_with_multiple'], 'fig')
    
    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure

    broadband_stat = ['broadband emissions / emissions: ' num2str(length(broad_band_indices)) '/' num2str(length(equ_emiss_max_t_hr)) ' = ' num2str(length(broad_band_indices)/(length(equ_emiss_max_t_hr))*100) '%'];
    disp(broadband_stat);
    single_stat = ['single-component emissions / emissions: ' num2str(length(single_indices)) '/' num2str(length(equ_emiss_max_t_hr)) ' = ' num2str(length(single_indices)/(length(equ_emiss_max_t_hr))*100) '%'];
    disp(single_stat);
    multi_stat = ['multi-component emissions / emissions: ' num2str(length(multi_indices)) '/' num2str(length(equ_emiss_max_t_hr)) ' = ' num2str(length(multi_indices)/length(equ_emiss_max_t_hr)*100) '%'];
    disp(multi_stat);
    single_200k_stat = ['single-component emissions between 175 kHz and 250 kHz: ' num2str(single_200k_num) '/' num2str(length(single_indices))];
    disp(single_200k_stat);

    WordText(ActXWord,broadband_stat,Style,[0,1]);%enter after text
    WordText(ActXWord,single_stat,Style,[0,1]);%enter after text
    WordText(ActXWord,multi_stat,Style,[0,1]);%enter after text
    WordText(ActXWord,single_200k_stat,Style,[0,1]);%enter after text

    % raw features of AE
    if ~isempty(raw_feature_matrix)
        raw_UAE_rise_series = raw_feature_matrix(:,1); % RISE TIME [s]
        raw_UAE_counts_to_series = raw_feature_matrix(:,2); % COUNTS to peak
        raw_UAE_counts_from_series = raw_feature_matrix(:,3); % COUNTS from peak
        raw_UAE_dur_series = raw_feature_matrix(:,4); % DURATION [s]
        raw_UAE_peak_amp_series = raw_feature_matrix(:,5); % PEAK AMPLITUDE [dB]
        raw_UAE_avg_freq_series = raw_feature_matrix(:,6); % AVERAGE(ABSOLUTE) FREQUENCY [Hz]
        raw_UAE_rms_series = raw_feature_matrix(:,7); % ROOT MEAN SQUARE VOLTAGE [uV]
        raw_UAE_asl_series = raw_feature_matrix(:,8); % AVERAGE SIGNAL LEVEL [dB]
        raw_UAE_reverb_freq_series = raw_feature_matrix(:,9); % REVERBERATION FREQUENCY [Hz]
        raw_UAE_init_freq_series = raw_feature_matrix(:,10); % INITIATION FREQUENCY [Hz]
        raw_UAE_sig_strength_series = raw_feature_matrix(:,11); % SIGNAL STRENGTH [Vs]
        raw_UAE_abs_eng_series = raw_feature_matrix(:,12); % ABSOLUTE ENERGY [aJ]
        raw_UAE_pp1_freq_series = raw_feature_matrix(:,13); % PARTIAL POWER 0-100 kHz of FREQUENCY SPECTRUM [%]
        raw_UAE_pp2_freq_series = raw_feature_matrix(:,14); % PARTIAL POWER 100-200 kHz of FREQUENCY SPECTRUM [%]
        raw_UAE_pp3_freq_series = raw_feature_matrix(:,15); % PARTIAL POWER 200-400 kHz of FREQUENCY SPECTRUM [%]
        raw_UAE_pp4_freq_series = raw_feature_matrix(:,16); % PARTIAL POWER 400-800 kHz of FREQUENCY SPECTRUM [%]
        raw_UAE_centroid_freq_series = raw_feature_matrix(:,17); % FREQUENCY CENTROID [Hz]
        raw_UAE_peak_freq_series = raw_feature_matrix(:,18); % PEAK FREQUENCY [Hz]
        raw_UAE_amp_of_peak_freq_series = raw_feature_matrix(:,19); % AMPLITUDE OF PEAK FREQUENCY [Hz]
        raw_UAE_num_of_freq_peaks_series = raw_feature_matrix(:,20); % NUM OF FREQUENCY PEAKS [Hz]
        raw_UAE_weighted_peak_freq_series = raw_feature_matrix(:,21); % WEIGHTED PEAK FREQUENCY [Hz]
        raw_UAE_total_counts_series = raw_feature_matrix(:,22); % TOTAL COUNTS [#]
        raw_UAE_fall_time_series = raw_feature_matrix(:,23); % FALL TIME [s]
    end
    
    
    % equalized features of AE
    if ~isempty(equ_feature_matrix)
        equ_UAE_rise_series = equ_feature_matrix(:,1); % RISE TIME [s]
        equ_UAE_counts_to_series = equ_feature_matrix(:,2); % COUNTS to peak
        equ_UAE_counts_from_series = equ_feature_matrix(:,3); % COUNTS from peak
        equ_UAE_dur_series = equ_feature_matrix(:,4); % DURATION [s]
        equ_UAE_peak_amp_series = equ_feature_matrix(:,5); % PEAK AMPLITUDE [dB]
        equ_UAE_avg_freq_series = equ_feature_matrix(:,6); % AVERAGE(ABSOLUTE) FREQUENCY [Hz]
        equ_UAE_rms_series = equ_feature_matrix(:,7); % ROOT MEAN SQUARE VOLTAGE [uV]
        equ_UAE_asl_series = equ_feature_matrix(:,8); % AVERAGE SIGNAL LEVEL [dB]
        equ_UAE_reverb_freq_series = equ_feature_matrix(:,9); % REVERBERATION FREQUENCY [Hz]
        equ_UAE_init_freq_series = equ_feature_matrix(:,10); % INITIATION FREQUENCY [Hz]
        equ_UAE_sig_strength_series = equ_feature_matrix(:,11); % SIGNAL STRENGTH [Vs]
        equ_UAE_abs_eng_series = equ_feature_matrix(:,12); % ABSOLUTE ENERGY [aJ]
        equ_UAE_pp1_freq_series = equ_feature_matrix(:,13); % PARTIAL POWER 0-100 kHz of FREQUENCY SPECTRUM [%]
        equ_UAE_pp2_freq_series = equ_feature_matrix(:,14); % PARTIAL POWER 100-200 kHz of FREQUENCY SPECTRUM [%]
        equ_UAE_pp3_freq_series = equ_feature_matrix(:,15); % PARTIAL POWER 200-400 kHz of FREQUENCY SPECTRUM [%]
        equ_UAE_pp4_freq_series = equ_feature_matrix(:,16); % PARTIAL POWER 400-800 kHz of FREQUENCY SPECTRUM [%]
        equ_UAE_centroid_freq_series = equ_feature_matrix(:,17); % FREQUENCY CENTROID [Hz]
        equ_UAE_peak_freq_series = equ_feature_matrix(:,18); % PEAK FREQUENCY [Hz]
        equ_UAE_amp_of_peak_freq_series = equ_feature_matrix(:,19); % AMPLITUDE OF PEAK FREQUENCY [Hz]
        equ_UAE_num_of_freq_peaks_series = equ_feature_matrix(:,20); % NUM OF FREQUENCY PEAKS [Hz]
        equ_UAE_weighted_peak_freq_series = equ_feature_matrix(:,21); % WEIGHTED PEAK FREQUENCY [Hz]
        equ_UAE_total_counts_series = equ_feature_matrix(:,22); % TOTAL COUNTS [#]
        equ_UAE_fall_time_series = equ_feature_matrix(:,23); % FALL TIME [s]
    end

       % Show print only statistics don't show or save plots
    if only_stat
        return
    end

    %%%%%%%%%%%%%%%%%%%%%%% PLOTING STATISTICS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
    %% color map
    my_cool = cool(128);
    my_hot = hot(128);
    my_parula = parula(128);
    custom_hot = my_hot(1:96, :);
    inv_cmap = flipud(custom_hot);
    prop_cmap = custom_hot;
    
    %% plot all features through timespan of all events
    raw_emiss_max_t_hr = (raw_emiss_max_t) ./ 3600;
    equ_emiss_max_t_hr = (equ_emiss_max_t) ./ 3600;
   
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

    feat_num = length(equ_feature_matrix(1,:));

    Style='Naslov 1'; %NOTE! if you are using an English version of MSWord use 'Heading 1'. 
    ActXWord.Selection.InsertNewPage; 
    TextString=['Feature distribution and analysis for ' dataset_name];
    WordText(ActXWord,TextString,Style,[0,1]);%two enters after text

    for feat_ind = 1:feat_num

        rank_feats_str = [ upper(feat_names_conn{feat_ind}) ':'];
        WordText(ActXWord,rank_feats_str,Style,[0,1]);%enter after text

        figure;
        hold on
        scatter3(equ_emiss_max_t_hr, equ_feature_matrix(:,feat_ind),1:length(equ_emiss_max_t_hr), 8, 'blue', 'filled');
        legend(['equalized ' feat_names{feat_ind}])
        grid on
        xlabel('time [h]')
        ylabel_str = [feat_names{feat_ind} ' ' feat_units{feat_ind}];
        ylabel_str(1) = upper(ylabel_str(1));
        ylabel(ylabel_str)
        xlim([0 max([max(equ_emiss_max_t_hr), max(equ_emiss_max_t_hr)])])
        box on
        title(['Distr. of ' feat_names{feat_ind} ' through time']);
        saveas(gcf, [dataset_fig_folder dataset_name '_equalized_' feat_names_conn{feat_ind} '_in_time'], 'fig')

        FigureIntoWord(ActXWord); %% Write figure

        %% Show distribution per 10% of samples and statistical properties: mean, std, perc10, perc 90
        figure
        grid on
        histogram(equ_feature_matrix(:,feat_ind),'Normalization','probability');
%         feat_mean = mean(equ_feature_matrix(:,feat_ind));
%         feat_std_3 = 3*std(equ_feature_matrix(:,feat_ind));
        data_len = length(equ_feature_matrix(:,1));
        sorted_feat_data = sort(equ_feature_matrix(:,feat_ind));
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
        title(['Histogram of ' feat_names{feat_ind} ' distribution']);
        xlabel(ylabel_str)
        ylabel('Percentage of feature points / 100')
        saveas(gcf, [dataset_fig_folder dataset_name '_equalized_' feat_names_conn{feat_ind} '_histogram'], 'fig')

        FigureIntoWord(ActXWord); %% Write figure
        ActXWord.Selection.InsertNewPage; 

%         Find_Outliers(equ_feature_matrix,equ_emiss_max_t_hr,feat_ind,ActXWord,dataset_fig_folder);
    end

    %% EQUALIZED statistics
    disp('--------------------------------------------------------------------')
    disp('Equalized characteristic of emissions...')
    
    %% Time-amplitude-frequency 
    figure;
    hold on    
    scatter(equ_emiss_max_t_hr, equ_UAE_peak_amp_series, 4, (equ_UAE_peak_freq_series ./ 1e3), 'filled');
    grid on
    xlabel('time, hours')
    ylabel('amplitude, V')
    title_str = 'Time-amplitude distr. of equalized emission frequencies (kHz)';
    title(title_str)
    xlim([0 max(equ_emiss_max_t_hr)])
    caxis([100 400])
    colorbar
    colormap("turbo")
    box on
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_time_amp_freq'], 'fig')

    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure
    
         
    %% time-frequency-amplitude maximums
    figure;
    hold on    
    scatter(equ_emiss_max_t_hr, equ_UAE_peak_freq_series, 4, equ_UAE_peak_amp_series, 'filled');
    grid on
    xlabel('time, hours')
    ylabel('frequency, kHz')
    yticks(1e3.*[0 200 400 600 800 1000])
    yticklabels({'0', '200', '400', '600', '800', '1000'})
    title_str = 'Time-frequency of max amp distr.of equalized emission time amplitudes (V)';
    title(title_str)
    xlim([0 max(equ_emiss_max_t_hr)])
    ylim([0 1e6])
    caxis([min(equ_UAE_peak_amp_series) 5.0*median(equ_UAE_peak_amp_series)])
%     caxis([min(equ_UAE_peak_amp_series) max(equ_UAE_peak_amp_series)])
    colorbar
    colormap(inv_cmap)
    box on
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_time_freq_amp'], 'fig')

    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure

    %% time-frequency-max_freq
    figure;
    hold on    
    scatter(equ_emiss_max_t_hr, equ_UAE_peak_freq_series, 4, equ_UAE_amp_of_peak_freq_series, 'filled');
    grid on
    xlabel('time, hours')
    ylabel('frequency, kHz')
    yticks(1e3.*[0 200 400 600 800 1000])
    yticklabels({'0', '200', '400', '600', '800', '1000'})
    title_str = 'Time-frequency distr. of equalized emission amplitude of peak frequencies (V)';
    title(title_str)
    xlim([0 max(equ_emiss_max_t_hr)])
    ylim([0 1e6])
    caxis([min(equ_UAE_amp_of_peak_freq_series) 5.0*median(equ_UAE_amp_of_peak_freq_series)])
%     caxis([min(equ_UAE_amp_of_peak_freq_series) max(equ_UAE_amp_of_peak_freq_series)])
    colorbar
    colormap(inv_cmap)
    box on
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_time_freq_amp_of_peak_freq'], 'fig')

    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure

    %% time-frequency-duration
    figure;
    hold on    
    scatter(equ_emiss_max_t_hr, equ_UAE_peak_freq_series, 4, (equ_UAE_dur_series .* 1e6), 'filled');
    grid on
    xlabel('time, hours')
    ylabel('frequency, kHz')
    yticks(1e3.*[0 200 400 600 800 1000])
    yticklabels({'0', '200', '400', '600', '800', '1000'})
    title_str = 'Time-frequency distr. of equalized durations (us)';
    title(title_str)
    xlim([0 max(equ_emiss_max_t_hr)])
    ylim([0 1e6])
    caxis([min(equ_UAE_dur_series), 300*1e-6] .* 1e6)
    colorbar
    colormap("turbo")
    box on
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_time_freq_dur'], 'fig')
    
    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure
    
    %% time-duration-frequency
    figure;
    hold on    
    scatter(equ_emiss_max_t_hr, (equ_UAE_dur_series .* 1e6), 4, (equ_UAE_peak_freq_series ./ 1e3), 'filled');
    grid on
    xlabel('time, hours')
    ylabel('emission duration, us')
    title_str = 'Time-duration distr. of equalized peak frequencies (kHz)';
    title(title_str)
    xlim([0 max(equ_emiss_max_t_hr)])
    ylim([min(equ_UAE_dur_series), max(equ_UAE_dur_series)] .* 1e6)
    caxis([100 400])
    colorbar
    colormap("turbo")
    box on
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_time_dur_freq'], 'fig')

    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure

     %% time-duration-amplitude of peak frequency
    figure;
    hold on    
    scatter(equ_emiss_max_t_hr, equ_UAE_peak_freq_series, 4, equ_UAE_num_of_freq_peaks_series, 'filled');
    grid on
    xlabel('time, hours')
    ylabel('emission duration, us')
    title_str = 'Time-peak freq distr. of equalized frequencies of num of freq peaks';
    title(title_str)
    xlim([0 max(equ_emiss_max_t_hr)])
    ylim([min(equ_UAE_peak_freq_series), max(equ_UAE_peak_freq_series)])
    caxis([min(equ_UAE_num_of_freq_peaks_series) max(equ_UAE_num_of_freq_peaks_series)])
    colorbar
    colormap("turbo")
    box on
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_time_peak_freq_and_num_of_freq'], 'fig')
    
    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure
    
    %% hourly event rate
        
    % discrete hour axis
    hr_start = floor(0./ 3600);
    equ_hours_n = hr_start:floor(max(floor(equ_emiss_max_t_hr)));
    num_hrs = length(equ_hours_n);
    equ_event_rate_hr = zeros(num_hrs, 1);
    
    for hr_ind = 1:num_hrs    
        equ_event_rate_hr(hr_ind) = length(find( floor(equ_emiss_max_t_hr) == equ_hours_n(hr_ind) ));
    end
    
    figure;
    bar(equ_hours_n, equ_event_rate_hr)
    grid on
    title_str = 'Equalized hourly emission rate';
    title(title_str)
    xlim([0 (max(equ_hours_n)+1)])
    xlabel('time, hours')
    ylabel('equalized emissions / hour')
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_hourly_emission_rate'], 'fig')

    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure

    %% cumulative number of emissions
    equ_cumul_events_hr = cumsum(equ_event_rate_hr);
    
    figure;
    bar(equ_hours_n, equ_cumul_events_hr)
    grid on
    title_str = 'Cumulative equalized emission count';
    title(title_str)
    xlim([0 (max(equ_hours_n)+1)])
    xlabel('time, hours')
    ylabel('total equalized emissions')
    saveas(gcf, [dataset_fig_folder dataset_name '_equ_cumul_emissions_count'], 'fig')

    WordText(ActXWord,title_str,Style,[0,1]);%enter after text
    FigureIntoWord(ActXWord); %% Write figure

    %% Close and save word document results
    CloseWord(ActXWord,WordHandle,FileSpec);    
    close all;

    %% Raw distributions
%     for feat_ind = 1:feat_num
%         figure;
%         hold on
%         scatter3(raw_emiss_max_t_hr, raw_feature_matrix(:,feat_ind),1:length(raw_emiss_max_t_hr), 8, 'blue', 'filled');
%         legend(['raw ' feat_names{feat_ind}])
%         grid on
% 
%         xlabel('time [h]')
%         ylabel_str = [feat_names{feat_ind} ' ' feat_units{feat_ind}];
%         ylabel_str(1) = upper(ylabel_str(1));
%         ylabel(ylabel_str)
%         xlim([0 max([max(raw_emiss_max_t_hr), max(raw_emiss_max_t_hr)])])
%         box on
%         title(['Distr. of ' feat_names{feat_ind} ' through time']);
%         saveas(gcf, ['../figures/preprocessing/features_calculation_results/' log_UAE_fname '_raw_' feat_names_conn{feat_ind} '_in_time'], 'fig')
%     end
    
    %% RAW statistics
%     disp('--------------------------------------------------------------------')
%     disp('Raw characteristic of emissions...')
%     
%     %% Time-amplitude-frequency 
%     figure;
%     hold on    
%     scatter(raw_emiss_max_t_hr, raw_UAE_peak_amp_series, 4, (raw_UAE_peak_freq_series ./ 1e3), 'filled');
%     grid on
%     xlabel('time, hours')
%     ylabel('amplitude, V')
%     title('Time-amplitude distr. of raw emission frequencies (kHz) ')
%     xlim([0 max(raw_emiss_max_t_hr)])
%     caxis([100 400])
%     colorbar
%     colormap(prop_cmap)
%     box on
%     saveas(gcf, ['../figures/preprocessing/raw_stat/' log_UAE_fname '_raw_time_amp_freq'], 'fig')
%     
%          
%     %% time-frequency-amplitude maximums
%     figure;
%     hold on    
%     scatter(raw_emiss_max_t_hr, raw_UAE_peak_freq_series, 4, raw_UAE_peak_amp_series, 'filled');
%     grid on
%     xlabel('time, hours')
%     ylabel('frequency, kHz')
%     yticks(1e3.*[0 200 400 600 800 1000])
%     yticklabels({'0', '200', '400', '600', '800', '1000'})
%     title('Time-frequency distr. of raw emission amplitudes (V)')
%     xlim([0 max(raw_emiss_max_t_hr)])
%     ylim([0 1e6])
%     %caxis([min(UAE_max_y_series) 0.1.*max(UAE_max_y_series)])
% %     caxis([min(raw_UAE_peak_amp_series) 5.0*median(raw_UAE_peak_amp_series)])
% %     caxis([min(raw_UAE_peak_amp_series) max(raw_UAE_peak_amp_series)])
%     colorbar
%     colormap(inv_cmap)
%     box on
%     saveas(gcf, ['../figures/preprocessing/raw_stat/' log_UAE_fname '_raw_time_freq_amp'], 'fig')
%     
%     %% time-frequency-duration
%     figure;
%     hold on    
%     scatter(raw_emiss_max_t_hr, raw_UAE_peak_freq_series, 4, (raw_UAE_dur_series .* 1e6), 'filled');
%     grid on
%     xlabel('time, hours')
%     ylabel('frequency, kHz')
%     yticks(1e3.*[0 200 400 600 800 1000])
%     yticklabels({'0', '200', '400', '600', '800', '1000'})
%     title('Time-frequency distr. of raw durations (us)')
%     xlim([0 max(raw_emiss_max_t_hr)])
%     ylim([0 1e6])
% %     caxis([emission_min_dur_thr, 200e-6] .* 1e6)
% %     caxis([min(raw_UAE_dur_series), 300e-6] .* 1e6)
%     colorbar
%     colormap(prop_cmap)
%     box on
%     saveas(gcf, ['../figures/preprocessing/raw_stat/' log_UAE_fname '_raw_time_freq_dur'], 'fig')
%     
%     
%     %% time-duration-frequency
%     figure;
%     hold on    
%     scatter(raw_emiss_max_t_hr, (raw_UAE_dur_series .* 1e6), 4, (raw_UAE_peak_freq_series ./ 1e3), 'filled');
%     grid on
%     xlabel('time, hours')
%     ylabel('emission duration, us')
%     title('Time-duration distr. of raw frequencies (kHz)')
%     xlim([0 max(raw_emiss_max_t_hr)])
%     ylim([min(raw_UAE_dur_series), max(raw_UAE_dur_series)] .* 1e6)
%     caxis([100 400])
%     colorbar
%     colormap(prop_cmap)
%     box on
%     saveas(gcf, ['../figures/preprocessing/raw_stat/' log_UAE_fname '_raw_time_dur_freq'], 'fig')
%     
%     
%     %% hourly event rate
%         
%     % discrete hour axis
%     hr_start = floor(t_offset ./ 3600);
%     raw_hours_n = hr_start:floor(max(floor(raw_emiss_max_t_hr)));
%     num_hrs = length(raw_hours_n);
%     raw_event_rate_hr = zeros(num_hrs, 1);
%     
%     for hr_ind = 1:num_hrs    
%         raw_event_rate_hr(hr_ind) = length(find( floor(raw_emiss_max_t_hr) == raw_hours_n(hr_ind) ));
%     end
%     
%     figure;
%     bar(raw_hours_n, raw_event_rate_hr)
%     grid on
%     title('Hourly raw emission rate')
%     xlim([0 (max(raw_hours_n)+1)])
%     xlabel('time, hours')
%     ylabel('emissions / hour')
%     saveas(gcf, ['../figures/preprocessing/raw_stat/' log_UAE_fname '_raw_hourly_emission_rate'], 'fig')
%     
%     %% cumulative number of emissions
%     raw_cumul_events_hr = cumsum(raw_event_rate_hr);
%     
%     figure;
%     bar(raw_hours_n, raw_cumul_events_hr)
%     grid on
%     title('Cumulative raw emission count')
%     xlim([0 (max(raw_hours_n)+1)])
%     xlabel('time, hours')
%     ylabel('total emissions')
%     saveas(gcf, ['../figures/preprocessing/raw_stat/' log_UAE_fname '_raw_cumul_emissions_count'], 'fig')
end