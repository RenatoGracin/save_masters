% Calculate binary envelope of emission in signal.
function binary_envelope = Calc_Bin_Envelope(signal, time, plot_norm_env, plot_bin_env)
% Returns binary envelope of emission in signal.
    arguments
        signal
        time = []
        plot_norm_env (1,1) logical {} = false
        plot_bin_env (1,1) logical {} = false
    end
    envelope_threshold = rms(abs(signal));

    [signal_envelope, ~] = envelope(signal, 100, 'rms');

    % plot signal segment and it's normal envelope
    if plot_norm_env == true
        figure;
        hold on
        plot(time,signal,'Color',[0.3010 0.7450 0.9330])
        rms_h = plot(time,signal_envelope,'LineWidth',2,'Color','r','DisplayName','RMS envelope of signal');
        line_h = yline(envelope_threshold,'LineWidth',2,'Color','k','Label','RMS of signal');
        grid on
        legend([rms_h,line_h],{'RMS envelope of signal','Binary enevelope threshold'});
        xlim([min(time) max(time)])
        xlabel('t[s]');
        ylabel('x(t)')
        title('Envelope of signal');
%         saveas(gca,['../figures/preprocessing/rms_envelope_with_threshold'],'fig')
    end
    
    binary_envelope = (signal_envelope >= envelope_threshold);

    % plot signal segment and it's binary envelope
    if plot_bin_env == true
        figure;
        hold on
        plot(time, signal,'Color',[0.3010 0.7450 0.9330])
        bin_env_h = plot(time, binary_envelope.*max(abs(signal)),"Color",'r','LineWidth',1);
        legend(bin_env_h,'Binary envelope of signal')
        grid on
        xlim([min(time) max(time)])
%         yline(envelope_threshold);
        xlabel('t[s]');
        ylabel('x(t)')
        title('Binary envelope of signal')
%         saveas(gca,['../figures/preprocessing/bin_envelope'],'fig')
    end
end