function filtered_signal = Filter_Unwanted_Freq(signal,low_freq_thr,high_freq_thr,fs)
%filter_unwanted_freq Summary of this function goes here
%   Detailed explanation goes here
       fpass = [low_freq_thr, high_freq_thr] ./ (fs/2);
       filtered_signal = bandpass(signal, fpass, 'ImpulseResponse', 'fir');
end

