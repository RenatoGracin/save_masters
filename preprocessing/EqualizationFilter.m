clc
% close all
clear all

%% load signal chain's frequency characteristics, calculate equilization coeficients
% Sensor used: Vallen VS600Z1
% calculate measured chain's frequency response correction function used during equalization
load input_matrices/freq_responses %% signal chain's frequency characteristics - meas_chain_freq_resp_VS600Z1_1M
load input_matrices/UAE_one_emission %% has example emission of signal - raw_emission_y
% sensor_freq_resp = DCPL2_freq_resp_1M_dB + AEP3N_freq_resp_1M_dB + VS600Z1_freq_resp_1M_dB;
sensor_freq_resp = meas_chain_freq_resp_VS600Z1_1M;
inverse_freq_resp = 1./sensor_freq_resp;
inverse_freq_resp(find(f_1M<=1.2e5 | f_1M>=8e5)) = 0;

%%% OLD WAY
% meas_chain_freq_resp_max = max(meas_chain_freq_resp_VS600Z1_1M);
% meas_chain_freq_resp_corr = meas_chain_freq_resp_max ./ meas_chain_freq_resp_VS600Z1_1M;
% meas_chain_freq_resp_corr(find(f_1M<=1.2e5 | f_1M>=8e5)) = 0;

%% plot sensor frequency response and it's correction function
figure;
hold on
% plot(f_1M/1000, sensor_freq_resp,'Color','b','LineWidth',1.5)
plot(f_1M/1000,inverse_freq_resp,'Color','r','LineWidth',1.5)
xlim([min(0) max(1000)])
title("Freqency sensor response correction function")
legend('Correction function');
xlabel('Frequency (kHz)')
ylabel('Magnitude (V)')
grid on

%% curve that the filter FC must fit
fit_curve_dB = db(inverse_freq_resp);
inf_ind = isinf(abs(fit_curve_dB));
db_change = min(fit_curve_dB(~inf_ind));
fit_curve_dB(inf_ind) = db_change;

% figure(31)
% 
% plot(f_1M/1000, fit_curve_dB, 'r','LineWidth',1.5)
% xlim([min(0) max(1000)])
% title("Freqency sensor response correction function in dB")
% legend('Correction function in dB');
% xlabel('Frequency (kHz)')
% ylabel('Magnitude (V)')
% grid on
% grid on

%% numbers for meas curve in Volts
% freqs = [0.5, 0.8, 1.200, 1.400, 1.600, 1.800, 2.000, 2.16, 2.220, 2.450, 2.58, 2.700, 2.880, 3.26, 3.55, 3.76, 3.920, 4.10, 4.50, 5.20, 5.70, 7.98, 8.2]*1e5;
% yGoal = [0.0, 0.0, 34.85, 34.85, 34.85, 34.85, 34.85, 29.0, 29.17, 18.25, 21.1, 18.75, 27.19, 10.0, 9.24, 8.15, 10.78, 4.56, 4.16, 2.14, 2.46, 5.90, 0];
% BWs = [0.5, 0.4, 0.5, 2, 2, 2, 0.5,...
%        0.2 ,0.2, 0.15, 0.1, 0.15, 0.21, 0.3, 0.3, 0.3, 0.1, 0.2, 0.7, 0.8, 0.2, 0.5, 0.4]*1e5;
% Gains = [-4, -15, 12, 10.5, 11.5, 10.5, 6,...
%         -3.45, 3.65, -5.5, 1.15, -3, 11.3, -4, -1, -1, 3.3, -2.2, -1.5, -2,  0.4, 6.9, -3.5];
%% numbers for meas curve that keeps maximum in dB 
freqs = [0.5, 0.7, 0.9, 1.17, 1.200, 1.400, 1.600, 1.800, 2.000, ...
        2.26, 2.48, 2.585, 2.700, 2.9, 3.350, 3.600, 3.920, ...
        4.220, 4.540, 4.80, 5, 5.22, 5.42, 5.72, 6, 6.15, 6.52, ...
        6.72, 6.8, 7.12, 7.26, 7.58, 7.82, 8, 8.2, 8.4, 8.6, 8.9]*1e5;
