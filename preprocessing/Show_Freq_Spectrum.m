% plots amplitude spectrum of given signal around given number of points.
function Show_Freq_Spectrum(signal, num_points, sampling_freq)
    [~, signal_max_ind] = max(abs(signal));

    % FFT centered around the time-domain maximum to extract the central frequency
    if ((signal_max_ind-num_points/2) < 1)        
        signal_cfft = fft(signal(1:num_points));          
    elseif ((signal_max_ind+num_points/2-1) > length(signal))
        signal_cfft = fft(signal( (end-num_points+1):end ));          
    else   
        signal_cfft = fft(signal( (signal_max_ind-num_points/2):(signal_max_ind+num_points/2-1) ));
    end                
    
    freq_spectrum = sampling_freq .* (0:(num_points/2))/num_points;

    % calculate single sided amplitude spectra of signal segment
    % Calculation based on: https://se.mathworks.com/help/matlab/ref/fft.html
    signal_abs_fft_pn = abs(signal_cfft./num_points); 
    signal_abs_fft = signal_abs_fft_pn(1:num_points/2+1);     
    signal_abs_fft(2:end-1) = 2*signal_abs_fft(2:end-1);
    % Calculation based on: https://se.mathworks.com/matlabcentral/answers/712808-how-to-remove-dc-component-in-fft
    signal_abs_fft(1) = 0; % filtriranje DC-a

    figure;
    plot(freq_spectrum, signal_abs_fft)
    ylabel('|X(f)|')
    xlabel('f[Hz]')
    title('Amplitude spectrum of signal')

    % calculate single sided phase spectra of signal segment
    signal_phase_fft_pn = angle(signal_cfft./num_points); 
    signal_phase_fft = signal_phase_fft_pn(1:num_points/2+1);     
    signal_phase_fft(2:end-1) = 2*signal_phase_fft(2:end-1);
    % Calculation based on: https://se.mathworks.com/matlabcentral/answers/712808-how-to-remove-dc-component-in-fft
    signal_phase_fft(1) = 0; % filtriranje DC-a

    figure;
    plot(freq_spectrum, signal_phase_fft)
    ylabel('<X(f)')
    xlabel('f[Hz]')
    title('Phase spectrum of signal')
end
