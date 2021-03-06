clc
% close all
clear all

fs_UAE = 2e6;               % 2 MSps sampling frequency of ultrasonic emissions
N = 1024;                   % for STFT
overlap = 0.80;             % percentage overlap
f = fs_UAE .* (0:(N/2))/N;  % frequency axis

env_thr = 0.5e-3;
%emission_min_dur_thr = 50e-6;
emission_min_dur_thr = 15e-6;
emission_max_dur_thr = 500e-6;
%peak_prom_thr = 0.3;       % normalized, percentage of max.
%peak_width_thr = 15e3;     % Hz
peak_prom_thr = 0.25;       % normalized, percentage of max.
%peak_width_thr = 18e3;     % Hz
peak_width_thr = 10e3;     % Hz


amp_thr = 5e-3;             % 5 mV
PSD_thr = 20;               % 20 dB
low_freq = 120e3;           % 120 kHz
high_freq = 850e3;          % 850 kHz

t_offset = 0 .* 3600;       % hours --> seconds

% path = '';

% path = 'E:\Sensirrika\';
% log_UAE_fname = 'UAE_data_exp_02_2018_05_02_part_02c';
% log_UAE_fname = 'UAE_data_exp_03_2018_05_04_part_02b';
% log_UAE_fname = 'UAE_data_exp_04_2018_05_07_complete';
% log_UAE_fname = 'UAE_data_exp_05_2018_05_10_complete';
% log_UAE_fname = 'UAE_data_exp_06_2018_06_05_complete';

% path = 'E:\Sensirrika\Exp 07\';
% log_UAE_fname = 'UAE_data_exp_07_2018_07_16_complete';

% path = 'E:\Sensirrika\Exp 08\';
% log_UAE_fname = 'UAE_data_exp_08_2018_07_19';

% path = 'E:\Sensirrika\Exp 09\';
% log_UAE_fname = 'UAE_data_exp_09_2018_07_23';

%path = 'E:\Sensirrika\Exp 10\';
%log_UAE_fname = 'UAE_data_exp_10_25_07_2018_part_01';
%log_UAE_fname = 'UAE_data_exp_10_25_07_2018_part_02';

%path = 'E:\Sensirrika\Exp 11\';
%log_UAE_fname = 'UAE_data_exp_11_complete';

%path = 'E:\Sensirrika\Exp 12\';
%log_UAE_fname = 'UAE_data_exp_12_complete';

% path = 'E:\Sensirrika\Exp 13\'; % OLD
path = '../../../';
% log_UAE_fname = 'UAE_data_exp_13_complete';
log_UAE_fname = 'UAE_data_exp_06_2018_06_05_complete'; % bigger dataset

%path = 'E:\Sensirrika\Exp 14\';
%log_UAE_fname = 'UAE_data_exp14_part_01';
%log_UAE_fname = 'UAE_data_exp14_part_02';
%log_UAE_fname = 'UAE_data_exp14_part_03';

%log_UAE_fname = 'UAE_data_ambient_emissions_no_foil_norm_temp';
%log_UAE_fname = 'UAE_data_ambient_emissions_thick_foil_norm_temp';
%log_UAE_fname = 'UAE_data_pre_exp11_plastic_foil_clicks';


%% load signal chain's frequency characteristics, calculate equilization coeficients
% load freq_responses % OLD
load ../input_matrices/freq_responses
load ../input_matrices/UAE_meas_dB_filter

% % Vallen VS600Z1
meas_chain_freq_resp_max = max(meas_chain_freq_resp_VS600Z1_1M);
meas_chain_freq_resp_corr = meas_chain_freq_resp_max ./ meas_chain_freq_resp_VS600Z1_1M;

% % Vallen VS900M
% meas_chain_freq_resp_max = max(meas_chain_freq_resp_VS900M_1M);
% meas_chain_freq_resp_corr = meas_chain_freq_resp_max ./ meas_chain_freq_resp_VS900M_1M;

% % Vallen VS150M
% meas_chain_freq_resp_max = max(meas_chain_freq_resp_VS150M_1M);
% meas_chain_freq_resp_corr = meas_chain_freq_resp_max ./ meas_chain_freq_resp_VS150M_1M;

