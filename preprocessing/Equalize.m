% Equalizes signal by one of 3 possible ways depending on argument type.
function [equalized_signal, signal_abs_fft_ss, signal_phase_fft_pn, time] = Equalize(signal,time,type, keep_around_max, plotFreqSpec)
% Returns equalized signal in time domain.
    arguments
        signal (1,:) double {mustBeNonempty(signal)}
        time = []
        type (1,1) {mustBeGreaterThanOrEqual(type,0),mustBeLessThan(type,4),mustBeNumeric(type)} = 3
        keep_around_max (1,1) logical = false
        plotFreqSpec (1,1) logical = false
    end
    global h
    global inverse_freq_resp
    global f_1M
    global low_freq_thr
    global high_freq_thr
    global fs_UAE

    %% 9) Equalize raw emissions - 2 ways

    if type == 2
        %% 9b) equalize emission in time-domain by convolution with impulse response h
        %%     of filter aproximating sensor freqency response correction function
        signal = conv(signal,h);
        signal = signal(1:length(time));
        equalized_signal = signal;
    end

    N = length(signal);

    if N~=1024
        disp('Wrong number of points');
    end

    emission_f = fs_UAE .* (0:(N/2))/N; % frequency axi

    % calculate single-sided amplitude spectrum of signal
    equalized_signal = signal;
    signal_fft = fft(signal);

    % https://se.mathworks.com/help/matlab/ref/fft.html?s_tid=srchtitle
    % calculate double-sided amplitude spectrum of emission
    signal_abs_fft_pn = abs(signal_fft./N);
    % calculate single-sided amplitude spectrum of emission
    signal_abs_fft_ss = signal_abs_fft_pn(1:N/2+1); 
    signal_abs_fft_ss(2:end-1) = 2*signal_abs_fft_ss(2:end-1);
    signal_abs_fft_ss(1) = 0; % filtriranje DC-a

    % calculate single-sided phase spectrum of emission
    signal_phase_fft_pn = angle(signal_fft./N);

    if type == 1
        %% 9a) equalize amplitude spectre by multiplying emission in amplitude spectrum
        %%     with sensor freqency response correction function
        equ_signal_abs_fft_ss = zeros(1, length(emission_f));
        ind_low_freq = max(find(emission_f < low_freq_thr));
        ind_high_freq = min(find(emission_f > high_freq_thr));         
    
        %% 10a) calculate single-sided amplitude spectrum of equalized emission
        for ind_f = ind_low_freq:ind_high_freq
            ind_f_meas_chain_freq_resp = min(findnearest(emission_f(ind_f), f_1M));
            equ_signal_abs_fft_ss(ind_f) = signal_abs_fft_ss(ind_f) .* inverse_freq_resp(ind_f_meas_chain_freq_resp);                
        end 
    
        signal_abs_fft_ss = equ_signal_abs_fft_ss;
            
        % calculate double-sided amplitude spectrum of equalized emission
        signal_abs_fft_ds = signal_abs_fft_ss(1:end-1);
        signal_abs_fft_ds(2:end) = signal_abs_fft_ds(2:end)./2;
        signal_abs_fft_ds = [signal_abs_fft_ds,0,fliplr(conj(signal_abs_fft_ds(:,2:end)))];
        % calculate equalized emission in time-domain
        signal_fft = (signal_abs_fft_ds.*(exp(1i*signal_phase_fft_pn))).*N;
        equalized_signal = ifft(signal_fft);
    end
            % plot single-sided amplitude spectrum of emission
    if plotFreqSpec
        figure;
        plot(emission_f, signal_abs_fft_ss)
        grid on
        xlim([min(emission_f) max(emission_f)])
        title('Equalized signal in single-sided amplitude spectrum.')
        xlabel('f(Hz)')
        ylabel('|X(f)|')

        figure;
        plot(emission_f, signal_phase_fft_pn)
        grid on
        xlim([min(emission_f) max(emission_f)])
        title('Equalized signal in double-sided phase spectrum.')
        xlabel('f(Hz)')
        ylabel('<X(f)')
    end
end