BWs = [0.5, 0.3, 0.4, 0.2, 0.7, 2, 2, 2, 0.5,...
       0.2 ,0.5, 0.1, 0.1, 0.5, 0.5, 0.5, 0.25, ...
       0.3, 0.5, 0.2, 0.3, 0.2, 0.3, 0.5, 0.1, 0.2, 0.3, ...
       0.1, 0.1, 0.32, 0.1, 0.4, 0.2, 0.4, 0.3, 0.2, 0.4, 0.3]*1e5;
Gains = [-3.5, -4, -13, 4.7, 10.2, 8.3, 10.4, 8.5, 4,...
        3.2, 1, 2, -0.2, 12.6, 2.2, 5.2, 8.6, ...
        2.2, 5.2, 1, 1.4, 1.6, -3.4, 5, -0.6, 2.7, -3.3, ...
        0.3, -1.2, 4, 0.3, 5.1, 2, 16.2, -7.5 ,-1, -1.2, -0.3];

freqs(end+1) = 5*1e5;
BWs(end+1) = 10*1e5;
Gains(end+1) = -1*db(max(sensor_freq_resp));

%% creating sensor response filter 
Fs  = 2e6;
N = 2;
FCs = [];
for ind = 1:length(freqs)
    [B,A] = designParamEQ(N,Gains(ind),freqs(ind)/(Fs/2),BWs(ind)/(Fs/2));
    BQ = dsp.BiquadFilter('SOSMatrix',[B.',[1,A.']]);
    FCs = [FCs;{BQ}];
end

FCs1 = FCs(1:15);
FCs2 = FCs(16:29);
FCs3 = FCs(30:end);
FC  = dsp.FilterCascade(FCs1{:});
FC  = dsp.FilterCascade(FC,FCs2{:});
FC  = dsp.FilterCascade(FC,FCs3{:});

%% Adding bandpass filter from 130 kHz to 800 kHz
%% NOT IN USE: beacause it significantly time shifts when filtering signal
% fpass = [130e3, 800e3] ./ (2e6/2);
% [~, bpass_filter] = bandpass(1:6000, fpass, 'ImpulseResponse', 'fir');
% 
% fir_filter = dsp.FIRFilter(bpass_filter.Coefficients);
% FC  = dsp.FilterCascade(FC,fir_filter);

%% show sensor response filter and extract axis data from it
hfvt = fvtool(FC,'Fs',Fs,'Color','white','FrequencyScale','Linear');
s = get(hfvt);
hchildren = s.Children;
haxes = hchildren(strcmpi(get(hchildren,'type'),'axes'));
hline = get(haxes,'children');
x = get(hline,'XData'); % 0-1000 kHz
y = get(hline,'YData');

%% plot filter and curve to fit
figure;
hold on
plot(f_1M/1000, fit_curve_dB,'Color','y','LineWidth',2)
plot(x,y,'Color','r')
xlim([min(0) max(1000)])
title('Fitting filter to curve of correction function')
legend('Correction function in dB','Filter aproximation of correction function');
xlabel('Frequency (kHz)')
ylabel('Magnitude (dB)')
grid on


%% filter or equalize example raw emission
% x = raw_emission_y(490:692);
% x = [x zeros(1,length(raw_emission_y)-length(x))];
x = raw_emission_y;
[h,t1] = FC.impz; %% get impulse response of filter
h = h'; %% h matrix must be transposed

%% plot impulse response of filtar
figure;
hold on
h_t = [0:1/2e6:(length(h)-1)/2e6];
plot(h_t, h,'Color','b')
xlim([min(h_t) max(h_t)])
title('Impulse response of filter aproximation of correction function')
xlabel('Time (s)')
ylabel('Amplitude (V)')
grid on

% h_norm = h/max(sensor_freq_resp);

%% save filter information so it can be used elsewhere
save(['./input_matrices/UAE_meas_dB_filter_all.mat'], 'freqs', 'BWs', 'Gains','FC','Fs','h');
save(['./input_matrices/UAE_meas_dB_filter_and_impulse.mat'], 'inverse_freq_resp','h');

disp('Saved impulse response h.')

