%% Compare findpeaks results with peak frequency feature

% load ..\feature_selection\input_matrices\big_dataset_UAE_equ_features.mat

% writematrix([emissions],'../clustering/comm_with_STM32/emissions.txt');
emission_example = downsample(emissions{100,5},4) * 1e6;
emission_example(1) = []; %% Remove fisrt element so their will be 128
plot(emission_example);
format
writematrix([emission_example],'../clustering/comm_with_STM32/emiss_abs_fft.txt');
mutiple_peak_first_freq = cellfun(@(v)v(1),freq_of_fft_peaks);
keep_ind = find(~isnan(mutiple_peak_first_freq));
figure;
yvalues = {'peak freq','find peaks'};
feature_matrix = [equ_feature_matrix(keep_ind,18),mutiple_peak_first_freq(keep_ind)'];
heatmap(yvalues,yvalues,corr(feature_matrix))
figure;
hold on
scatter(equ_emiss_max_t_hr,equ_feature_matrix(:,18),5,'red','filled');
scatter(equ_emiss_max_t_hr,mutiple_peak_first_freq,5,'blue','filled');
disp('done');