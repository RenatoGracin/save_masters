 % Calculates and returns maximum value and index of each emission of signal.
 function [emissions_max_val, emissions_max_ind] = Calc_Max_Of_Emissions(signal, emissions_start_ind, emissions_end_ind)
    signal_ind = 1:length(signal);
    % Get elements between bounds: https://se.mathworks.com/matlabcentral/answers/483773-find-values-of-vector-that-fall-within-multiple-ranges
    emissions_matrix =  signal .* (signal_ind >= emissions_start_ind(:) & signal_ind <= emissions_end_ind(:));
    [emissions_max_val_T, emissions_max_ind_T] = max(abs(emissions_matrix),[],2);
    emissions_max_val = emissions_max_val_T.';
    emissions_max_ind = emissions_max_ind_T.';
 end