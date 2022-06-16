clc
% close all
clear all

global h_norm
global h
global meas_chain_freq_resp_corr
global f_1M
global low_freq_thr
global high_freq_thr
global N
global fs_UAE
global emission_f
global angle_f
global peak_amp_thr
global emission_min_dur_thr
global emission_max_dur_thr
global t_offset
global dataset_name

fs_UAE = 2e6;               % 2 MSps sampling frequency of ultrasonic emissions
N = 1024;                   % for STFT

emission_f = fs_UAE .* (0:(N/2))/N; % frequency axis
angle_f = fs_UAE .* (0:(N-1))/N;

% emission_amp_thr = 0.5e-3;    % 0.5 mV - threshold for splitting noise and emission
peak_amp_thr = 2e-3;          % 2 mV (was 5 mV) - threshold for determining emission peaks
emission_min_dur_thr = 15e-6; % 15 us s- threshold for minimum emission duration
emission_max_dur_thr = 500e-6;% 500 us - threshold for maximum emission duration

low_freq_thr = 120e3;         % 110 kHz - threshold for minimum important freqency spectrum 
high_freq_thr = 850e3;            % 850 kHz - threshold for maximum important freqency spectrum 

t_offset = 0 .* 3600;       % hours --> seconds
addpath 'C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\preprocessing'
%% choose which dataset to load
% path = '..\clustering\method_used_before\optics_matlab\data\';
% dataset_name = 'exp_6';
% log_UAE_fname = '../../UAE_data_exp_06_2018_06_05_complwete';
% log_UAE_fname = '../../UAE_data_exp_07_2018_07_16_complete';
% dataset_name = 'exp_7'; % 5 from literature
% log_UAE_fname = '../../UAE_data_exp_08_2018_07_19';
% dataset_name = 'exp_8';
% log_UAE_fname = '../../UAE_data_exp_09_2018_07_23';
% dataset_name = 'exp_9';
% log_UAE_fname = '../../UAE_data_exp_10_25_07_2018_part_01';
% dataset_name = 'exp_10_part_1';
% log_UAE_fname = '../../UAE_data_exp_10_25_07_2018_part_02';
% dataset_name = 'exp_10_part_2';
% log_UAE_fname = '../../UAE_data_exp_12_complete';
% dataset_name = 'exp_12';
log_UAE_fname = '../../UAE_data_exp_13_complete';
dataset_name = 'exp_13';
% log_UAE_fname = '../../UAE_data_exp_13_complete';
% log_UAE_fname = 'C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\UAE_data_exp14_part_01';
% dataset_name = 'exp_14_part_1';
% log_UAE_fname = '../../UAE_data_exp14_part_02';
% dataset_name = 'exp_14_part_2';
% log_UAE_fname = '../../UAE_data_exp14_part_03';
% dataset_name = 'exp_14_part_3';


% log_UAE_fname = '../../UAE_data_exp_13_complete'; % smaller dataset
% dataset_name = 'small_dataset';

% log_UAE_fname = '../../UAE_data_exp_06_2018_06_05_complete'; % bigger dataset
% dataset_name = 'big_dataset';

load input_matrices/UAE_meas_dB_filter_and_impulse.mat; % impulse response of filter based on sensor frequency characteristic
global inverse_freq_resp
global h

global stat_num_interf_LF
global stat_num_interf_HF
global all_emissions
global emission_without_peak_count
global equ_emission_without_peak_count
global stat_num_evts
% initalize statistics variables
stat_num_evts = 0;
stat_num_interf_HF = 0;
stat_num_interf_LF = 0;
emission_without_peak_count = 0;
equ_emission_without_peak_count = 0;
all_emissions = 0;

%% 0) load dataset

disp('Loading file...')
fid_UAE_log = fopen(['' log_UAE_fname '.bin'], 'r');

[data_UAE,count] = fread(fid_UAE_log,[2,inf],'double');

fclose(fid_UAE_log);
disp('...done.')


% if file not empty
if (count > 0)
    
    % seperate magnitude from time
    t_UAE = data_UAE(1,:);
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
    
    % extract individual events in the recording
    ind_jmp = find(diff(t_UAE) > (2/fs_UAE)); 
    num_evts = length(ind_jmp) + 1;
    ind_evt_start = [1 (ind_jmp + 1)];
    ind_evt_end = [ind_jmp length(t_UAE)];

    % Calculate frequency filter for individual events - don't use because it lowers amplitude in time domain
    % Filter signal (Bandpass) in time domain to keep frequencies between certain threshold.
