clc
close all
clear all

dataset_name = 'small_dataset';
% dataset_name = 'big_dataset';

load(['input_matrices/' dataset_name '_UAE_equ_features.mat']);
path = ['../figures/feature_selection/' , dataset_name];

% find index when mixed data begins
equ_emiss_max_t_hr = (equ_emiss_max_t) ./ 3600;
ind_negativ_end = min(find(equ_emiss_max_t_hr>300));

% Turn ASL back to V
equ_feature_matrix(:,8) = db2mag(equ_feature_matrix(:,8));

feature_matrix = equ_feature_matrix;

%% 0) Standardize feature matrix 
% mentioned here: https://medium.com/analytics-vidhya/principal-component-analysis-pca-8a0fcba2e30c

% Remove rows that have element with inf value
err_rows = [];

for feat_ind = 1:length(feature_matrix(1,:))
    x = feature_matrix(:,feat_ind);
    err_ele_ind = find(isinf(x) | isnan(x))';
    if ismember(err_ele_ind,err_rows) == 0
        err_rows = [err_rows,err_ele_ind];
    end
end

feature_matrix(err_rows,:) = [];

peak_freqs =  feature_matrix(:,18);
peak_around_200k_ind = find((peak_freqs >  1.8e5) & (peak_freqs < 2.1e5));
peak_other_ind = find(~((peak_freqs >  1.8e5) & (peak_freqs < 2.1e5)));

time_amps =  feature_matrix(:,5);
time_amp_over_1_2mV_ind = find(time_amps >  12e-4);
time_amp_other_ind = find(~(time_amps >  12e-4));

max_ftt =  feature_matrix(:,19);
freq_amp_over_70uV_ind = find(max_ftt >  7e-5);
freq_amp_other_ind = find(~(max_ftt >  7e-5));

freq_peaks_count = feature_matrix(:,20);

freq_peak_under_5_ind = find(freq_peaks_count <  5);
freq_peak_other_ind = find(~(freq_peaks_count <  5));


% figure;
% grid on
% hold on
% scatter(equ_emiss_max_t_hr(freq_amp_over_0_7uV_ind),feature_matrix(freq_amp_over_0_7uV_ind,18),'red',Marker='square',SizeData=5)
% scatter(equ_emiss_max_t_hr(time_amp_over_1_2mV_ind),feature_matrix(time_amp_over_1_2mV_ind,18),'yellow',Marker='square',SizeData=5)

% Standardization
for feat_ind = 1:length(feature_matrix(1,:))
    % Standardization with z-score using formula x_norm = (x-mean(x))/std(x);
    % link: https://www.indeed.com/career-advice/career-development/how-to-calculate-z-score
    x = feature_matrix(:,feat_ind);
    feature_matrix(:,feat_ind) = (x-min(x))/(max(x)-min(x));

end

vbls2 = {'rise time','counts to','counts from','duration',...
        'peak amplitude','average frequency','rms','asl','reverbation frequency',...
        'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',...
        'pp3','pp4','centroid frequency','peak frequency','amplitude of peak frequency','num of freq peaks', 'weighted peak frequency''weighted peak frequency',...
        'total counts','fall time'};

%% Laplacian score feature selection
% [idx, score] = fsulaplacian(feature_matrix);
% 
% figure;
% grid on
% scatter(1:20,score(idx),'black','filled')
% xlab = vbls2(idx);
% xticks([1:20]);
% xticklabels(xlab);
% ylabel('Laplace score');
% title('Feature selection based on Laplace score');

%% SVD entropy feature selection 
%% link: https://sci-hub.se/https://dl.acm.org/doi/abs/10.1016/j.ins.2013.12.029
%% The bigger the entropy the smaller feature contribution
% CE = Calc_All_CE(feature_matrix);
% 
% figure;
% grid on
% [CE_sort, sort_ind] = sort(CE);
% scatter(1:20,CE_sort,'black','filled')
% xlab = vbls2(sort_ind);
% xticks([1:20]);
% xticklabels(xlab);
% ylabel('Contribution of feature SVD entropy');
% title('Feature selection based on SVD entropy');

%% Simple feature selection
% Calc_Crit = @(data) Calc_All_CE(data);
% 
% [high_feats,avg_feats,low_feats] = Simple_Feature_Selection(feature_matrix,Calc_Crit);

