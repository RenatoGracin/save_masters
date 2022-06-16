clc
clear all
close all

%% TRY neutral convolution to equal phase addition
% format long
% t = 0:2*pi/101:2*pi;
% sig1 = sin(t/pi*4);
% sig2 = [zeros(1,25) ones(1,52)*1 zeros(1,25)];
% sig_freq = 2e6 .* (0:(length(sig1)-1))/length(sig1);
% sig_phase = angle(fft(sig1)+fft(sig2));
% con = conv(sig1,sig2);
% con_freq = 2e6 .* (0:(length(con)-1))/length(con);
% con_phase = angle(fft(con));
% figure(7);
% hold on
% plot(sig_freq,sig_phase,'Color','y','LineWidth',3)
% plot(con_freq,con_phase,'Color','r');

load input_matrices/freq_responses
load input_matrices/UAE_one_emission
load input_matrices/UAE_meas_dB_filter

y1 = raw_emission_y;
y2 = h;
c = conv(y1,y2);
y1(y1 == 0) = [];
c2 = conv(y1,y2);

figure;
hold on;
plot(y1);
plot(c2)

% figure;
% hold on
% % plot(f_1M,AEP3N_freq_resp_1M_dB+VS600Z1_freq_resp_1M_dB+DCPL2_freq_resp_1M_dB)
% % plot(f_1M,meas_chain_freq_resp_VS600Z1_1M_dB)
% plot(f_1M,VS600Z1_freq_resp_1M_dB)
% 
% a = 1;

% Freq1 = 1000;
% Freq3 = 3000;
% Fs = 16000;
% T = 1/Fs;
% Nos = (0:128-1)*T;
% Amp = 1.0;
% Signal1 = Amp*sin(2*pi*Freq1*Nos);
% Signal3 = Amp*sin(2*pi*Freq3*Nos);
% 
% Signal4 = conv(Signal1,Signal3); 

% Signal1 = [ zeros(1,length(Signal1)/2-1) Signal1 zeros(1,length(Signal1)/2)];
% Signal3 = [ zeros(1,length(Signal3)/2-1) Signal1 zeros(1,length(Signal3)/2)];

% NFFT = 32;
% freqdata1 = fft(Signal1,NFFT);
% freqdata2 = fft(Signal3,NFFT);
% freqdata4 = fft(Signal4,NFFT);

% for ii = 2:((length(freqdata1)/2)+1)
%       
%    sig1_cc = real(freqdata1(1,ii));
%    sig1_dd = imag(freqdata1(1,ii));
%    Mag1(ii-1) = sqrt((sig1_cc^2)+(sig1_dd^2));
%    Phase1(ii-1) = atan(sig1_dd/sig1_cc);
%    
%    sig2_cc = real(freqdata2(1,ii));
%    sig2_dd = imag(freqdata2(1,ii));
%    Mag2(ii-1) = sqrt((sig2_cc^2)+(sig2_dd^2));
%    Phase2(ii-1) = atan(sig2_dd/sig2_cc);  
%    
%    sig3_cc = real(freqdata4(1,ii));
%    sig3_dd = imag(freqdata4(1,ii));
%    Mag3(ii-1) = sqrt((sig3_cc^2)+(sig3_dd^2));
%    Phase3(ii-1) = atan(sig3_dd/sig3_cc);
%    
%    Newmag(ii-1) = Mag1(ii-1)*Mag2(ii-1);
%    NewPhase(ii-1) = Phase1(ii-1) + Phase2(ii-1); 
%   
% end

% emission_f = Fs .* (0:(length(freqdata1)-1))/length(freqdata1);
% figure;
% hold on
% plot(emission_f, abs(freqdata1).*abs(freqdata2))
% plot(emission_f, abs(freqdata4))
% grid on
% 
% figure;
% hold on
% plot(emission_f, angle(freqdata1)+angle(freqdata2))
% plot(emission_f, angle(freqdata4))
% grid on

hfvt = fvtool(FC,'Fs',Fs,'Color','white','FrequencyScale','Linear');
s = get(hfvt);
hchildren = s.Children;
haxes = hchildren(strcmpi(get(hchildren,'type'),'axes'));
hline = get(haxes,'children');
x = get(hline,'XData'); % 0-1000 kHz
y = get(hline,'YData');

fvtool(ifft(y),1)

