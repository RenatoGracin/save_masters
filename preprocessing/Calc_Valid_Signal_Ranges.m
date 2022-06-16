% Calculate valid emission duration and indices.
 function [emission_start_ind, emission_end_ind] = Calc_Valid_Signal_Ranges(bin_envelope, duration_threshold, plot_bin_env, signal,simulate_time)
  % Returns valid signal segments start and end indices.
    arguments
        bin_envelope (1,:) double {mustBeNonempty(bin_envelope)}
        duration_threshold (1,2) {mustBeNumeric(duration_threshold)}
        plot_bin_env (1,1) logical = false
        signal = []
        simulate_time = []
    end
    global fs_UAE

    envelope_transitions = diff([0 bin_envelope 0]);
    emission_start_ind = find(envelope_transitions > 0);
    emission_end_ind = find(envelope_transitions < 0) - 1;
    emission_dur_T = (emission_end_ind - emission_start_ind + 1) ./ fs_UAE;

    % indices of raw segments satisfying required duration
    % ADD EQUALS OR NOT!
    all_emission_ind = find( (emission_dur_T > duration_threshold(1)) & (emission_dur_T < duration_threshold(2)));

    % calculate start, end and duration of valid signal segment
    emission_start_ind = emission_start_ind(all_emission_ind);
    emission_end_ind = emission_end_ind(all_emission_ind);
    % all_emis_dur_T = raw_emis_dur_T(all_emission_ind);

    % plot signal segment and it's binary envelope
    if plot_bin_env == true
        signal_ind = 1:length(signal);
        emission_matrix =  (signal_ind >= emission_start_ind(:) & signal_ind <= emission_end_ind(:));
        binary_envelope = sum(emission_matrix,1)>0;
        figure;
        hold on
%         simulate_time = 1:length(signal);
        plot(simulate_time, signal, 'Color',[0.3010 0.7450 0.9330])
        env_h = plot(simulate_time, binary_envelope.*max(abs(signal)),'Color','r','LineWidth',2);
%         plot(simulate_time, bin_envelope.*max(abs(signal)),'Color','g','LineWidth',1);
        legend(env_h,'Validated binary envelope of signal based on signal duration')
        grid on
        xlim([min(simulate_time) max(simulate_time)])
        xlabel('Raw scale');
        ylabel('x(t)')
        title('Validated binary envelope of signal based on signal duration')
        hold off
    end
 end