%% Forward feature selection
% Calc_First = @(data) Calc_Highest_CE(data);
% Crit_Func = @(data) Calc_SVD_Entropy(data);
% Calc_All = @(data) Calc_All_CE(data);
% feats_order = Forward_Feature_Selection(feature_matrix,Calc_First,Crit_Func,2,Calc_All);
% 
% disp(vbls2(feats_order));

%% Backward feature selection
% Calc_Func = @(data) Calc_All_CE(data);
% feats_order = Backward_Feature_Selection(feature_matrix,Calc_Func);
% 
% disp(vbls2(feats_order));


%% Matlab function for forward or backward feature selection - DOESN'T WORK!!
% fun = @(data1,unused1,data2,unused2)Compare_SVD_Entropy(data1,data2);
% options = statset('Display','iter');
% [inmodel,history] = sequentialfs(fun,feature_matrix,feature_matrix,'cv','none','direction','forward','nullmodel',true,'options',options);

%% Remove potential outliers that affect PCA results
% emiss_outlier_ind = find(feature_matrix(:,5)>1); 
% 
% feature_matrix(emiss_outlier_ind,:) = [];

%% 1) Calculate correleogram of features against features
% Make predictions, but don't remove features beacuse strong correlation
% can still help better classify data -> link:
figure;
yvalues = {'RISE','CNT TO','CNT FROM','DUR'...
            'AMP','AVG FREQ','RMS','ASL','REV FREQ',...
            'INIT FREQ','SIG STR','AENG','PP1','PP2','PP3'...
            'PP4','CEN FREQ','PEAK FREQ','AMP OF PEAK FREQ','FREQ PEAK CNT', 'WPC',...
            'CNT ALL', 'FALL'};
heatmap(yvalues,yvalues,corr(feature_matrix),'XLabel','Features','YLabel','Features');
title(['Equalized correleogram of features'])
colormap turbo
saveas(gcf,[path '_equalized_correleogram_of_features'], 'fig')

% MATLAB feature selection: https://se.mathworks.com/help/stats/feature-selection.html#mw_ef6af785-15ec-4128-a6c2-8d29614825b7
%% 1.5) Try other methods of feature selection
% Rank features for unsupervised learning using Laplacian scores
% link: https://se.mathworks.com/help/stats/fsulaplacian.html#mw_abd018ae-4ff4-453b-8bdb-1b500b383233
%     input = equ_feature_matrix;
% 
%     [idx,scores] = fsulaplacian(input, 'Distance','seuclidean');
%     disp(yvalues(idx));

%% 2) PCA of features - don't center because we already standardized
[coeff, score, latent, tsquared, explained, mu] = pca(feature_matrix,"Centered",false);

% [coeff,score,latent,tsquared,explained, mu] = pca(feature_matrix,'VariableWeights','variance');

%% Plot principal components based on containing variance in dataset
%% Mark red PC which make more then 85% variance of dataset
variance_threshold = 85;
names = {'PC1'; 'PC2'; 'PC3'; 'PC4'; 'PC5'; 'PC6'; 'PC7'; 'PC8'; 'PC9'; 'PC10';...
    'PC10';'PC11';'PC12';'PC13';'PC14';'PC15';'PC16';'PC17';'PC18';'PC19';'PC20'};
number_of_principals = min(find(cumsum(explained)>variance_threshold));

% colors = [];
% for num = 1:number_of_principals
%     colors = [colors;[1 0 0]];
% end
% b = bar(explained(1:10));
% b.FaceColor = 'flat';
% b.CData(1:number_of_principals,:) = colors;
% xticklabels(names(1:10));
% title('Percentage of the total variance explained by each principal component');
% legend(['Principal components that explain ' num2str(variance_threshold) '% of dataset variance'])
% xlabel('Principal components')
% ylabel('Percentage[%]')
% grid on;

%% 3) Show correleogram of features and PC
% figure;
% yvalues = {'RISE','CNT TO','CNT FROM','DUR'...
%             'AMP','AVG FREQ','RMS','ASL','REV FREQ',...
%             'INIT FREQ','SIG STR','AENG','PP1','PP2','PP3'...
%             'PP4','CEN FREQ','PEAK FREQ','AMP OF PEAK FREQ','FREQ PEAK CNT'};
% str = string(1:1:number_of_principals);
% xvalues = {str{:}};
% heatmap(xvalues,yvalues,coeff(:,1:number_of_principals),'XLabel','Principal Components','YLabel','Features');
% title(['Equalized Correleogram of Features and Principal Components'])
% colormap turbo
% saveas(gcf,[ path '_equalized_Correleogram_of_Features_and_Principal_Components'] , 'fig')

