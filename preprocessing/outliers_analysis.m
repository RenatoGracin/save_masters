%% Try to remove outliers
% clear all
% load ..\feature_selection\input_matrices\small_dataset_UAE_equ_features.mat
[~,dataset_names,feature_matrix_paths] = Get_Dataset_Paths();

Style='Naslov 2';
title='Granice u svim skupovima podataka:';

WordFileName='Granice_skupova_podataka_nakon_izbacivanja_outliera.doc';
CurDir=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\documentation\preprocessing'];
FileSpec = fullfile(CurDir,WordFileName);
[ActXWord,WordHandle]=StartWord(FileSpec);

WordText(ActXWord,title,Style,[0,1]);%enter after text

Style = 'Normal';

feat_names = {'rise time','counts to','counts from','duration',...
    'peak amplitude','average frequency','rms','asl','reverbation frequency',...
    'initiation frequency', 'signal strength', 'absolute energy', 'PP1','PP2',...
    'PP3','PP4','centroid frequency','peak frequency','amplitude of peak frequency','num of freq peaks','weighted peak frequency',...
     'total counts', 'fall time'};

feat_units = {'s','#','#','s',...
'V','Hz','V','dB','Hz',...
'Hz', 'Vs', 'aJ', '%','%',...
'%','%','Hz','Hz','V','#','Hz',...
 '#', 's'};

all_high_thresh = [];
all_low_thresh = [];
%% Every 4 datasets write new table
table_col_size = 4;
for dataset_ind = 1:length(dataset_names)

    if mod(dataset_ind,table_col_size) == 1
            if dataset_ind ~= 1
                %% Create smaller table
                [NoRows,NoCols]=size(DataCell);          
                %create table with data from DataCell
                WordCreateTable(ActXWord,NoRows,NoCols,DataCell,1);%enter before table
            end
            DataCell = { 'Značajka/Skup podataka', dataset_names{dataset_ind:min([dataset_ind+table_col_size-1,length(dataset_names)])}};
            for feat_ind = 1:length(feat_names)
                    DataCell{feat_ind+1,1} = [feat_names{feat_ind} ' [' feat_units{feat_ind} ']'];
            end
            col_num = 1;
    end

    col_num = col_num +1;
    clearvars equ_feature_matrix equ_emiss_max_t
    load(feature_matrix_paths{dataset_ind},'equ_feature_matrix','equ_emiss_max_t');
    high_thresh = 0;
    low_thresh = 0;
    all_outliers = [];
    dataset_high_thresh = [];
    dataset_low_thresh = [];
    dataset_len = length(equ_feature_matrix(:,1));
    for feat_ind = 1:length(equ_feature_matrix(1,:))
        [outliers_ind,high_thresh,low_thresh,corrected_data] = Find_Outliers(equ_feature_matrix,equ_emiss_max_t./3600,feat_ind,0,'C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\figures\preprocessing\',0);
        max_val = max(corrected_data(:,feat_ind));
        min_val = min(corrected_data(:,feat_ind));
        dataset_high_thresh = [dataset_high_thresh;max_val];
        dataset_low_thresh = [dataset_low_thresh;min_val];
        all_outliers = unique([all_outliers,outliers_ind']);
        DataCell{feat_ind+1,col_num} = ['[' num2str(min_val,'%2.2e') ' , ' num2str(max_val,'%2.2e')  ']'];  
    end
    
    all_high_thresh = [all_high_thresh,dataset_high_thresh];
    all_low_thresh = [all_low_thresh,dataset_low_thresh];

%     disp([ dataset_names{dataset_ind} ': Number of distinct outliers are: ' num2str(length(all_outliers))]);
%     disp([ dataset_names{dataset_ind} ': Percent of outliers in dataset: ' num2str((length(all_outliers)/dataset_len)*100) ' %']);
end

DataCell = { 'Značajka', 'Završni izbor granica'};
for feat_ind = 1:length(feat_names)
    DataCell{feat_ind+1,1} = [feat_names{feat_ind} ' [' feat_units{feat_ind} ']'];
    DataCell{feat_ind+1,2} = ['[' num2str(min(all_low_thresh(feat_ind,:)),'%2.2e') ' , ' num2str(max(all_high_thresh(feat_ind,:)),'%2.2e')  ']'];  
end

%% Create smaller table
[NoRows,NoCols]=size(DataCell);          
%create table with data from DataCell
WordCreateTable(ActXWord,NoRows,NoCols,DataCell,1);%enter before table

CloseWord(ActXWord,WordHandle,FileSpec);    
close all;
disp('Sucessfully written to word')

disp('Done');