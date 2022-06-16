function [signal, valid_emiss_start_ind, valid_emiss_end_ind, emissions_max_ind,binary_envelope] = Get_Emission_From_Signal(signal, time, ...
 remove_LF_inter, filter_unwanted_freq, filter_HF_inter, filter_by_peaks, keep_one_emission, plotValidEmiss)
    global stat_num_interf_LF
    global stat_num_interf_HF
    global all_emissions
    global emission_without_peak_count
    global bpass_filter
    global emission_min_dur_thr
    global emission_max_dur_thr
    global peak_amp_thr
    global low_freq_thr
    global high_freq_thr
    global fs_UAE

    binary_envelope = [];
    valid_emiss_start_ind = [];
    valid_emiss_end_ind = [];
    emissions_max_ind = [];

    if remove_LF_inter
        %% 2) exclude low-frequency interferences from the dataset
        if (Filter_LF_Interference(signal) > 0) % freq. domain LF
            disp('Skipped: LF interference')
            stat_num_interf_LF = stat_num_interf_LF + 1;
            return
        end
    end

    %% 3) Filter signal to keep frequencies 120-800 kHz
    if filter_unwanted_freq
       signal = Filter_Unwanted_Freq(signal,low_freq_thr,high_freq_thr,fs_UAE);
    end

    %% 4) Calculate binary envelope of emission in signal segment - used to split emission from noise
    [bin_env_mask] = Calc_Bin_Envelope(signal, time, false, false);

     %% 5) Split emission from noise using binary envelope
    [all_emis_seg_start_ind, all_emis_seg_end_ind] = Calc_Valid_Signal_Ranges(bin_env_mask, [emission_min_dur_thr, emission_max_dur_thr], false, signal,time);

    if filter_HF_inter
        if isempty(all_emis_seg_start_ind)
            disp('Skipped: HF interference')
            stat_num_interf_HF = stat_num_interf_HF + 1;
            return
        end
    end

    % add number of emissions in event to total number of emissions
    all_emissions = all_emissions + length(all_emis_seg_start_ind);

    % Calculate maximum value and index of all emissions.
    if filter_by_peaks || keep_one_emission
        [emissions_max_val, emissions_max_ind] = Calc_Max_Of_Emissions(signal, all_emis_seg_start_ind, all_emis_seg_end_ind);
    end

    %% Init valid emission indices
    valid_emission_ind = 1:length(all_emis_seg_start_ind);

    %% 7) Exclude emissions with no peaks
    % exclude raw emissions with max amplitude lower than peak_amp_thr
    if filter_by_peaks
        valid_emission_ind = find(emissions_max_val > peak_amp_thr);
        emission_without_peak_count=emission_without_peak_count + (length(all_emis_seg_start_ind)-length(valid_emission_ind));

        if isempty(valid_emission_ind)

%             figure;
%             hold on
%             plot(time,signal,'Color',[0.3010 0.7450 0.9330])
%             ind = [1:length(signal)];
%             for i = 1:length(all_emis_seg_end_ind)
%                 if signal(emissions_max_ind(i))
%                     emissions_max_val(ind) = emissions_max_val(i)*-1;
%                 end
%                 plot(time,emissions_max_val(i)*(ind<all_emis_seg_end_ind(i) & ind > all_emis_seg_start_ind(i)),'Color','r',LineWidth=1)
%                 plot(time(emissions_max_ind(i)), emissions_max_val(i), 'xr', 'MarkerSize',10,'LineWidth',2)
%             end

            return
        end
    end
    

    %% 8) Split emissions OR Choose best emission
    if keep_one_emission
        % Get index of emission (best emission) that has highest maximum value
        [~, valid_emission_ind]= max(emissions_max_val);
    end

    signal_ind = 1:length(signal);
    emission_start_ind = all_emis_seg_start_ind(valid_emission_ind);
    emission_end_ind = all_emis_seg_end_ind(valid_emission_ind);
    emission_matrix =  (signal_ind >= emission_start_ind(:) & signal_ind <= emission_end_ind(:));
    binary_envelope = sum(emission_matrix,1)>0;

    if plotValidEmiss
        % plot signal segment and it's binary envelope
        figure;
        hold on
        plot(time, signal)
        plot(time, binary_envelope.*max(abs(signal)),'LineWidth',1)
        grid on
        xlim([min(time) max(time)])
        xlabel('t[s]');
        ylabel('x(t)')
        title('Ultra validated binary envelope of signal')
        hold off
    end

    emissions_max_ind = emissions_max_ind(valid_emission_ind);
    valid_emiss_start_ind = all_emis_seg_start_ind(valid_emission_ind);
    valid_emiss_end_ind = all_emis_seg_end_ind(valid_emission_ind);
end