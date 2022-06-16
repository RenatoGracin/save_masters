function [expanded_signal, expanded_time] = Expand_Around_Max(signal, time, max_ind)
    % get N elements of AE around max amplitude
    % add elements if emission_y is shorter than N points
    global N
    global fs_UAE
    %% NEW WAY
    dT = 1/fs_UAE;
    zero_len = N-length(signal);
    after_max_len = length(signal)-max_ind;
    if N/2 <= max_ind
        expanded_signal = [signal zeros(1,zero_len)];
        expanded_time = [time time(end)+dT:dT:time(end)+(zero_len*dT)];
    elseif N/2 <= after_max_len
        expanded_signal = [zeros(1,zero_len) signal];
        expanded_time = [time(1)-(zero_len*dT):dT:time(1)-dT time];
    else
        expanded_signal = [zeros(1,N/2-max_ind) signal zeros(1,N/2-after_max_len)];
        expanded_time = [time(1)-((N/2-max_ind)*dT):dT:time(1)-dT time  time(end)+dT:dT:time(end)+((N/2-after_max_len)*dT)];
    end

    %% OLD WAY
%     before_y = zeros(1,N/2-max_ind+1); % adding zeros before the emission to reach N/2 in max
%     after_y = zeros(1,N/2-(length(signal)-max_ind)-1); % adding zeros after the emission to reach N/2 in max
%     signal = [before_y signal after_y];
%     before_t = time(1)-(length(before_y)/fs_UAE):1/fs_UAE:time(1)-(1/fs_UAE);
%     after_t = time(end)+(1/fs_UAE):1/fs_UAE:time(end)+(length(after_y)/fs_UAE);
%     time = [before_t time after_t];
%     % take N elements around max amplitude
%     % LOSING INFORMATION when distance from max amplitude is larger than N/2! 
%     [~, max_ind] = max(abs(signal));
%     expanded_signal = signal((max_ind-N/2):(max_ind+N/2-1));
%     expanded_time = time((max_ind-N/2):(max_ind+N/2-1));
 end