% % Vallen AE1045S
% meas_chain_freq_resp_max = max(meas_chain_freq_resp_AE1045S_1M);
% meas_chain_freq_resp_corr = meas_chain_freq_resp_max ./ meas_chain_freq_resp_AE1045S_1M;


% figure
% plot(f_1M, meas_chain_freq_resp_VS600Z1_1M)
% grid on

% figure
% yyaxis left
% hold on
% plot(f_1M, meas_chain_freq_resp_VS600Z1_1M, 'LineWidth', 2)
% plot(f_1M, meas_chain_freq_resp_corr .* meas_chain_freq_resp_VS600Z1_1M, '--', 'LineWidth', 2)
% hold off
% grid on
% ylabel('Sensitivity, mV/ubar')
% 
% yyaxis right
% plot(f_1M, meas_chain_freq_resp_corr, 'LineWidth', 2)
% ylabel('Correction factor')
% ylim([0 30])
% xlim([1.2e5 8.8e5])
% xlabel('Frequency, kHz')
% title('Frequency response equalization')

%% statistics
stat_num_evts = 0;
stat_num_interf_HF = 0;
stat_num_interf_LF = 0;
stat_num_emis = 0;
stat_num_emis_broad = 0;
stat_num_emis_single = 0;
stat_num_emis_multi = 0;


%% load stored data

disp('Loading file...')

fid_UAE_log = fopen([path log_UAE_fname '.bin'], 'r');
[data_UAE,count] = fread(fid_UAE_log,[2,inf],'double');
fclose(fid_UAE_log);

disp('...done.')

% if file not empty
if (count > 0)
    
    %% plot all events
    t_UAE = data_UAE(1,:);
    %ch = data(2:3,:);
    ch_UAE = data_UAE(2,:);

    t_UAE_hr = (t_UAE + t_offset) ./ 3600;
    
%     % plot raw time-domain signal
%     figure(51)
%     hold on    
%     plot(t_UAE_hr, ch_UAE);
%     grid on
%     title('raw time-domain signal')
%     xlabel('time, hours')
%     ylabel('voltage, V')
%     %saveas(gcf, [log_UAE_fname '_fig1'], 'fig')
    
    
    %% extract and plot individual events in the recording
    
    ind_jmp = find(diff(t_UAE) > (2/fs_UAE));
    num_evts = length(ind_jmp) + 1;
    ind_evt_start = [1 (ind_jmp + 1)];
    ind_evt_end = [ind_jmp length(t_UAE)];    
    
    disp(['Total number of events: ', num2str(num_evts)])
    stat_num_evts = num_evts;
   
    % initialize variables
    UAE_max_t_series = [];    
    UAE_max_y_series = [];    
    UAE_max_f_series = [];
    UAE_max_dur_series = [];
    
    UAE_single_t_mat = [];
    UAE_single_f_mat = [];
    UAE_single_a_mat = [];
    
    UAE_multi_t_mat = [];
    UAE_multi_f_mat = [];
    UAE_multi_a_mat = [];
    
    UAE_broad_t_mat = [];
    UAE_broad_f_mat = [];
    UAE_broad_a_mat = [];
    
    equ_emission_without_peak_count = 0;
    broad_indices = [];
    %%
    for ind_seg = 1:num_evts
        
        disp(['Event #', num2str(ind_seg)])
        
        %% 1) extract signal segments
        UAE_evt_t = t_UAE(ind_evt_start(ind_seg):ind_evt_end(ind_seg));
        UAE_evt_y = ch_UAE(ind_evt_start(ind_seg):ind_evt_end(ind_seg));                        
                
        % plot in time domain
%         figure(52)        
%         plot(UAE_evt_t, UAE_evt_y)
%         xlabel('time, s')
%         ylabel('voltage, V')
%         grid on
%         xlim([min(UAE_evt_t) max(UAE_evt_t)])
%         title('An individual emission event in time-domain')
        
        %% plot STFT spectrogram
