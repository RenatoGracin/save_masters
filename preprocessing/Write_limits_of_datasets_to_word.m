%% Write max and mins of dataset features to word table

Style='Naslov 2';
title='Granice u svim skupovima podataka:';

WordFileName='Granice_skupova_podataka.doc';
CurDir=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\documentation\preprocessing'];
FileSpec = fullfile(CurDir,WordFileName);
[ActXWord,WordHandle]=StartWord(FileSpec);

WordText(ActXWord,title,Style,[0,1]);%enter after text

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

global global_max
global global_min

global_max = zeros(length(feat_units),11);
real_dataset_num = 0;

% DataCell = cell(length(feat_units)+1,11);
DataCell = { 'Značajka/Skup podataka', 'Exp 6','Exp 7','Exp 8','Exp 9'};
for feat_ind = 1:length(feat_names)
        DataCell{feat_ind+1,1} = [feat_names{feat_ind} ' [' feat_units{feat_ind} ']'];
end

dataset_num = 2;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\input_matrices\big_dataset_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

dataset_num = dataset_num+1;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_7\exp_7_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

dataset_num = dataset_num+1;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_8\exp_8_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);
dataset_num = dataset_num+1;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_9\exp_9_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

%% Create smaller table
[NoRows,NoCols]=size(DataCell);          
%create table with data from DataCell
WordCreateTable(ActXWord,NoRows,NoCols,DataCell,1);%enter before table

clear DataCell
DataCell = { 'Značajka/Skup podataka', 'Exp 10 part 1' ,'Exp 10 part 2','Exp 12','Exp 13'};
for feat_ind = 1:length(feat_names)
    DataCell{feat_ind+1,1} = [feat_names{feat_ind} ' [' feat_units{feat_ind} ']'];
end
dataset_num = 2;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_10_part_1\exp_10_part_1_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);


dataset_num = dataset_num+1;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_10_part_2\exp_10_part_2_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

dataset_num = dataset_num+1;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_12\exp_12_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

dataset_num = dataset_num+1;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\input_matrices\small_dataset_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

%% Create smaller table
[NoRows,NoCols]=size(DataCell);          
%create table with data from DataCell
WordCreateTable(ActXWord,NoRows,NoCols,DataCell,1);%enter before table

clear DataCell
DataCell = { 'Značajka/Skup podataka','Exp 14 part 1','Exp 14 part 2','Ekstremni [min,max]' 'Srednji [min,max]' };
for feat_ind = 1:length(feat_names)
    DataCell{feat_ind+1,1} = [feat_names{feat_ind} ' [' feat_units{feat_ind} ']'];
end
dataset_num = 2;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_14_part_1\exp_14_part_1_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

dataset_num = dataset_num+1;
real_dataset_num = real_dataset_num +1 ;
clear equ_feature_matrix
load ..\feature_selection\feature_calc_matrices\exp_14_part_2\exp_14_part_2_UAE_equ_features.mat equ_feature_matrix

DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num);

dataset_num = dataset_num+1;
clear equ_feature_matrix
DataCell = fill_data_col_global_max(DataCell,feat_names,dataset_num);

dataset_num = dataset_num+1;
clear equ_feature_matrix
DataCell = fill_data_col_global_mean(DataCell,feat_names,dataset_num);
%the obvious data   
% DataCell={'Test 1', num2str(0.3) ,'Pass';
%           'Test 2', num2str(1.8) ,'Fail'};

[NoRows,NoCols]=size(DataCell);          
%create table with data from DataCell
WordCreateTable(ActXWord,NoRows,NoCols,DataCell,1);%enter before table

CloseWord(ActXWord,WordHandle,FileSpec);    
close all;
disp('Sucessfully written to word')

function DataCell = fill_data_col(DataCell,equ_feature_matrix,feat_names,dataset_num,real_dataset_num)
    for feat_ind = 1:length(feat_names)
        max_val = max(equ_feature_matrix(:,feat_ind));
        min_val = min(equ_feature_matrix(:,feat_ind));
        global global_max
        global global_min
        global_max(feat_ind,real_dataset_num) = max_val;
        global_min(feat_ind,real_dataset_num) = min_val;
        DataCell{feat_ind+1,dataset_num} = ['[' num2str(min_val,'%2.2e') ' , ' num2str(max_val,'%2.2e')  ']'];
    end
end

function DataCell = fill_data_col_global_max(DataCell,feat_names,dataset_num)
    for feat_ind = 1:length(feat_names)
        global global_max
        global global_min
        max_val = max(global_max(feat_ind,:));
        min_val = min(global_min(feat_ind,:));
        DataCell{feat_ind+1,dataset_num} = ['[' num2str(min_val,'%2.2e') ' , ' num2str(max_val,'%2.2e')  ']'];
    end
end

function DataCell = fill_data_col_global_mean(DataCell,feat_names,dataset_num)
    for feat_ind = 1:length(feat_names)
        global global_max
        global global_min
        max_val = mean(global_max(feat_ind,:));
        min_val = mean(global_min(feat_ind,:));
        DataCell{feat_ind+1,dataset_num} = ['[' num2str(min_val,'%2.2e') ' , ' num2str(max_val,'%2.2e')  ']'];
    end
end