%     global bpass_filter
%     fpass = [low_freq_thr, high_freq_thr] ./ (fs_UAE/2);
%     [~, bpass_filter] = bandpass(ind_evt_start(1):ind_evt_end(1), fpass, 'ImpulseResponse', 'fir');

    disp(['Total number of events: ', num2str(num_evts)])
    stat_num_evts = num_evts;

    raw_emiss_max_t = []; % TIME OF MAX PEAK OF RAW EMISSION [s]
    global equ_emiss_max_t
    equ_emiss_max_t = []; % TIME OF MAX PEAK OF EQUALIZED EMISSION [s]

    raw_feature_matrix = [];
    equ_feature_matrix = [];

    curr_emiss_ind = 0;

    global emissions
    emissions = [];
%%%%%%%%%%%%%%%%%%%%%% - START ANALYSIS- %%%%%%%%%%%%%%%%%%%%%%%%%
    for ind_seg = 1:num_evts
        
        disp(['Event #', num2str(ind_seg)])
        
        %% 1) extract signal segments
        UAE_evt_t = t_UAE(ind_evt_start(ind_seg):ind_evt_end(ind_seg));
        UAE_evt_y = ch_UAE(ind_evt_start(ind_seg):ind_evt_end(ind_seg));
              
        %% 1) Find valid emissions
         % [remove_LF_inter, filter_unwanted_freq, filter_HF_inter, filter_by_peaks, keep_one_emission, plotValidEmiss]
        choose_steps = num2cell([true, false, true, true, false, false]);
        [UAE_evt_y, valid_emiss_start_ind, valid_emiss_end_ind, emissions_max_ind,binary_envelope] = Get_Emission_From_Signal(UAE_evt_y, UAE_evt_t, choose_steps{:});

        for emiss_ind =  1:length(valid_emiss_start_ind)
            emission_y = UAE_evt_y(valid_emiss_start_ind(emiss_ind):valid_emiss_end_ind(emiss_ind));
            emission_t = UAE_evt_t(valid_emiss_start_ind(emiss_ind):valid_emiss_end_ind(emiss_ind));

%             figure;
%             hold on
%             plot(UAE_evt_t,UAE_evt_y)
%             bin_emiss = zeros(1,length(UAE_evt_y));
%             bin_emiss(valid_emiss_start_ind(emiss_ind):valid_emiss_end_ind(emiss_ind)) = max(emission_y);
%             plot(UAE_evt_t,bin_emiss,'Color','r','LineWidth',1)
%             hold off
%             title('Raw signal in time domain')
%             legend('Raw signal in time domain','Binary envelope of found emission')
%             xlabel('t[s]')
%             ylabel('x(t)[V]')
% 
%             figure;
%             plot(emission_t,emission_y)
%             title('Raw signal in time domain')
%             legend('Raw signal in time domain','Binary envelope of found emission')
%             xlabel('t[s]')
%             ylabel('x(t)[V]')

            %% Emission expanded with zeros
            [max_val,max_ind] = max(emission_y);
            [emission_y_zeros, emission_t_zeros] = Expand_Around_Max(emission_y, emission_t, max_ind);
    
            %% Emission expanded with real signal values
