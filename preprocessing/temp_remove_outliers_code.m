%% Remove outliers from data


% data_len = length(equ_feature_matrix(:,1));
% yvalues = {'RISE','CNT TO','CNT FROM','DUR'...
%             'AMP','AVG FREQ','RMS','ASL','REV FREQ',...
%             'INIT FREQ','SIG STR','AENG','PP1','PP2','PP3'...
%             'PP4','CEN FREQ','PEAK FREQ','AMP OF PEAK FREQ','FREQ PEAK CNT', 'WPC','TOATAL COUNTS','FALL TIME'};
% for feat_ind = 1:length(equ_feature_matrix(1,:))
%     feat_data = equ_feature_matrix(:,feat_ind);
%     sorted_feat_data = sort(feat_data);
%     perc10 = sorted_feat_data(floor(0.10*data_len));
%     perc90 = sorted_feat_data(floor(0.90*data_len));
%     cut_off = (perc90 - perc10)*3;
%     upper_limit = perc90+cut_off;
%     lower_limit = perc10-cut_off;
%     outliers_ind = find((feat_data < lower_limit) | (feat_data > upper_limit));
%     disp(['Feature ' num2str(feat_ind) ' or ' yvalues{feat_ind} ' has ' num2str(length(outliers_ind)) ' outliers.'])
%     valid_ind = find((feat_data > lower_limit) | (feat_data < upper_limit));
%     valid_feature_matrix = equ_feature_matrix(valid_ind,feat_ind);
%     equ_emiss_max_t_hr = equ_emiss_max_t*.3600;
%     valid_emiss_max_t_hr = equ_emiss_max_t_hr(valid_ind);
%     
%     figure;
%     hold on
%     scatter(valid_emiss_max_t_hr,valid_feature_matrix,5,'blue','filled','o')
%     scatter(equ_emiss_max_t_hr(outliers_ind),valid_feature_matrix(outliers_ind,:),10,'red','filled','o')
%     disp(num2str(outliers_ind(:)));
% 
%     for i = 1:length(outliers_ind)
%         time = cell2mat(emission_save{outliers_ind(i)}(1));
%         signal = cell2mat(emission_save{outliers_ind(i)}(2));
%         bin_envelope = cell2mat(emission_save{outliers_ind(i)}(3));
%         figure;
%         hold on
%         plot(time,signal,'Color','b');
%         plot(time,bin_envelope,'Color','r','LineWidth',1);
%         grid on
%         hold off
%         close all
%     end
% 
% end
% yvalues = {'RISE','CNT TO','CNT FROM','DUR'...
%             'AMP','AVG FREQ','RMS','ASL','REV FREQ',...
%             'INIT FREQ','SIG STR','AENG','PP1','PP2','PP3'...
%             'PP4','CEN FREQ','PEAK FREQ','AMP OF PEAK FREQ','FREQ PEAK CNT', 'WPC'};
%% Features with zero outlier: 3,6,8,9,10,13,14,15,17,20

%% FOR 10% - 90%
%COUNT FROM, AVG FREQ, ASL, REV FREQ, INIT FREQ, , PP1 - PP3, CEN FREQ,
%FREQ PEAK COUNT

%% 1,2,4 features remove outliers that have multiple emissions inside analyzed one
%% RISE, COUNT TO, DURATION, 

%% 5,7,11,12,19 features captures very valid emissions with minimal noise
%% AMP, RMS, SIG STR, AENG, AMP OF PEAK FREQ
%% 16 picks 481 -> good
%% PP4

%% 18,21 picks 2 and 124 -> bad
%% PEAK FREQ, WPC

%% CHANGES FOR 25%-75%
%% GOOD -> masno 5=AMP, 7=RMS, 12=AENG (imo ih 98), 19=AMP OF PEAK FREQ
%% GOOD AND BAD -> 16=PP4 -> maybe likes thick signals, 18=PEAK FREQ i 21=WPC-> maybe spikes for high freq but there were some thick
%% BAD -> mostly bad, one good , 3=COUNTS FROM, 6=AVG FREQ, 9 = REV FREQ
%% BOTH -> 8 = ASL, 10=INIT FREQ, 14=PP2, 15=PP3, 17=CEN FREQ, 20=FREQ PEAK CNT prvi je bio dobar
%% 13=PP1 - short spikes (impulses) or combination of short spikes