%% Compare filter and impulse response
% figure;
% hold on
% grid on
% plot(x.*1000,db2mag(y))
h_fft = fft(h);
N = length(h);
h_fft_ss = (angle(h_fft));
h_fft_ss = h_fft_ss(1:N/2+1); 
h_freq = Fs .* (0:(N/2))/N; % frequency axi
% plot(h_freq,h_fft_ss); %% PLOT PHASE DIFFERENCE

% % Vallen VS600Z1
meas_chain_freq_resp_max = max(meas_chain_freq_resp_VS600Z1_1M);
%% normalizing so resonant freqency response stays the same
meas_chain_freq_resp_corr_one = meas_chain_freq_resp_max ./ meas_chain_freq_resp_VS600Z1_1M;
meas_chain_freq_resp_corr_one(find(f_1M<=1.2e5 | f_1M>=8e5)) = 0;

db_change = max(db(meas_chain_freq_resp_corr_one));
maximum = max(meas_chain_freq_resp_corr_one);

%% normalizing so amplitudes with value 1 stay the same
meas_chain_freq_resp_corr = meas_chain_freq_resp_corr_one;
meas_chain_freq_resp_corr = meas_chain_freq_resp_corr_one/max(meas_chain_freq_resp_corr_one);

% plot(f_1M,meas_chain_freq_resp_corr_one)
FR_positive_frequency_only = meas_chain_freq_resp_corr_one;
FR_data = zeros(1,1002);
FR_data(1:501) = FR_positive_frequency_only;
FR_data(502:1002) = fliplr(FR_positive_frequency_only(1:end));

% f_shift = ifftshift(f);
IR_data = ifft(FR_data);
% plot(IR_data);

IR_fft = fft(IR_data);
N = length(IR_data);
%% CALC AMP
IR_fft_ss = (abs(IR_fft));
IR_fft_ss = IR_fft_ss(1:N/2); 
IR_freq = Fs .* (0:(N/2-1))/N; % frequency axi
% plot(f_1M,IR_fft_ss);
% plot(f_1M,meas_chain_freq_resp_corr_one)
%% CALC PHASE
% IR_fft_ss_pn = (angle(IR_fft));
% IR_fft_ss_pn = IR_fft_ss_pn(1:N/2); 
% IR_freq = Fs .* (0:(N/2-1))/N; % frequency axi
% plot(f_1M,IR_fft_ss_pn);
%% Getting precise result of impulse response

%% NOW TRY WITH CONVOLUTION!
y1=raw_emission_y;

[h,t1] = FC.impz; %% get impulse response of filter
h = h'; %% h matrix must be transpose
y2 = h;


conv(y1,y2);


N=length(y1);
n = N;
freq = Fs .* (0:n/2)/n; % frequency axi

y = db2mag(y);
x = 1000*x;
% plot(x,y,'Color','r')
small_y = zeros(1, length(freq));  

%% 10a) calculate single-sided amplitude spectrum of equalized emission
for ind_f = 1:length(freq)
    small_y(ind_f) = y(min(findnearest(freq(ind_f), x)));          
end 

convol=conv(y1,y2);
conv_fft = fft(convol,n);
f1=fft(y1,n);
f2=fft(y2,n);
mul_fft = f1.*f2;
mul = ifft(mul_fft);
%% Compare in time domain
% figure;
% plot(mul,'Color','y','LineWidth',2)
% hold on
% plot(convol,'Color','r')
% max(mul(1:length(convol))-convol)
%% Compare in freq domain
figure;
f1 = abs(f1);
f1 = f1(1:end/2+1);
%     signal_abs_fft_ss = signal_abs_fft_pn(1:N/2+1); 
%     signal_abs_fft_ss(2:end-1) = 2*signal_abs_fft_ss(2:end-1);
%     signal_abs_fft_ss(1) = 0; % filtriranje DC-a
f2 = abs(f2);
f2 = f2(1:end/2+1);
f2 = small_y;
mul_fft = f1.*f2;
plot(freq,mul_fft,'Color','y','LineWidth',2)
hold on
conv_fft = abs(conv_fft);
conv_fft = conv_fft(1:end/2+1);
plot(freq,conv_fft,'Color','r')
max(abs(mul_fft-conv_fft))

%% Compare filter with real thing
% plot(freq,f2,'Color','y','LineWidth',1)
% hold on
% plot(freq,small_y,'Color','b');
% max(abs(small_y-f2))




% [Newmag' NewPhase']
% [Mag3' Phase3'] 