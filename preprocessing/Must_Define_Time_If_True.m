% Validation function for calc_bin_envelope.
function Must_Define_Time_If_True(plot_bool,time)
    % Test for time is not empty
    if and(plot_bool, isempty(time))
        eid = 'Time:isEmpty';
        msg = 'Time parametar must not be empty when plotting is true.';
        throwAsCaller(MException(eid,msg))
    end
end