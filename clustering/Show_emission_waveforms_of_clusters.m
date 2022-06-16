%% Choose dataset
dataset_name = 'small_dataset';
% dataset_name = "big_dataset";

%% Load emission waveforms 
load(['../feature_selection/input_matrices/' dataset_name '_UAE_equ_features.mat']);

%% Load certain feature selected results
load(['' dataset_name '_feature_selection_with_DBCV_id_tpe0ed4582_e001_41db_b0e8_a0fe6841b677.mat'])

%% Get cluster labels for certain feature subset
feature_subset = [1,15,18];

labels = [];
for subset_ind = 1:length(subsets)
    if isempty(setdiff(feature_subset,subsets{subset_ind}))
        [~,best_res_ind] = max(dbcv_indices(subset_ind,:));
        labels = all_labels_dbcv{subset_ind,best_res_ind};
        break;
    end
end

if isempty(labels)
    disp('Feature subset doesnt exist!');
    return;
end

%% Show feature subset clustering results
show_3D_clustering(feature_matrix(:,feature_subset),labels);

%% Show emission waveforms for certain selected feature subset cluster
u_labels = unique(labels);

disp('Cluster labels:')
disp(u_labels)
chosen_cluster_ids = [1,2];
% cluster_sample_perc = 0.5;
num_of_emiss = 20;

%% Show total raw signal of emission in time domain
chosen_waveform = [8,7]; % UAE_evt_t, UAE_evt_y
title_str = 'Total raw signal of emission in time domain';
xlabel_str = 'time [h]';
ylabel_str = 'x(t) [V]';

%% Show seperated raw signal of emission in time domain
% chosen_waveform = [2,1]; % emission_t, emission_y
% title_str = 'Seperated raw signal of emission in time domain';
% xlabel_str = 'time [h]';
% ylabel_str = 'x(t) [V]';

%% Show seperated equalized signal of emission in time domain
% chosen_waveform = [4,3]; % equ_emission_t, equ_emission_y
% title_str = 'Seperated equalized signal of emission in time domain';
% xlabel_str = 'time [h]';
% ylabel_str = 'x(t) [V]';

%% Show seperated equalized signal of emission in frequency domain
% chosen_waveform = [6,5]; % emission_f, equ_emission_abs_fft_ss
% title_str = 'Seperated equalized signal of emission in frequency domain';
% xlabel_str = 'frequency [Hz]';
% ylabel_str = 'x(f) [V]';

for cluster_ind = 1:length(u_labels)
    if ismember(u_labels(cluster_ind),chosen_cluster_ids)
        cluster_global_indices = find(labels==u_labels(cluster_ind));
        clust_len = length(cluster_global_indices);
        if exist('num_of_emiss', 'var')
           cluster_sample_perc = num_of_emiss/clust_len;
        end
        chosen_emiss_ind = randsample(cluster_global_indices,clust_len*cluster_sample_perc);
        for i = 1:length(chosen_emiss_ind)
            figure;
            plot(emissions{chosen_emiss_ind(i),chosen_waveform(1)},emissions{chosen_emiss_ind(i),chosen_waveform(2)})
            title([title_str ' for cluster ' num2str(u_labels(cluster_ind))]);
            xlabel(xlabel_str);
            ylabel(ylabel_str);
        end
    end
end