% equalize emission - convolut with impulse response of filter
%% EXAMPLE OF USING FILTER IMPULSE RESPONSE h
% h = [h zeros(1,length(x)-length(h))];
% x = [x zeros(1,length(h)-length(x))];
x_conv = conv(x,h);
x_conv = x_conv(1:length(x));
% x_conv = [zeros(1,489) x_conv zeros(1,1024-692)];
% x_conv = [x_conv zeros(1,1024-length(x_conv))];
% x = [x zeros(1,1024-length(x))];
%% Filter to with bandpass filter - add if needed
% x_conv = bandpass(x_conv, fpass, 'ImpulseResponse', 'fir');

%% plot equilization in time domain
figure;
hold on
plot(x,'Color','b')
plot(x_conv,'Color','r')
legend('raw signal time-domain','equalized signal time-domain')
title('Time domain of Raw and Equalized signal')
xlabel('t(s)')
ylabel('x(t)(V)')
grid on


%% plot equilization in amplitude spectrum
x_fft = abs(fft(x));
x_freq = 2e6 * (1:length(x_fft)/2+1)/length(x_fft);
x_conv_fft = abs(fft(x_conv));
x_conv_freq = 2e6 * (1:length(x_conv_fft)/2+1)/length(x_conv_fft);
x_conv_fft_abs_ss = x_conv_fft(1:end/2+1); 
figure;
hold on
x_fft_ss = x_fft(1:end/2+1);
plot(x_freq,x_fft(1:end/2+1),'Color','b')
plot(x_conv_freq,x_conv_fft_abs_ss,'Color','r','LineWidth',2)
legend('raw signal single-sided amplitude spectrum','equalized signal single-sided amplitude spectrum')
title('Amplitude spectrum of Raw and Equalized signal')
xlabel('f(Hz)')
ylabel('|X(f)|(V)')
xlim([0 1e6])
grid on

signal_abs_fft_ss = x_fft_ss;
N = length(x_fft);
emission_f = 2e6 .* (0:(N/2))/N; % frequency axis
equ_signal_abs_fft_ss = zeros(1, length(emission_f));
low_freq_thr = 120e3;   
high_freq_thr = 850e3;
ind_low_freq = max(find(emission_f < low_freq_thr));
ind_high_freq = min(find(emission_f > high_freq_thr));         

%% 10a) calculate single-sided amplitude spectrum of equalized emission
for ind_f = ind_low_freq:ind_high_freq%1:length(emission_f)
    ind_f_meas_chain_freq_resp = min(findnearest(emission_f(ind_f), f_1M));
    equ_signal_abs_fft_ss(ind_f) = signal_abs_fft_ss(ind_f) .* inverse_freq_resp(ind_f_meas_chain_freq_resp);                
end 

%% plot equilization in amplitude spectrum
figure;
hold on
plot(emission_f,signal_abs_fft_ss,'Color','b')
plot(emission_f,equ_signal_abs_fft_ss,'Color','r','LineWidth',2)
legend('correct raw signal single-sided amplitude spectrum','equalized signal single-sided amplitude spectrum')
title('correct Amplitude spectrum of Raw and Equalized signal')
xlabel('f(Hz)')
ylabel('|X(f)|(V)')
grid on


% save(['../feature_plotting/UAE_emission_freq_mat'], 'x_conv_freq','x_conv_fft_abs_ss');

%% checking curve in freqency domain of made impulse response
%% it is the same except 0 is 1 -> doesnt affect amplitude because original signal is filtered at the begging 
% emission_f = Fs .* (0:(length(h)/2))/length(h);
% figure;
% hold on
% fft_h = abs(fft(h));
% plot(emission_f,fft_h(1:ceil(end/2)),'Color','y','LineWidth',2)
% plot(f_1M,inverse_freq_resp,'Color','r')
% xlim([min(emission_f) max(emission_f)])
% title('Fitting filter to curve of sensor response')
% legend('Inverted curve of sensor response in V','amplitude spectrum of impulse response of made filter');
% xlabel('f(Hz)')
% ylabel('|X(f)|(V)')
% hYLabel = get(gca,'YLabel');
% set(hYLabel,'rotation',0,'HorizontalAlignment','right')
% grid on