%% 6) Show factor map of features and first 3 PCs
vbls = {'rise time','counts to','counts from','duration',...
        'peak amplitude','average frequency','rms','asl','reverbation frequency',...
        'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',...
        'pp3','pp4','centroid frequency','peak frequency','amplitude of peak frequency','num of freq peaks'};
% figure;
% biplot(coeff(:,1:3),'Scores',score(:,1:3),'Varlabels',vbls);
% xlabel(strcat('PC1 (',num2str(explained(1)),'%)'))
% ylabel(strcat('PC2 (',num2str(explained(2)),'%)'))
% zlabel(strcat('PC3 (',num2str(explained(3)),'%)'))
% ax = gca;
% ax.FontSize = 8;
% title(strcat('Equalized Factor Map of PCA'))
% hold on
% th = 0:pi/50:2*pi;
% plot(cos(th), sin(th),'color','b');
% plot3(zeros(length(th),1),cos(th), sin(th),'color','b');
% plot3(cos(th),zeros(length(th),1), sin(th),'color','b');
% hold off
% saveas(gcf,[ path '_Equalized_Factor_map_of_PCA'] , 'fig')

%% All possible 2D combinations of first 6 principal components 
all_pca_comb = [[1,2,3];[4,5,6];[1,4,5];[1,2,6];[2,4,5];[3,4,5];[3,4,6]];

%% All emission seperations based on specific features
specific_name = {'negatives';'with peak around 200 kHz';'with time amplitude over 1.2 mV';'with frequency peak count under 5';'with frequency amplitude over 70 uV'};
specific_save_name = {'negatives';'with_peak_around_200_kHz';'with_time_amplitude_over_1_2_mV';'with_frequency_peak_count_under_5';'with_frequency_amplitude_over_70_uV'};
specific_ind = {[1:ind_negativ_end-1]',peak_around_200k_ind,time_amp_over_1_2mV_ind,freq_peak_under_5_ind,freq_amp_over_70uV_ind};
other_name = {'mixed';'with peak NOT around 200 kHz';'with time amplitude under 1.2 mV';'with frequency peak count over 5';'with frequency amplitude under 70 uV'};
other_ind = {[ind_negativ_end:length(score(:,1))]',peak_other_ind,time_amp_other_ind,freq_peak_other_ind,freq_amp_other_ind};

%% 7) Show emissions in coordinate system of 3D principal components
% for specific_num = 1:length(specific_name)
%     for pc_comp = 1:length(all_pca_comb)
%         pcs = all_pca_comb(pc_comp,:);
%         figure;
%         hold on
%         score_specific = score(specific_ind{specific_num},:);
%         score_other = score(other_ind{specific_num},:);
%         %% Plot negative vs mixed
%         scatter3(score_specific(:,pcs(1)),score_specific(:,pcs(2)),score_specific(:,pcs(3)),'red','filled')
%         scatter3(score_other(:,pcs(1)),score_other(:,pcs(2)),score_other(:,pcs(3)), 'yellow', 'filled')
%         grid on
%         legend(['emissions ' specific_name{specific_num}], ['emissions ' other_name{specific_num}])
%         axis equal
%         xlabel([num2str(pcs(1)) '. Principal Component'])
%         ylabel([num2str(pcs(2)) '. Principal Component'])
%         zlabel([num2str(pcs(3)) '. Principal Component'])
%         pc_names = [num2str(pcs(1)) '-' num2str(pcs(2)) '-' num2str(pcs(3))];
%         title(strcat(['Equalized emissions in 3D PC:' pc_names ' space']));
%         
%         saveas(gcf,[ path '_equalized_emissions_' specific_save_name{specific_num} '_in_3D_PC_' pc_names '_space'] , 'fig')
%     end
% end

%% 8) Locate outliers based on pc distrubution
% ouliers_ind = find(score(:,1)>30);
% equ_feature_matrix(err_rows,:) = [];
% equ_emiss_max_t_hr(err_rows,:) = [];
% equ_feature_matrix(emiss_outlier_ind,:) = [];
% equ_emiss_max_t_hr(emiss_outlier_ind,:) = [];

% for feat = 1:20
%     figure;
%     hold on
%     scatter(equ_emiss_max_t_hr,equ_feature_matrix(:,feat),'black','filled');
%     scatter(equ_emiss_max_t_hr(ouliers_ind),equ_feature_matrix(ouliers_ind,feat),'red','filled');
%     title(['Feature: ', yvalues{feat}]);
%     xlim([0 max(equ_emiss_max_t_hr)]);
%     ylim([min(equ_feature_matrix(:,feat)) max(equ_feature_matrix(:,feat))]);
% end