%         figure(61)
%         spectrogram(UAE_evt_y, blackman(N), floor(0.9.*N), N, fs_UAE, 'yaxis');
%         xlabel('time, ms')
%         ylabel('frequency, MHz')
%         box on
%         title('Time-frequency DFT power-spectrogram of an emission')
        
        %% plot continuous wavelet transform
%         figure(62)
%         cwt(UAE_evt_y,'bump',fs_UAE,'VoicesPerOctave',32);
%         xlabel('time, ms')
%         ylabel('frequency, kHz')
%         yticks([100 200 500 1000])
%         title('Time-frequency CWT scalogram of an emission')
%         box on
        
        
        %% 2) time-domain processing: extract location and value of maximum amplitude
        [UAE_evt_max_y, UAE_evt_max_ind] = max(abs(UAE_evt_y));
        UAE_evt_max_t = UAE_evt_t(UAE_evt_max_ind);
        
        %% Convolution
%         conv_sig = conv(UAE_evt_y,h);
%         UAE_evt_y = conv_sig(1:length(UAE_evt_y));

        %% 3) FFT centered around the time-domain maximum to extract the central frequency
        
        if ((UAE_evt_max_ind-N/2) < 1)            
            UAE_max_evt_cfft = fft(UAE_evt_y(1:N));            
        elseif ((UAE_evt_max_ind+N/2-1) > length(UAE_evt_y))            
            UAE_max_evt_cfft = fft(UAE_evt_y( (end-N+1):end ));            
        else            
            UAE_max_evt_cfft = fft(UAE_evt_y( (UAE_evt_max_ind-N/2):(UAE_evt_max_ind+N/2-1) ));
        end                
        
        evt_abs_fft_pn = abs(UAE_max_evt_cfft./N);
        UAE_max_evt_abs_fft = evt_abs_fft_pn(1:N/2+1);        
        UAE_max_evt_abs_fft(2:end-1) = 2*UAE_max_evt_abs_fft(2:end-1);
        UAE_max_evt_abs_fft(1) = 0;
        
        % plot the FFT around maximum
%         figure(53)        
%         plot(f, UAE_max_evt_abs_fft)
%         grid on
%         title('Single-sided amplitude spectrum')
%         xlabel('frequency, Hz')
%         ylabel('amplitude spectrum, V')
        
        
        %% 4) exclude low-frequency interferences from the dataset
        
        % in frequency-domain: based on maximal frequency
        [fft_max_val, fft_max_ind] = max(UAE_max_evt_abs_fft);        
        fft_max_freq = f(fft_max_ind);
        
        if (fft_max_freq < low_freq)% freq. domain LF
            disp('Skipped: LF interference')
            stat_num_interf_LF = stat_num_interf_LF + 1;
            
%             pause
            
            continue;
        else       
            %% 5) exclude high-frequency interferences from the dataset
            
            % in time-domain: based on duration of the envelope
            [UAE_evt_env, env_low] = envelope(UAE_evt_y, 30, 'rms');
            bin_env_mask = (UAE_evt_env >= env_thr);
            
            
            % plot envelope
%             figure(54)
%             clf
%             hold on
%             plot(UAE_evt_t, abs(UAE_evt_y))                    % manually extracted
%             plot(UAE_evt_t, UAE_evt_env, 'Linewidth', 1)       % Matlab      
%             hold off
%             grid on
%             xlim([min(UAE_evt_t) max(UAE_evt_t)])
%             xlabel('time, s')
%             ylabel('voltage, V')
%             legend('absolute magnitude', 'RMS envelope')
%             title('Time-domain envelope of an emission')

            % plot binary envelope mask
