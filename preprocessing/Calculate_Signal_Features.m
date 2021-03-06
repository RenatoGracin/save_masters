function   [feature_row, max_t,sorted_peak_freqs,sorted_peak_vals] = Calculate_Signal_Features(emission_t,emission_y, emission_abs_fft_ss,peak_amp_thr)    
    global fs_UAE
    emission_f = fs_UAE * (1:length(emission_y)/2+1)/length(emission_y);
    feature_row = [];
    % calculate features of AE
    % init variables
    [max_y, max_y_ind] = max(abs(emission_y));
    max_t = emission_t(max_y_ind);

    [max_fft, max_fft_ind] = max(emission_abs_fft_ss);
    max_f = emission_f(max_fft_ind);

    ind_thr_cross = find(abs(emission_y)>0);
    valid_emission_y = emission_y(ind_thr_cross(1):ind_thr_cross(end));
    valid_emission_t = emission_t(ind_thr_cross(1):ind_thr_cross(end));
    ind_peaks = find(abs(emission_y)>peak_amp_thr);

    t_0 = emission_t(ind_thr_cross(1)); % Time of first threshold crossing (arrival time)
    t_end = emission_t(ind_thr_cross(end)); % Time of last threshold crossing (arrival time)
    N_AE = length(ind_peaks); % Number of threshold crossings
    t_AE = t_end-t_0; % Time between first and last threshold crossing of signal
    U_max = max_y; % Maximum signal voltage
    t_peak = max_t; % Time of maximum signal voltage
    f_peak = max_f; % Frequency of maximum signal contribution
    N_peak = length(ind_peaks(ind_peaks<=max_y_ind)); % Number of threshold crossings between t_0 and t_peak
    N_peak_after = length(ind_peaks(ind_peaks>max_y_ind)); % Number of threshold crossings between t_peak and t_end
    FREQFP = trapz(emission_abs_fft_ss.^2) ;% FULL POWER of FREQUENCY SPECTRUM

    %% RISE TIME [s] - the time interval between the start of signal and the signal peak amplitude
    feature_row = [feature_row, t_peak-t_0];

    %% COUNTS TO PEAK [#] - counts of peaks higher than peak_amp_thr before peak amplitude of signal in time-domain
    feature_row = [feature_row, N_peak];

    %% COUNTS FROM PEAK [#] - counts of peaks higher than peak_amp_thr after peak amplitude of signal in time-domain
    feature_row = [feature_row, N_peak_after];

    %% DURATION [s] - time difference between start and end of signal
    feature_row = [feature_row, t_end- t_0];
    % ili  UAE_dur_series = [UAE_dur_series; emission_t(end)-emission_t(1)];

    %% PEAK AMPLITUDE [V] - maximum amplitude of signal in time-domain
    %% Use in dB?
    feature_row = [feature_row, U_max];

    %% AVERAGE(ABSOLUTE) FREQUENCY [Hz] - number of all threshold peak_amp_thr through duration of emission
    feature_row = [feature_row, N_AE/t_AE];
     % ili  UAE_avg_freq_series = [UAE_avg_freq_series; meanfreq(emission_y,fs_UAE)];

    %% ROOT MEAN SQUARE VOLTAGE [V] - root of mean of squared values of signal in time-domain
    %% Only calculate on valid emission because of length of signal
    feature_row = [feature_row, rms(valid_emission_y)]; %% RMS should be done with integral

    %% AVERAGE SIGNAL LEVEL [dB] - mean of absolute values of signal in time-domain
    %% SQRT of dB -> should first db2mag then sqrt then mag2db -> link:https://math.stackexchange.com/questions/4063351/sqrt-of-db-number
    feature_row = [feature_row, db(sqrt(db2mag(trapz(valid_emission_t,(db(abs(valid_emission_y)))/length(valid_emission_y)))))]; %% Change to Root Mean Decibel
%     asl_aprox = db(sqrt(db2mag(mean((db(abs(valid_emission_y)))))));

    %% REVERBERATION FREQUENCY [Hz] - number of all peak_amp_thr crossings between peak amplitude and end of AE signal
    feature_row = [feature_row, N_peak_after/(t_end-t_peak)];

    %% INITIATION FREQUENCY [Hz] - number of all peak_amp_thr crossings between start of AE and peak amplitude 
    feature_row = [feature_row, N_peak/(t_peak-t_0)];sqrt

    %% SIGNAL STRENGTH [Vs] - integral of absolute values of signal in time-domain
    %% Don't use valid_emission_y beacuse their so no zero at end of signal so that surface is missed
    feature_row = [feature_row, trapz(emission_t,abs(emission_y))];

    %% ABSOLUTE ENERGY [aJ] - integral of absolute squared values of signal in time-domain divided by reference resistance of 10 kOhm  
    feature_row = [feature_row, trapz(emission_t,(abs(emission_y).^2)./1e3)];

    %% PARTIAL POWER 0-100 kHz of FREQUENCY SPECTRUM [%] - ratio of total and partial integral of squared values of signal in frequency-domain between 0-100 kHz 
    pp1_ind = find(emission_f<1e5);
    feature_row = [feature_row, trapz(emission_abs_fft_ss(pp1_ind).^2)/FREQFP];

    %% PARTIAL POWER 100-200 kHz of FREQUENCY SPECTRUM [%] - ratio of total and partial integral of squared values of signal in frequency-domain between 100-200 kHz
    pp2_ind = find(emission_f>=1e5 & emission_f<2.5e5);
    feature_row = [feature_row, trapz(emission_abs_fft_ss(pp2_ind).^2)/FREQFP];

    %% PARTIAL POWER 200-400 kHz of FREQUENCY SPECTRUM [%] - ratio of total and partial integral of squared values of signal in frequency-domain between 200-400 kHz
    pp3_ind = find(emission_f>=2.5e5 & emission_f<4.25e5);
    feature_row = [feature_row, trapz(emission_abs_fft_ss(pp3_ind).^2)/FREQFP];

    %% PARTIAL POWER 400-800 kHz of FREQUENCY SPECTRUM [%] - ratio of total and partial integral of squared values of signal in frequency-domain between 400-800 kHz
    pp4_ind = find(emission_f>=4.25e5 & emission_f<8e5);
    feature_row = [feature_row, trapz(emission_abs_fft_ss(pp4_ind).^2)/FREQFP];

    %% FREQUENCY CENTROID [Hz] - weighted mean of the frequencies present in signal in frequency-domain
    freq_cent = trapz(emission_f,emission_f.*emission_abs_fft_ss)/trapz(emission_f,emission_abs_fft_ss);
    feature_row = [feature_row, freq_cent];

    %% PEAK FREQUENCY [Hz] - frequency of maximum amplitude of signal in frequency-domain
    feature_row = [feature_row, f_peak];

    %% AMPLITUDE OF PEAK FREQUENCY [Hz] - maximum amplitude of signal in frequency-domain
    feature_row = [feature_row, max_fft];
    
    %% FREQUENCY PEAKS [Hz] - peaks of signal in frequency-domain
%     [peaks, peaks_ind,W] = findpeaks(emission_abs_fft_ss, "MinPeakHeight",limit_fft,MinPeakProminence=limit_fft);
%     findpeaks(emission_abs_fft_ss, emission_f, MinPeakHeight =limit_fft*2,MinPeakProminence=limit_fft);

%     fig = figure('visible','off');
%     hold on
%     findpeaks(emission_abs_fft_ss, emission_f, MinPeakHeight =limit_fft*2,MinPeakProminence=limit_fft);
%     norm_amp_spec = (emission_abs_fft_ss-min(emission_abs_fft_ss))/(max(emission_abs_fft_ss)-min(emission_abs_fft_ss));
    norm_amp_spec = emission_abs_fft_ss./max_fft;
    peak_prom_thr = 0.25;       % normalized, percentage of max.
    peak_width_thr = 10e3;     % Hz
%     [peaks,~] = findpeaks(norm_amp_spec, emission_f, 'MinPeakProminence', peak_prom_thr, 'MinPeakWidth', peak_width_thr, 'MinPeakHeight', min_peak_height,...
%                 'WidthReference','halfprom','Annotate','extents');
    [peaks,peak_freqs] = findpeaks(norm_amp_spec, emission_f, 'MinPeakProminence', peak_prom_thr, 'MinPeakWidth', peak_width_thr);
%     figure;
%     findpeaks(norm_amp_spec, emission_f, 'MinPeakProminence', peak_prom_thr, 'MinPeakWidth', peak_width_thr,'Annotate','extents');
%     grid on
%     xlabel('f[Hz]')
%     ylabel('|X(f)|[V]')
%     box on
%     global equ_emiss_max_t
%     emiss_ind = num2str(length(equ_emiss_max_t)+1);
%     title(['Find peaks graph for emission ' emiss_ind])
%     global dataset_name
%     saveas(fig, ['../figures/preprocessing/features_calculation_results/' dataset_name '_findpeaks_for_emiss' emiss_ind ], 'fig')
    sorted_peak_vals = [];
    sorted_peak_freqs = [];

    if length(peaks) > 0
        %% Save and sort peak from highest to lowest
        [sorted_peak_vals, sorted_peaks_ind] = sort(peaks,'descend');
        sorted_peak_freqs = peak_freqs(sorted_peaks_ind);
    
        %% Emissions with one or mutiple peaks that is not maximum are really 2 peak emissions
        if ~ismember(peak_freqs,max_f)
            sorted_peak_freqs = [sorted_peak_freqs, max_f];
            sorted_peak_vals = [sorted_peak_vals, max_fft];
        end
    end
    feature_row = [feature_row, length(sorted_peak_vals)];


    %% WEIGHTED FREQUENCY PEAK [Hz] - weighted frequency peak of signal in frequency-domain
    feature_row = [feature_row, sqrt(freq_cent*f_peak)];

    %% ALL COUNTS [#] - counts of peaks higher than peak_amp_thr of signal in time-domain
    feature_row = [feature_row, N_AE];

    %% FALL TIME [s] - the time interval between the signal peak amplitude and end of the signal
    feature_row = [feature_row, t_end-t_peak];
end