% figure;
% hold on
% scatter(score(:,1),score(:,2),'blue','filled');
% scatter3(score(:,1),score(:,2),score(:,3),'red','filled');

stand_feature_matrix = feature_matrix;
save(['../clustering/input_matrices/' dataset_name '_feature_selection.mat'], 'stand_feature_matrix','equ_feature_matrix','equ_emiss_max_t_hr','score','number_of_principals',...
                                                                              'ind_negativ_end','time_amp_over_1_2mV_ind','time_amp_other_ind','peak_around_200k_ind',...
                                                                              'peak_other_ind','freq_amp_over_70uV_ind','freq_amp_other_ind');
disp('Successfully selected features!')
close all

function [svd_entropy] = Calc_SVD_Entropy(dataset)
    S = svd(dataset);
    V = zeros(1,length(S));
    for i = 1:length(S)
        V(i) = S(i)/sum(S.^2);
    end

    svd_entropy = - 1/log(length(S)) * sum(V.*log(V));
end

function [contribution_estimate] = Compare_SVD_Entropy(data_subset_1, data_subset_2)
    %% Contribution of each feature
    E_all = Calc_SVD_Entropy(data_subset_1);
    E_without_feat = Calc_SVD_Entropy(data_subset_2);
    contribution_estimate = E_all - E_without_feat;
end

function all_contributions = Calc_All_CE(dataset)
    all_contributions = zeros(1,length(dataset(1,:)));
    for feat_ind = 1:length(dataset(1,:))
        x_all = dataset;
        x_without_feat = dataset(:,find(find(dataset(1,:))~=feat_ind));
        
        all_contributions(feat_ind) = Compare_SVD_Entropy(x_all,x_without_feat);
    end
end

function best_feat = Calc_Highest_CE(dataset)
    [~,best_feat] = max(Calc_All_CE(dataset));
end

function [high_feats,avg_feats,low_feats] = Simple_Feature_Selection(dataset,Calc_Crit)
    CE = Calc_Crit(dataset);
    % average and standard deviation of CE
    c = mean(CE);
    s = std(CE);
    
    % features with high contribution
    high_feats = find(CE > c+s);
    % features with average contribution
    avg_feats = find((CE < c+s) & (CE > c-s));
    % features with low contribution
    low_feats = find(CE < c-s);
end

function best_feats = Forward_Feature_Selection(dataset,Calc_First,Crit_Func1,method,Crit_Func2)

    if method > 2 || method < 1
        disp('Wrong method!');
    end

    feat_num = length(dataset(1,:));


    if method == 1
        best_feats  = [Calc_First(dataset)];
    
    
        while length(best_feats) < feat_num
            criterion = zeros(1,feat_num);
            for feat_ind = 1:feat_num
                if ismember(feat_ind,best_feats)
                    continue;
                end
                subdataset = dataset(:,[best_feats,feat_ind]);
                criterion(feat_ind) = Crit_Func1(subdataset);
            end
        
            [~, add_feat_ind] = max(criterion);
        
            best_feats = [best_feats,add_feat_ind];
        end
    elseif method == 2
        best_feats = [];
    
        while length(best_feats) < feat_num
            keep_feats = setxor(find(dataset(1,:)),best_feats);
            subdataset = dataset(:,keep_feats);
            sub_ind_2_data_ind = [1:feat_num];
            sub_ind_2_data_ind = sub_ind_2_data_ind(keep_feats);
    
            [~,remove_feat]  = max(Crit_Func2(subdataset));
            
            remove_feat = sub_ind_2_data_ind(remove_feat);
    
            best_feats = [best_feats,remove_feat];
        end
    end
end

function worst_feats = Backward_Feature_Selection(dataset,Crit_Func)

    feat_num = length(dataset(1,:));
    worst_feats = [];

    while length(worst_feats) < feat_num
        keep_feats = setxor(find(dataset(1,:)),worst_feats);
        subdataset = dataset(:,keep_feats);
        sub_ind_2_data_ind = [1:feat_num];
        sub_ind_2_data_ind = sub_ind_2_data_ind(keep_feats);

        [~,remove_feat]  = min(Crit_Func(subdataset));
        
        remove_feat = sub_ind_2_data_ind(remove_feat);

        worst_feats = [remove_feat,worst_feats];
    end
end