%             figure(55)
%             plot(UAE_evt_t, bin_env_mask)
%             xlim([min(UAE_evt_t) max(UAE_evt_t)])
%             ylim([-0.2 1.82])
%             grid on
%             xlabel('time, s')
%             title('Emission duration binary mask')

            env_mask_transitions = diff([0 bin_env_mask 0]);
            raw_emis_seg_start_ind = find(env_mask_transitions > 0);
            raw_emis_seg_end_ind = find(env_mask_transitions < 0) - 1;
            raw_emis_dur_T = (raw_emis_seg_end_ind - raw_emis_seg_start_ind + 1) ./ fs_UAE;

            % indices of raw segments satisfying of required duration
            all_emis_ind = find( (raw_emis_dur_T > emission_min_dur_thr) & (raw_emis_dur_T < emission_max_dur_thr) );

            %pause
            
            if isempty(all_emis_ind)% min. duration
                disp('Skipped: HF interference')
                stat_num_interf_HF = stat_num_interf_HF + 1;
                continue;
            else
                %% 6) extract duration
                all_emis_seg_start_ind = raw_emis_seg_start_ind(all_emis_ind);
                all_emis_seg_end_ind = raw_emis_seg_end_ind(all_emis_ind);
                all_emis_dur_T = raw_emis_dur_T(all_emis_ind);

                % extract duration of the particular segment containing the amplitude maxim                
                dist_to_end = (all_emis_seg_end_ind - UAE_evt_max_ind);
                dist_to_end(dist_to_end <= 0) = inf;    % Matlab has no function for min. pos. value
                [min_dist_to_end_val, emis_max_y_ind] = min(dist_to_end);
                emis_max_y_dur = all_emis_dur_T(emis_max_y_ind);

                % TODO (if needed): absolute start/end location of the emission in the recording
                

                %% 7) equalize frequency                                 
                equ_fft = zeros(1, length(f));
                ind_low_freq = max(find(f < 120e3));
                ind_high_freq = min(find(f > 800e3));                
                
                for ind_f = ind_low_freq:ind_high_freq                
                    ind_f_meas_chain_freq_resp = min(findnearest(f(ind_f), f_1M));
                    equ_fft(ind_f) = UAE_max_evt_abs_fft(ind_f) .* meas_chain_freq_resp_corr(ind_f_meas_chain_freq_resp);                
                end    

%                 equ_fft = UAE_max_evt_abs_fft;
                
                % equilized frequency response
%                 figure(56)
%                 plot(f, equ_fft)
%                 grid on
%                 title('Equilized amplitude spectrum')
%                 xlabel('frequency, Hz')
%                 ylabel('amplitude spectrum, V')
                
                % find, extract the most prominent peaks
                % first normalize
                [max_equ_fft_val, max_equ_fft_ind] = max(equ_fft);
                norm_equ_fft = equ_fft ./ max_equ_fft_val;
                
%                 figure(57)
%                 findpeaks(norm_equ_fft, f, 'MinPeakProminence', peak_prom_thr, 'MinPeakWidth', peak_width_thr, 'Annotate','extents')
%                 title('Peaks in normalized amplitude spectrum')
%                 xlabel('frequency, Hz')
%                 ylabel('normalized amplitude spectrum')
                [norm_peak_vals, peak_freqs] = findpeaks(norm_equ_fft, f, 'MinPeakProminence', peak_prom_thr, 'MinPeakWidth', peak_width_thr, 'Annotate','extents');