%             ind_thr_cross = find(abs(emission_y_zeros)>0);
%             add_before = ind_thr_cross(1);
%             add_after = ind_thr_cross(end);
% 
%             UAE_evt_max_ind = valid_emiss_start_ind(emiss_ind)+max_ind;
%             if ((UAE_evt_max_ind-N/2) < 1)            
%                 start_ind = 1;
%                 end_ind = N;
%             elseif ((UAE_evt_max_ind+N/2-1) > length(UAE_evt_y))    
%                 start_ind = (length(UAE_evt_y)-N+1);
%                 end_ind = length(UAE_evt_y);       
%             else     
%                 start_ind = (UAE_evt_max_ind-N/2);
%                 end_ind = (UAE_evt_max_ind+N/2-1);    
%             end    
%             emission_y = UAE_evt_y(start_ind:end_ind);
    
            emission_y = emission_y_zeros;
            emission_t = emission_t_zeros;
    
            curr_emiss_ind = curr_emiss_ind +1;
    
            %% 2) Equalize signal and Keep N points
            [equ_emission_y, equ_emission_abs_fft_ss, ~, equ_emission_t] = Equalize(emission_y, emission_t, 2, false, false);
    
    %                 [raw_emission_y, raw_emission_abs_fft_ss, ~, raw_emission_t] = Equalize(emission_y, emission_t, 3, false);
    
    %                 figure;
    %                 hold on
    %                 grid on
    %                 plot(equ_emission_t,equ_emission_y);
    %                 plot(emission_f, raw_emission_abs_fft_ss,'Color','b')
    %                 plot(emission_f, equ_emission_abs_fft_ss,'Color','r')
    %                 title("Equalized emission in Amplitude spectrum");
    
            %% 4) Calculate features of emission
            [equ_feature_row, equ_max_t,equ_sorted_peak_freqs,equ_sorted_peak_vals] = Calculate_Signal_Features(equ_emission_t,equ_emission_y,equ_emission_abs_fft_ss,rms(abs(equ_emission_y)));
    
            equ_feature_matrix = [equ_feature_matrix; equ_feature_row];
            
            % time of max peak of emission in whole time domain
            equ_emiss_max_t = [equ_emiss_max_t; equ_max_t];
            
            Nans = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN];
            Nans_len = length(Nans);
            if length(equ_sorted_peak_freqs) > Nans_len
                equ_sorted_peak_freqs = equ_sorted_peak_freqs(1:Nans_len);
            end
            Nans(1:length(equ_sorted_peak_freqs)) = equ_sorted_peak_freqs;
            freq_of_fft_peaks{length(equ_feature_matrix(:,1))} = Nans;
%             amp_of_fft_peaks{length(equ_feature_matrix(:,1))} = equ_sorted_peak_vals;
    
            %% Save all emissions for later analysis
            emissions{length(equ_feature_matrix(:,1)),1} = emission_y; 
            emissions{length(equ_feature_matrix(:,1)),2} = emission_t; 
            emissions{length(equ_feature_matrix(:,1)),3} = equ_emission_y; 
            emissions{length(equ_feature_matrix(:,1)),4} = equ_emission_t;
            emissions{length(equ_feature_matrix(:,1)),5} = equ_emission_abs_fft_ss; 
            emissions{length(equ_feature_matrix(:,1)),6} = emission_f;
            emissions{length(equ_feature_matrix(:,1)),7} = UAE_evt_y; 
            emissions{length(equ_feature_matrix(:,1)),8} = UAE_evt_t; 
            emissions{length(equ_feature_matrix(:,1)),9} = binary_envelope; 

            %% Calculate raw features for compatibility
%             [raw_feature_row, raw_max_t] = Calculate_Signal_Features(raw_emission_t,raw_emission_y,raw_emission_abs_fft_ss,rms(abs(raw_emission_y)));
% 
%             raw_feature_matrix = [raw_feature_matrix; raw_feature_row];
%             
%             % time of max peak of emission in whole time domain
%             raw_emiss_max_t = [raw_emiss_max_t; raw_max_t];

        end
    end % events in whole signal
else
    disp("There is no data!")
    return
end % count non-zero events

%% 13) save all features in matrices for later analysis
%% rows are emissions and columns are features

    
%% Create folder for dataset matrices if it doesn't exist
dataset_mat_folder = ['../feature_selection/feature_calc_matrices/' dataset_name '/'];
if ~exist(dataset_mat_folder, 'dir')
   mkdir(dataset_mat_folder)
end

save([dataset_mat_folder dataset_name '_UAE_equ_features.mat'], 'emissions', 'raw_feature_matrix','raw_emiss_max_t', 'equ_feature_matrix','equ_emiss_max_t','freq_of_fft_peaks');

save([dataset_mat_folder dataset_name '_UAE_stats.mat'], 'stat_num_interf_LF', 'stat_num_interf_HF','all_emissions', 'emission_without_peak_count','stat_num_evts');

dont_use_raw_matrix = true;
if dont_use_raw_matrix
    raw_feature_matrix = zeros(2,length(equ_feature_matrix(:,1)))+[1;2];
   raw_emiss_max_t = [1,2];
end

Plot_Emission_Stats(false,dataset_name,raw_feature_matrix,equ_feature_matrix,raw_emiss_max_t,equ_emiss_max_t,freq_of_fft_peaks);

disp("Successfully calculated features!");

%% Calculate AE rate curve and cumulative AE curve
%% Chose time interval for point as 15 min
% time_interval = 1/4; % time interval in hours
% calc_AE_rate_and_derivations(equ_emiss_max_t,time_interval)

close all

% writematrix([emissions],'../clustering/comm_with_STM32/emissions.txt');