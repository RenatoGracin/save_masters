clc
close all
clear all

%% Only big dataset can seperate negatives from mixed emissions
dataset_name = 'big_dataset';

load(['input_matrices/' dataset_name '_UAE_equ_features.mat']);
path = ['../figures/feature_selection/' , dataset_name];

% find index when mixed data begins
equ_emiss_max_t_hr = (equ_emiss_max_t) ./ 3600;
ind_negativ_end = min(find(equ_emiss_max_t_hr>300));


%% Calculate PCA on seperatly on negatives and mixed emissions

show_neg = 1;
if show_neg
    feature_matrix = equ_feature_matrix(1:ind_negativ_end,:);
    emiss_type = 'only_negative';
    emiss_descript = 'Only Negatives: ';
    emiss_legend = 'only negative emissions';
else
    feature_matrix = equ_feature_matrix(ind_negativ_end:end,:);
    emiss_type = 'only_mixed';
    emiss_descript = 'Only Mixed: ';
    emiss_legend = 'only mixed emissions';
end

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

% Standardization
for feat_ind = 1:length(feature_matrix(1,:))
    % Standardization with z-score using formula x_norm = (x-mean(x))/std(x);
    % link: https://www.indeed.com/career-advice/career-development/how-to-calculate-z-score
    x = feature_matrix(:,feat_ind);
    feature_matrix(:,feat_ind) = (x-mean(x))/std(x);
end


%% 1) Calculate correleogram of features against features
% Make predictions, but don't remove features beacuse strong correlation
% can still help better classify data -> link:
figure;
yvalues = {'RISE','CNT TO','CNT FROM','DUR'...
            'AMP','AVG FREQ','RMS','ASL','REV FREQ',...
            'INIT FREQ','SIG STR','AENG','PP1','PP2','PP3'...
            'PP4','CEN FREQ','PEAK FREQ','AMP OF PEAK FREQ','FREQ PEAK CNT','WPC','TOTAL COUNTS','FALL TIME'};
heatmap(yvalues,yvalues,corr(feature_matrix),'XLabel','Features','YLabel','Features');
title([emiss_descript 'Equalized correleogram of features'])
colormap turbo
saveas(gcf,[path emiss_type '_equalized_correleogram_of_features'], 'fig')

%% 2) PCA of features - don't center because we already standardized
[coeff, score, latent, tsquared, explained, mu] = pca(feature_matrix,"Centered",false);

%% Plot principal components based on containing variance in dataset
%% Mark red PC which make more then 85% variance of dataset
hFig = figure;
variance_threshold = 85;
names = {'PC1'; 'PC2'; 'PC3'; 'PC4'; 'PC5'; 'PC6'; 'PC7'; 'PC8'; 'PC9'; 'PC10';...
    'PC10';'PC11';'PC12';'PC13';'PC14';'PC15';'PC16';'PC17';'PC18';'PC19';'PC20'};
number_of_principals = min(find(cumsum(explained)>variance_threshold));
colors = [];
for num = 1:number_of_principals
    colors = [colors;[1 0 0]];
end
b = bar(explained(1:10));
b.FaceColor = 'flat';
b.CData(1:number_of_principals,:) = colors;
xticklabels(names(1:10));
title([emiss_descript 'Percentage of the total variance explained by each principal component']);
legend(['Principal components that explain ' num2str(variance_threshold) '% of dataset variance'])
xlabel('Principal components')
ylabel('Percentage[%]')
grid on;

%% 3) Show correleogram of features and PC
figure;
yvalues = {'RISE','CNT TO','CNT FROM','DUR'...
            'AMP','AVG FREQ','RMS','ASL','REV FREQ',...
            'INIT FREQ','SIG STR','AENG','PP1','PP2','PP3'...
            'PP4','CEN FREQ','PEAK FREQ','AMP OF PEAK FREQ','FREQ PEAK CNT','WPC','TOTAL COUNTS','FALL TIME'};
str = string(1:1:number_of_principals);
xvalues = {str{:}};
heatmap(xvalues,yvalues,coeff(:,1:number_of_principals),'XLabel','Principal Components','YLabel','Features');
title([emiss_descript 'Equalized Correleogram of Features and Principal Components'])
colormap turbo
saveas(gcf,[ path emiss_type '_equalized_Correleogram_of_Features_and_Principal_Components'] , 'fig')

%% 6) Show factor map of features and first 3 PCs
vbls = {'rise time','counts to','counts from','duration',...
        'peak amplitude','average frequency','rms','asl','reverbation frequency',...
        'initial frequency', 'signal strength', 'absolute energy', 'pp1','pp2',...
        'pp3','pp4','centroid frequency','peak frequency','amplitude of peak frequency','num of freq peaks','weighted peak frequency',...
        'total counts','fall time'};
figure;
biplot(coeff(:,1:3),'Scores',score(:,1:3),'Varlabels',vbls);
xlabel(strcat('PC1 (',num2str(explained(1)),'%)'))
ylabel(strcat('PC2 (',num2str(explained(2)),'%)'))
zlabel(strcat('PC3 (',num2str(explained(3)),'%)'))
ax = gca;
ax.FontSize = 8;
title([emiss_descript 'Equalized Factor Map of PCA'])
hold on
th = 0:pi/50:2*pi;
plot(cos(th), sin(th),'color','b');
plot3(zeros(length(th),1),cos(th), sin(th),'color','b');
plot3(cos(th),zeros(length(th),1), sin(th),'color','b');
hold off
saveas(gcf,[ path emiss_type '_Equalized_Factor_map_of_PCA'] , 'fig')

%% All possible 2D combinations of first 6 principal components 
all_pca_comb = [[1,2,3];[4,5,6];[1,4,5];[1,2,6];[2,4,5];[3,4,5];[3,4,6]];

%% 7) Show emissions in coordinate system of 3D principal components
for pc_comp = 1:length(all_pca_comb)
    figure;
    pcs = all_pca_comb(pc_comp,:);
    hold on
    %% Plot negative vs mixed
    scatter3(score(:,pcs(1)),score(:,pcs(2)),score(:,pcs(3)),'red','filled')
    grid on
    legend(emiss_legend)
    axis equal
    xlabel([num2str(pcs(1)) '. Principal Component'])
    ylabel([num2str(pcs(2)) '. Principal Component'])
    zlabel([num2str(pcs(3)) '. Principal Component'])
    pc_names = [num2str(pcs(1)) '-' num2str(pcs(2)) '-' num2str(pcs(3))];
    title(strcat([emiss_descript 'Equalized emissions in 3D PC:' pc_names ' space']));
    
    saveas(gcf,[ path emiss_type '_equalized_emissions_in_3D_PC_' pc_names '_space'] , 'fig')
end

disp('Successfully selected features!')