%                 figure;
%                 findpeaks(norm_equ_fft, f, 'MinPeakProminence', peak_prom_thr, 'MinPeakWidth', peak_width_thr, 'Annotate','extents');
                                                                
                
                % a) store emission's equilized frequency-maximum, time, amplitude and duration
                UAE_max_f_series = [UAE_max_f_series; f(max_equ_fft_ind)];
                UAE_max_t_series = [UAE_max_t_series; UAE_evt_max_t];    
                UAE_max_y_series = [UAE_max_y_series; UAE_evt_max_y];                        
                UAE_max_dur_series = [UAE_max_dur_series; emis_max_y_dur];       
                
                dom_freqs_vect = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN];
                dom_amps_vect = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN];
                
                
                % sort in categories based on nuumber of peaks detected
                if isempty(peak_freqs) % dominant peaks
                    % no prominent peaks, "broadband" or simply "noisy" signal                    
                    % store the frequency-maximum
                    UAE_broad_t_mat = [UAE_broad_t_mat; UAE_evt_max_t];
                    UAE_broad_f_mat = [UAE_broad_f_mat; f(max_equ_fft_ind)];
                    UAE_broad_a_mat = [UAE_broad_a_mat; max_equ_fft_val];
                    stat_num_emis_broad = stat_num_emis_broad + 1;
                    broad_indices = [broad_indices,ind_seg];
                    
                elseif (length(peak_freqs) == 1)                    
                    % single prominent peak detected                    
                     peak_freqs_ind = find(peak_freqs == f);
                     peak_vals = equ_fft(peak_freqs_ind);
                                       
                    if (f(max_equ_fft_ind) == peak_freqs)
                        % indeed only a single peak
                        UAE_single_t_mat = [UAE_single_t_mat; UAE_evt_max_t];
                        UAE_single_f_mat = [UAE_single_f_mat; peak_freqs];
                        UAE_single_a_mat = [UAE_single_a_mat; peak_vals];
                        stat_num_emis_single = stat_num_emis_single + 1;
                        
                    else
                        % actually two peaks
                        dom_freqs_vect(1) = peak_freqs;
                        dom_amps_vect(1) = peak_vals;
                        
                        UAE_multi_t_mat = [UAE_multi_t_mat; UAE_evt_max_t];
                        UAE_multi_f_mat = [UAE_multi_f_mat; [dom_freqs_vect, f(max_equ_fft_ind)]];
                        UAE_multi_a_mat = [UAE_multi_a_mat; [dom_amps_vect, max_equ_fft_val]];
                        stat_num_emis_multi = stat_num_emis_multi + 1;
                        
                    end % single peak
                    
                else                   
                    % multiple dominant peaks detected, sort by ascending peak-frequency indices                    
                    [shared_vals, peak_freqs_ind] = intersect(f, peak_freqs, 'stable');
                    peak_vals = equ_fft([peak_freqs_ind]);
                    
                    % sort by descending peak magnitudes
                    [max_peak_vals, max_peak_inds] = maxk(peak_vals, length(dom_freqs_vect));
                    dom_freqs_vect(1:length(max_peak_inds)) = peak_freqs(max_peak_inds);
                    dom_amps_vect(1:length(max_peak_inds)) = peak_vals(max_peak_inds);
                    
                    if (max_equ_fft_val > max(dom_amps_vect))
                        % multiple dominant peaks plus an additional high amplitude maximum
                        UAE_multi_t_mat = [UAE_multi_t_mat; UAE_evt_max_t];
                        UAE_multi_f_mat = [UAE_multi_f_mat; [dom_freqs_vect, f(max_equ_fft_ind)]];
                        UAE_multi_a_mat = [UAE_multi_a_mat; [dom_amps_vect, max_equ_fft_val]];
                        stat_num_emis_multi = stat_num_emis_multi + 1;
                        
                    else
                        % multiple dominant peaks
                        UAE_multi_t_mat = [UAE_multi_t_mat; UAE_evt_max_t];
                        UAE_multi_f_mat = [UAE_multi_f_mat; [dom_freqs_vect, NaN]];
                        UAE_multi_a_mat = [UAE_multi_a_mat; [dom_amps_vect, NaN]];
                        stat_num_emis_multi = stat_num_emis_multi + 1;
                        
                    end % multiple peaks
                        
                end % if any dominant peaks
            
%                 pause

            end % min. dur (HF interf.)                  
        end % freq. domain (LF interf.)
    end % individual events

%% 
disp('--------------------------------------------------------------------')
disp(['Total number of emissions: ' num2str(length(UAE_max_t_series))])

stat_num_emis = length(UAE_max_t_series);
stat_perc_emis = (stat_num_emis ./ stat_num_evts) .* 100;
stat_perc_interf_LF = (stat_num_interf_LF ./ stat_num_evts) .* 100;
stat_perc_interf_HF = (stat_num_interf_HF ./ stat_num_evts) .* 100;
stat_perc_emis_broad = (stat_num_emis_broad ./ stat_num_emis) .* 100;
stat_perc_emis_single = (stat_num_emis_single ./ stat_num_emis) .* 100;
stat_perc_emis_multi = (stat_num_emis_multi ./ stat_num_emis) .* 100;

