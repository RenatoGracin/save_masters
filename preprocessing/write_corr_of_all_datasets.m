%% Correlation of all datasets

Style='Naslov 2';
title_str='Korelacije u svim skupovima podataka:';

WordFileName='Korelacije_skupova_podataka.doc';
CurDir=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\documentation\preprocessing'];
FileSpec = fullfile(CurDir,WordFileName);
[ActXWord,WordHandle]=StartWord(FileSpec);
global path
path =['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\figures\preprocessing\'];

WordText(ActXWord,title_str,Style,[0,1]);%enter after text

yvalues = {'RISE','CNT TO','CNT FROM','DUR'...
            'AMP','AVG FREQ','RMS','ASL','REV FREQ',...
            'INIT FREQ','SIG STR','AENG','PP1','PP2','PP3'...
            'PP4','CEN FREQ','PEAK FREQ','AMP OF PEAK FREQ','FREQ PEAK CNT', 'WPC',...
            'CNT ALL', 'FALL'};

clear equ_feature_matrix
load ..\feature_selection\input_matrices\big_dataset_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_6';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)


clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_7\exp_7_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_7';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)

clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_8\exp_8_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_8';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)

clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_9\exp_9_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_9';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)

clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_10_part_1\exp_10_part_1_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_10_part_1';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)

clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_10_part_2\exp_10_part_2_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_10_part_2';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)


clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_12\exp_12_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_12';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)

clear equ_feature_matrix
load ..\feature_selection\input_matrices\small_dataset_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_13';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)


clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_14_part_1\exp_14_part_1_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_14_part_1';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)

clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_14_part_2\exp_14_part_2_UAE_equ_features.mat equ_feature_matrix
dataset_name = 'exp_14_part_2';
WordText(ActXWord,dataset_name,Style,[0,1]);%enter after text
Calc_Heatmap(equ_feature_matrix,yvalues,dataset_name,ActXWord)

CloseWord(ActXWord,WordHandle,FileSpec);    
close all;
disp('Sucessfully written to word')


function Calc_Heatmap(feature_matrix,yvalues,dataset_name,ActXWord)
    err_rows = [];

    for feat_ind = 1:length(feature_matrix(1,:))
        x = feature_matrix(:,feat_ind);
        err_ele_ind = find(isinf(x) | isnan(x))';
        if ismember(err_ele_ind,err_rows) == 0
            err_rows = [err_rows,err_ele_ind];
        end
    end
    
    feature_matrix(err_rows,:) = [];
    
    figure;
    heatmap(yvalues,yvalues,corr(feature_matrix),'XLabel','Features','YLabel','Features');
    title(['Equalized correleogram of features for ' dataset_name])
    colormap turbo
    global path
    saveas(gcf,[path dataset_name '_equalized_correleogram_of_features'], 'fig')
    FigureIntoWord(ActXWord); 
end