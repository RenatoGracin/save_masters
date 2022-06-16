% Determain if signal in time domain is a LF (low-frequency) interference.
% LF interferneces have freqency peak lower than low_freq_thr.
function ret_val = Filter_LF_Interference(signal)
% Returns 0 if it is not LF interference, else returns 1.
    global N  
    global emission_f
    global low_freq_thr

    [~, signal_max_ind] = max(abs(signal));

    % FFT centered around the time-domain maximum to extract the central frequency
    if ((signal_max_ind-N/2) < 1)        
        signal_cfft = fft(signal(1:N));          
    elseif ((signal_max_ind+N/2-1) > length(signal))
        signal_cfft = fft(signal( (end-N+1):end ));          
    else   
        signal_cfft = fft(signal( (signal_max_ind-N/2):(signal_max_ind+N/2-1) ));
    end                

    % calculate single sided amplitude spectra of signal segment
    % Calculation based on: https://se.mathworks.com/help/matlab/ref/fft.html
    signal_abs_fft_pn = abs(signal_cfft./N); 
    signal_abs_fft = signal_abs_fft_pn(1:N/2+1);     
    signal_abs_fft(2:end-1) = 2*signal_abs_fft(2:end-1);
    % Calculation based on: https://se.mathworks.com/matlabcentral/answers/712808-how-to-remove-dc-component-in-fft
    signal_abs_fft(1) = 0; % filtriranje DC-a

    [~, fft_max_ind] = max(signal_abs_fft);
    fft_max_freq = emission_f(fft_max_ind);
    
    % exclude signal segments with freqency peak lower than low_freq_thr
    if (fft_max_freq < low_freq_thr)
        ret_val = 1;
    else
        ret_val = 0;
    end
end