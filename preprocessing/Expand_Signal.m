% Extracts signal with certain distance or around maximum with predefined number of points.
function [expanded_signal, expanded_time] = Expand_Signal(signal, time, start_ind, end_ind, expand_with_zeros)
    % Returns valid signal segments start and end indices.
    arguments
        signal (1,:) double {mustBeNonempty(signal)}
        time (1,:) double {mustBeNonempty(time)}
        start_ind (1,1) {mustBeGreaterThan(start_ind,0),mustBeNumeric(start_ind)}
        end_ind (1,1) {mustBeGreaterThan(end_ind,start_ind),mustBeNumeric(end_ind)}
        expand_with_zeros (1,1) logical = false
    end
    global N
    global fs_UAE

    sig_len = length(signal);

    if (sig_len < end_ind) || (length(time) ~= sig_len)
        eid = 'SignalLen:isInvalid';
        msg = 'End index must be lesser than signal length. Time and signal must have the same length.';
        throwAsCaller(MException(eid,msg))
    end

    addition = ((end_ind - start_ind + 1) - N)/2;

    if addition < 0
        add_before_len = floor(abs(addition));
        add_after_len = ceil(abs(addition));
        % When signal is given as zero then addition should be filled with zeros
        if expand_with_zeros
            expanded_signal = [zeros(1, add_before_len) signal(start_ind:end_ind) zeros(1, add_after_len)];
        else
            new_start_ind = start_ind - add_before_len;
            new_end_ind = end_ind + add_after_len;

            add_before = [];
            if (new_start_ind < 0)
                add_before = zeros(1,abs(new_start_ind)+1);
                new_start_ind = 1;
            end
            
            add_after = [];
            if (new_end_ind > sig_len)
                add_after = zeros(1,abs(new_end_ind - sig_len));
                new_end_ind = sig_len;
            end
    
            expanded_signal = [add_before signal(new_start_ind:new_end_ind) add_after];
        end
        t_step = 1/fs_UAE;
        new_start_time = time(start_ind) - (t_step*add_before_len);
        new_end_time = time(end_ind) + (t_step*add_after_len);
        expanded_time = [new_start_time:t_step:time(start_ind-1) time(start_ind:end_ind) time(end_ind+1):t_step:new_end_time];
    else % Need to shorten signal to N length.
        [~, max_ind] = max(signal(start_ind:end_ind));
        [expanded_signal, expanded_time] = Expand_Around_Max(signal(start_ind:end_ind), time(start_ind:end_ind), max_ind);
    end
 end