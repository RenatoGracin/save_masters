function Plot_All_Equ(signal, time, phase_spec, amplitude_spec, time_spec)
    global fs_UAE
    N = length(signal);
    emission_f = fs_UAE .* (0:(N/2))/N; % frequency axis
    angle_f = fs_UAE .* (0:(N-1))/N;

    [raw_sig_1, sig_abs_fft_raw, sig_phase_fft_raw] = Equalize(signal, 0);
    [equ_sig_1, sig_abs_fft_1, sig_phase_fft_1] = Equalize(signal, 1);
    [equ_sig_2, sig_abs_fft_2, sig_phase_fft_2] = Equalize(signal, 2);
    [equ_sig_3, sig_abs_fft_3, sig_phase_fft_3] = Equalize(signal, 3);
    
    modes = ["equalized with multiplication","equalized with convolution","equalized with convolution normalized"];

    emission_t = time;

    % plot all equalized and raw in frequency spectre
    if phase_spec
        enabled_modes = Get_High_Bit_Positions(phase_spec);
        figure;
        hold on
        if any(enabled_modes == 1)
            plot(angle_f, sig_phase_fft_1, 'Color', 'y', 'LineWidth', 2)
        end
        if any(enabled_modes == 2)
            plot(angle_f, sig_phase_fft_2, 'Color', 'r')
        end
        if any(enabled_modes == 3)
            plot(angle_f, sig_phase_fft_3, 'Color', 'b')
        end
        grid on
        xlim([min(angle_f) max(angle_f)])
        title('angle ds emission in freq around maximum')
        legend(modes(enabled_modes(:)));
        xlabel('f(Hz)')
        ylabel('<X(f)')
        hYLabel = get(gca,'YLabel');
        set(hYLabel,'rotation',0,'HorizontalAlignment','right')
    end

    if amplitude_spec == amplitude_spec
        enabled_modes = Get_High_Bit_Positions(amplitude_spec);
        figure;
        hold on
        plot(emission_f, sig_abs_fft_raw, 'Color', 'b')
        if any(enabled_modes == 1)
            plot(emission_f, sig_abs_fft_1, 'Color', 'y', 'LineWidth', 2)
        end
        if any(enabled_modes == 2)
            plot(emission_f, sig_abs_fft_2, 'Color', 'r')
        end
        if any(enabled_modes == 3)
            plot(emission_f, sig_abs_fft_3, 'Color', 'g')
        end
        grid on
        xlim([min(emission_f) max(emission_f)])
        title('abs ss emission in freq around maximum')
        descripition = ["raw", modes(enabled_modes(:))];
        legend(descripition(:));
        xlabel('f(Hz)')
        ylabel('|X(f)|')
        hYLabel = get(gca,'YLabel');
        set(hYLabel,'rotation',0,'HorizontalAlignment','right')
    end

    %% plot all equalized and raw in time domain spectre
    % NOTE: convoluted signal has better zero padded area
    if time_spec
        enabled_modes = Get_High_Bit_Positions(time_spec);
        figure;
        hold on
        if any(enabled_modes == 1)
            plot(emission_t, equ_sig_1, 'Color', 'y', 'LineWidth', 2)
        end
        if any(enabled_modes == 2)
            plot(emission_t, equ_sig_2, 'Color', 'r')
        end
        if any(enabled_modes == 3)
            plot(emission_t, equ_sig_3, 'Color', 'g')
        end
        plot(emission_t, signal, 'Color', 'b')
        grid on
        xlim([min(emission_t) max(emission_t)])
        title('emission in time domain around maximum')
        descripition = [modes(enabled_modes(:)),"raw"];
        legend(descripition);
        xlabel('t(s)')
        ylabel('x(t)')
        hYLabel = get(gca,'YLabel');
        set(hYLabel,'rotation',0,'HorizontalAlignment','right')
    end
end