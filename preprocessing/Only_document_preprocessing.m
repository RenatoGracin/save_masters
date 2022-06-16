%% Only document preprocessing
addpath = 'C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\preprocessing\';
dataset_name = 'small_dataset';
% dataset_mat_folder = ['../feature_selection/feature_calc_matrices/' dataset_name '/'];
dataset_mat_folder = [ '..\feature_selection\input_matrices\'];

% load([dataset_mat_folder dataset_name '_UAE_equ_features.mat']);
load([dataset_mat_folder 'big_dataset_UAE_equ_features.mat']);

% load([dataset_mat_folder dataset_name '_UAE_stats.mat']);

dont_use_raw_matrix = true;
if dont_use_raw_matrix
    raw_feature_matrix = zeros(2,length(equ_feature_matrix(:,1)))+[1;2];
   raw_emiss_max_t = [1,2];
end

Plot_Emission_Stats(false,dataset_name,raw_feature_matrix,equ_feature_matrix,raw_emiss_max_t,equ_emiss_max_t,freq_of_fft_peaks);

disp("Successfully calculated features!");