disp(['emissions / events: ' num2str(stat_num_emis), ' / ', num2str(stat_num_evts), ' = ', num2str(stat_perc_emis), '%'])
disp(['LF interferences / events: ' num2str(stat_num_interf_LF), ' / ', num2str(stat_num_evts), ' = ', num2str(stat_perc_interf_LF), '%'])
disp(['HF interferences / events: ' num2str(stat_num_interf_HF), ' / ', num2str(stat_num_evts), ' = ', num2str(stat_perc_interf_HF), '%'])
disp(['broadband emissions / emissions: ' num2str(stat_num_emis_broad), ' / ', num2str(stat_num_emis), ' = ', num2str(stat_perc_emis_broad), '%'])
disp(['single-component emissions / emissions: ' num2str(stat_num_emis_single), ' / ', num2str(stat_num_emis), ' = ', num2str(stat_perc_emis_single), '%'])
disp(['multi-component emissions / emissions: ' num2str(stat_num_emis_multi), ' / ', num2str(stat_num_emis), ' = ', num2str(stat_perc_emis_multi), '%'])
single_200k_num = sum(UAE_single_f_mat > 175e3 & UAE_single_f_mat < 250e3);
disp(['single-component emissions between 175 kHz and 250 kHz: ' num2str(single_200k_num) '/' num2str(stat_num_emis_single)]);



% %% time axis in hrs
UAE_max_t_series_hr = (UAE_max_t_series + t_offset) ./ 3600;
UAE_max_t_series_min = (UAE_max_t_series + t_offset) ./ 60;

UAE_single_t_mat_hr = (UAE_single_t_mat + t_offset) ./ 3600;
UAE_multi_t_mat_hr = (UAE_multi_t_mat + t_offset) ./ 3600;
UAE_broad_t_mat_hr = (UAE_broad_t_mat + t_offset) ./ 3600;
% 

figure;
hold on
scatter(UAE_max_t_series_hr, UAE_max_f_series, 4, 'g', 'filled');
scatter(UAE_broad_t_mat_hr, UAE_broad_f_mat, 4, 'r', 'filled');
scatter(UAE_single_t_mat_hr, UAE_single_f_mat, 4, 'k', 'filled');
grid on
xlabel('time, hours')
ylabel('Peak Freq, Hz')
xlim([0 max(UAE_max_t_series_hr)])
box on
title('Distr. of emission peak freq in time')


%% color map
%my_jet = jet(128);
%custom_cmap = my_jet(15:115, :);

% my_cool = cool(128);
% my_hot = hot(128);
% my_parula = parula(128);
% custom_hot = my_hot(1:96, :);
% inv_cmap = flipud(custom_hot);
% prop_cmap = custom_hot;
% 

