function calc_AE_rate_and_derivations(equ_emiss_max_t,time_interval)
    equ_emiss_max_t_hr = equ_emiss_max_t./3600;
    
    AE_rate_per_time_inteval = [];
    AE_cumulative_per_time_inteval = [];
    cumulative_AE = 0;
    equ_emiss_max_t_time_interval = equ_emiss_max_t_hr/time_interval;
    equ_emiss_t_time_interval =  0:ceil(equ_emiss_max_t_time_interval(end))-1;
    for time_interval_num = equ_emiss_t_time_interval
        AE_sum = sum(floor(equ_emiss_max_t_time_interval) == time_interval_num); 
        AE_rate_per_time_inteval = [AE_rate_per_time_inteval, AE_sum];
        cumulative_AE = cumulative_AE + AE_sum;
        AE_cumulative_per_time_inteval = [AE_cumulative_per_time_inteval, cumulative_AE];
    end
    
    figure;
    plot(equ_emiss_t_time_interval,AE_rate_per_time_inteval);
    title('AE rate')
    xlabel(['time in ' num2str(time_interval*60) ' min'])
    ylabel('AE rate')
    
    figure
    plot(equ_emiss_t_time_interval,AE_cumulative_per_time_inteval);
    title('AE cumulative')
    xlabel(['time in ' num2str(time_interval*60) ' min'])
    ylabel('AE cumulative')
    p50_ind = min(find(length(equ_emiss_max_t_hr)*0.5 < AE_cumulative_per_time_inteval));
    xline(equ_emiss_t_time_interval(p50_ind),'Label','P50');
    p88_ind = min(find(length(equ_emiss_max_t_hr)*0.12 < AE_cumulative_per_time_inteval));
    xline(equ_emiss_t_time_interval(p88_ind),'Label','P88');
    p12_ind = min(find(length(equ_emiss_max_t_hr)*0.88 < AE_cumulative_per_time_inteval));
    xline(equ_emiss_t_time_interval(p12_ind),'Label','P12');
    
    %% Calculate first derivation od AE rate curve
    
    emission_rate_first_derv = [];
    for time_ind = 1:length(AE_cumulative_per_time_inteval)-1
        derv_val = (AE_cumulative_per_time_inteval(time_ind+1) - AE_cumulative_per_time_inteval(time_ind));
        emission_rate_first_derv = [emission_rate_first_derv, derv_val];
    end
    
    figure;
    plot(equ_emiss_t_time_interval(1:end-1),emission_rate_first_derv);
    title('First derivation of AE cumulative')
    xlabel(['time in ' num2str(time_interval*60) ' min'])
    ylabel('AE cumulative 1st derivation')
    
    %% Calculate second derivation od AE rate curve
    
    emission_rate_second_derv = [];
    for time_ind = 1:length(emission_rate_first_derv)-1
        derv_val = (emission_rate_first_derv(time_ind+1) - emission_rate_first_derv(time_ind));
        emission_rate_second_derv = [emission_rate_second_derv, derv_val];
    end
    
    figure;
    plot(equ_emiss_t_time_interval(1:end-2),emission_rate_second_derv);
    title('Second derivation of AE cumulative')
    xlabel(['time in ' num2str(time_interval*60) ' min'])
    ylabel('AE cumulative 2nd derivation')

    %% Calculate third derivation od AE rate curve
    
    emission_rate_third_derv = [];
    for time_ind = 1:length(emission_rate_second_derv)-1
        derv_val = (emission_rate_second_derv(time_ind+1) - emission_rate_second_derv(time_ind));
        emission_rate_third_derv = [emission_rate_third_derv, derv_val];
    end
    
    figure;
    plot(equ_emiss_t_time_interval(1:end-3),emission_rate_third_derv);
    title('Third derivation of AE cumulative')
    xlabel(['time in ' num2str(time_interval*60) ' min'])
    ylabel('AE cumulative 3rd derivation')

%     figure;
%     plot(0:ceil(equ_emiss_max_t_hr(end))-1,emission_rate_per_hr);
%     figure;
%     bar(emission_rate_per_hr)
end