% %% time-series of individual events' time-domain amplitudes
% figure(1)
% hold on
% scatter(UAE_max_t_series_hr, UAE_max_y_series, 4, 'k', 'filled');
% grid on
% xlabel('time, hours')
% ylabel('amplitude, V')
% xlim([0 max(UAE_max_t_series_hr)])
% box on
% title('Distr. of emission amplitudes in time')
% saveas(gcf, [log_UAE_fname '_time_amp'], 'fig')
% 
% 
% %% Time-amplitude-frequency 
% figure(2)
% hold on    
% scatter(UAE_max_t_series_hr, UAE_max_y_series, 4, (UAE_max_f_series ./ 1e3), 'filled');
% grid on
% xlabel('time, hours')
% ylabel('amplitude, V')
% title('Time-amplitude distr. of emission frequencies (kHz) ')
% xlim([0 max(UAE_max_t_series_hr)])
% caxis([100 400])
% colorbar
% colormap(prop_cmap)
% box on
% saveas(gcf, [log_UAE_fname '_time_amp_freq'], 'fig')
% 
%    
% %% time-series of individual events' frequency-domain maximums   
% figure(3)
% hold on    
% scatter(UAE_max_t_series_hr, UAE_max_f_series, 4, 'k', 'filled');
% grid on
% xlabel('time, hours')
% ylabel('frequency, kHz')
% yticks(1e3.*[0 200 400 600 800 1000])
% yticklabels({'0', '200', '400', '600', '800', '1000'})
% title('Distr. of emission frequencies in time')
% xlim([0 max(UAE_max_t_series_hr)])
% ylim([0 1e6])
% box on
% saveas(gcf, [log_UAE_fname '_time_freq'], 'fig')
% 
%      
% %% time-frequency-amplitude maximums
% figure(4)
% hold on    
% scatter(UAE_max_t_series_hr, UAE_max_f_series, 4, UAE_max_y_series, 'filled');
% grid on
% xlabel('time, hours')
% ylabel('frequency, kHz')
% yticks(1e3.*[0 200 400 600 800 1000])
% yticklabels({'0', '200', '400', '600', '800', '1000'})
% title('Time-frequency distr. of emission amplitudes (V)')
% xlim([0 max(UAE_max_t_series_hr)])
% ylim([0 1e6])
% %caxis([min(UAE_max_y_series) 0.1.*max(UAE_max_y_series)])
% caxis([min(UAE_max_y_series) 5.0*median(UAE_max_y_series)])
% colorbar
% colormap(inv_cmap)
% box on
% saveas(gcf, [log_UAE_fname '_time_freq_amp'], 'fig')
% 
% 
% %% time-duration
% figure(5)
% hold on    
% scatter(UAE_max_t_series_hr, (UAE_max_dur_series .* 1e6), 4, 'k', 'filled');
% grid on
% xlabel('time, hours')
% ylabel('emission duration, us')
% title('Distr. of emission durations in time')
% xlim([0 max(UAE_max_t_series_hr)])
% ylim([emission_min_dur_thr, emission_max_dur_thr] .* 1e6)
% box on
% saveas(gcf, [log_UAE_fname '_time_dur'], 'fig')
% 
% 
% %% time-frequency-duration
% figure(6)
% hold on    
% scatter(UAE_max_t_series_hr, UAE_max_f_series, 4, (UAE_max_dur_series .* 1e6), 'filled');
% grid on
% xlabel('time, hours')
% ylabel('frequency, kHz')
% yticks(1e3.*[0 200 400 600 800 1000])
% yticklabels({'0', '200', '400', '600', '800', '1000'})
% title('Time-frequency distr. of durations (us)')
% xlim([0 max(UAE_max_t_series_hr)])
% ylim([0 1e6])
% caxis([emission_min_dur_thr, 200e-6] .* 1e6)
% colorbar
% colormap(prop_cmap)
% box on
% saveas(gcf, [log_UAE_fname '_time_freq_dur'], 'fig')
% 
% 
% %% time-duration-frequency
% figure(7)
% hold on    
% scatter(UAE_max_t_series_hr, (UAE_max_dur_series .* 1e6), 4, (UAE_max_f_series ./ 1e3), 'filled');
% grid on
% xlabel('time, hours')
% ylabel('emission duration, us')
% title('Time-duration distr. of frequencies (kHz)')
% xlim([0 max(UAE_max_t_series_hr)])
% ylim([emission_min_dur_thr, emission_max_dur_thr] .* 1e6)
% caxis([100 400])
% colorbar
% colormap(prop_cmap)
% box on
% saveas(gcf, [log_UAE_fname '_time_dur_freq'], 'fig')
% 
% 
% %% hourly event rate
%     
% % discrete hour axis
% hr_start = floor(t_offset ./ 3600);
% hours_n = hr_start:floor(max(floor(UAE_max_t_series_hr)));
% num_hrs = length(hours_n);
% event_rate_hr = zeros(num_hrs, 1);
% 
% for hr_ind = 1:num_hrs    
%     event_rate_hr(hr_ind) = length(find( floor(UAE_max_t_series_hr) == hours_n(hr_ind) ));
% end
% 
% figure(8)
% bar(hours_n, event_rate_hr)
% grid on
% title('Hourly emission rate')
% xlim([0 (max(hours_n)+1)])
% xlabel('time, hours')
% ylabel('emissions / hour')
% saveas(gcf, [log_UAE_fname '_hourly_emission_rate'], 'fig')
% 
% 
% %% cumulative number of emissions
% cumul_events_hr = cumsum(event_rate_hr);
% 
% figure(9)
% bar(hours_n, cumul_events_hr)
% grid on
% title('Cumulative emission count')
% xlim([0 (max(hours_n)+1)])
% xlabel('time, hours')
% ylabel('total emissions')
% saveas(gcf, [log_UAE_fname '_cumul_emissions_count'], 'fig')
% 
% 
% %% magnitudes of dominant time-frequency-amplitude content
% figure(10)
% hold on
% 
% median_a_dens = nanmedian([nanmedian(nanmedian(UAE_multi_a_mat)), nanmedian(UAE_broad_a_mat), nanmedian(UAE_single_a_mat)]);
% 
% for ind_f_max = 1:size(UAE_multi_f_mat, 2)
%     scatter(UAE_multi_t_mat_hr, UAE_multi_f_mat(:, ind_f_max), 4, UAE_multi_a_mat(:, ind_f_max), 'filled');
% end
% scatter(UAE_broad_t_mat_hr, UAE_broad_f_mat, 4, UAE_broad_a_mat, 'filled');
% scatter(UAE_single_t_mat_hr, UAE_single_f_mat, 4, UAE_single_a_mat, 'filled');
% grid on
% xlabel('time, hours')
% ylabel('frequency, kHz')
% yticks(1e3.*[0 200 400 600 800 1000])
% yticklabels({'0', '200', '400', '600', '800', '1000'})
% title('Time-freq. distr. of amplitude-spect. peaks (V/Hz)')
% xlim([0 max(UAE_max_t_series_hr)])
% ylim([0 1e6])
% caxis([0 2.*median_a_dens])
% colorbar
% colormap(inv_cmap)
% box on
% saveas(gcf, [log_UAE_fname '_time_freq_dom_amp_spect'], 'fig')
% 
% 
% %% dominant time-frequency-amplitude content by categories
% figure(11)
% hold on
% p1 = scatter(UAE_multi_t_mat_hr, UAE_multi_f_mat(:, 1), 4, [inv_cmap(36, :)], 'filled');
% p2 = scatter(UAE_multi_t_mat_hr, UAE_multi_f_mat(:, 2), 4, [my_cool(12, :)], 'filled');
% p3 = scatter(UAE_multi_t_mat_hr, UAE_multi_f_mat(:, 3), 4, [my_parula(90, :)], 'filled');
% p4 = scatter(UAE_broad_t_mat_hr, UAE_broad_f_mat, 4, [inv_cmap(8, :)], 'filled');
% p5 = scatter(UAE_single_t_mat_hr, UAE_single_f_mat, 4, [inv_cmap(end, :)], 'filled');
% 
% grid on
% xlabel('time, hours')
% ylabel('frequency, kHz')
% yticks(1e3.*[0 200 400 600 800 1000])
% yticklabels({'0', '200', '400', '600', '800', '1000'})
% title('Time-freq. distr. of emission signals by categories')
% xlim([0 max(UAE_max_t_series_hr)])
% ylim([0 1e6])
% colormap(inv_cmap)
% legend([p1, p2, p3, p4, p5], {'multi-component, #1', 'multi-component, #2', 'multi-component, #3', 'broadband', 'single-component'})
% box on
% saveas(gcf, [log_UAE_fname '_time_freq_emis_categ'], 'fig')


end % count non-zero events


%% save results
% save([log_UAE_fname '.mat'], ...
%     'UAE_max_t_series_hr', 'UAE_max_y_series', 'UAE_max_f_series', 'UAE_max_dur_series', ...
%     'UAE_single_t_mat_hr', 'UAE_single_f_mat', 'UAE_single_a_mat', ...
%     'UAE_multi_t_mat_hr', 'UAE_multi_f_mat', 'UAE_multi_a_mat', ...
%     'UAE_broad_t_mat_hr', 'UAE_broad_f_mat', 'UAE_broad_a_mat', ...
%     'hours_n', 'event_rate_hr', 'cumul_events_hr', ...
%     'stat_num_evts', 'stat_num_emis', 'stat_perc_emis', ...
%     'stat_num_interf_HF', 'stat_perc_interf_HF', ...
%     'stat_num_interf_LF', 'stat_perc_interf_LF', ...
%     'stat_num_emis_broad', 'stat_perc_emis_broad', ...
%     'stat_num_emis_single', 'stat_perc_emis_single', ...
%     'stat_num_emis_multi', 'stat_perc_emis_multi')
% 
