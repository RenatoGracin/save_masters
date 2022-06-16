function [outliers_ind,outliers_thresh_high,outliers_thresh_low,data] = Find_Outliers(data,time,feat_num,ActXWord,dataset_fig_folder,plotOn)
    arguments
        data
        time
        feat_num
        ActXWord = 0
        dataset_fig_folder = 'C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\figures\preprocessing\'
        plotOn = 0
    end

    feat_names_conn = {'rise_time','counts_to','counts_from','duration',...
    'peak_amplitude','average_frequency','rms','asl','reverbation_frequency',...
    'initial_frequency', 'signal_strength', 'absolute_energy', 'PP1','PP2',...
    'PP3','PP4','centroid_frequency','peak_frequency','amplitude_of_peak_frequency','num_of_freq peaks','weighted_peak_frequency', ...
     'total_counts', 'fall_time'};

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

%     outliers_thresh_high =mean(data(:,feat_num)+3*std(data(:,feat_num)));
%     outliers_thresh_low =mean(data(:,feat_num)-3*std(data(:,feat_num)));
    data_len = length(data(:,1));
    sorted_feat_data = sort(data(:,feat_num));
    perc5 = sorted_feat_data(floor(0.02*data_len));
    perc95 = sorted_feat_data(ceil(0.98*data_len));
    perc50 = sorted_feat_data(floor(0.5*data_len));
    cut_off = (perc95 - perc5)*1.5;
    outliers_thresh_high = perc95+cut_off;
    outliers_thresh_low = perc5-cut_off;

    if plotOn
        if ~isnumeric(ActXWord)
            Style= 'Naglašeno';   
            end_out_str = ['Prije izbacivanja outliera dobivamo slijedeću distribuciju:'];
            WordText(ActXWord,end_out_str,Style,[0,1]);%enter after tex
        end
        
        figure;
        subplot(2,2,1);
        hold on
        scatter3(time, data(:,feat_num),1:length(time), 8, 'blue', 'filled');
        yline(perc50,'Color','k','LineStyle','--','LineWidth',2)
        yline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
        yline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
        legend(['equalized ' feat_names{feat_num}],['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'')
        grid on
        xlabel('time [h]')
        ylabel_str = [feat_names{feat_num} ' [' feat_units{feat_num} ']'];
        ylabel_str(1) = upper(ylabel_str(1));
        ylabel(ylabel_str)
        ylim([min([outliers_thresh_low,sorted_feat_data(1)])*1.1,max([outliers_thresh_high,sorted_feat_data(end)])*1.1]);
        xlim([0 max([max(time), max(time)])])
        global dataset_name
        title(['Distr. of ' feat_names{feat_num} ' through time']);
        saveas(gcf, [dataset_fig_folder dataset_name '_equalized_' feat_names_conn{feat_num} '_in_time_removed_outliers'], 'fig')
        
        if ~isnumeric(ActXWord)
            FigureIntoWord(ActXWord); %% Write figure
        end

        %% Show distribution per 10% of samples and statistical properties: mean, std, perc10, perc 90
        subplot(2,2,2);
        grid on
        histogram(data(:,feat_num),'Normalization','probability');
%         feat_mean = mean(data(:,feat_num));
%         feat_std_3 = 3*std(data(:,feat_num));
        xline(perc50,'Color','k','LineStyle','--','LineWidth',2)
        xline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
        xline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
        legend('',['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'');
        title(['Histogram of ' feat_names{feat_num} ' distribution']);
        xlabel(ylabel_str)
        xlim([min([outliers_thresh_low,sorted_feat_data(1)])*1.1,max([outliers_thresh_high,sorted_feat_data(end)])*1.1]);
        ylabel('Percentage of feature points / 100')
        saveas(gcf, [dataset_fig_folder dataset_name '_equalized_' feat_names_conn{feat_num} '_histogram_with_outliers'], 'fig')
   
        if ~isnumeric(ActXWord)
            FigureIntoWord(ActXWord); %% Write figure
        end
    end


    outliers_ind = find(data(:,feat_num)>=outliers_thresh_high | data(:,feat_num)<=outliers_thresh_low);
    outliers_high_ind = find(data(:,feat_num)>=outliers_thresh_high);
    outliers_low_ind = find(data(:,feat_num)<=outliers_thresh_low);
    valid_ind = find(data(:,feat_num) < outliers_thresh_high & data(:,feat_num) > outliers_thresh_low);
    global emissions
%     outliers_ind = randsample(outliers_ind,length(outliers_ind));
    outliers_len = length(outliers_ind);
    
    if ~isnumeric(ActXWord)
        Style= 'Naglašeno';     
        start_out_str = [ 'Potencijalni outlieri iznad ' num2str(outliers_thresh_high) ' ' num2str(feat_units{feat_num})  ' i ispod ' num2str(outliers_thresh_low) ' ' num2str(feat_units{feat_num}) ' ' upper(feat_names{feat_num}) ':'];
        WordText(ActXWord,start_out_str,Style,[0,1]);%enter after tex
    end
    if plotOn && 0
        for ind = 1:outliers_len
            figure;
            hold on
            plot(emissions{outliers_ind(ind),8},emissions{outliers_ind(ind),7});
            plot(emissions{outliers_ind(ind),8},emissions{outliers_ind(ind),9}.*max(abs(emissions{outliers_ind(ind),7})),LineWidth=2);
        %     figure;
        %     plot(emissions{outliers_ind(ind),6},emissions{outliers_ind(ind),5});
            title([feat_names{feat_num} ' = ' num2str(data(outliers_ind(ind),feat_num)) ' [' feat_units{feat_num} ']']);
            if ~isnumeric(ActXWord)
                FigureIntoWord(ActXWord); %% Write figure
            end
        end

    end

    limit_max = max(data(valid_ind,feat_num));
    limit_min = min(data(valid_ind,feat_num));

    data(outliers_high_ind,feat_num) = limit_max;
data(outliers_low_ind,feat_num) = limit_min;

    if plotOn
        out_vals_str = [upper(feat_names{feat_num}) ' outliers are emissions with value more than ' num2str(outliers_thresh_high) ' [' feat_units{feat_num} ']'];
        disp(out_vals_str);
        out_perc_str = ['Percentage of outliers for ' upper(feat_names{feat_num}) ': ' num2str(length(outliers_ind)) '/' num2str(length(time)) ' = ' num2str(100*length(outliers_ind)/length(time)) ' %'];
        disp(out_perc_str);

        if ~isnumeric(ActXWord)
            Style= 'Naglašeno';     
            WordText(ActXWord,out_vals_str,Style,[0,1]);%enter after tex
            WordText(ActXWord,out_perc_str,Style,[0,1]);%enter after tex
        end
   

        if ~isempty(outliers_ind)
            %% Remove outliers
%             data(outliers_ind,:) = [];
%             time(outliers_ind) = [];
            %% Limit outlier valies
                 
            if ~isnumeric(ActXWord)
                Style= 'Naglašeno';   
                end_out_str = ['Nakon izbacivanja outlieri iznad ' num2str(outliers_thresh_high) ' ' num2str(feat_units{feat_num})  ' i ispod ' num2str(outliers_thresh_low) ' ' num2str(feat_units{feat_num}) ' ' upper(feat_names{feat_num}) ' ' 'dobivamo slijedeću distribuciju:'];
                WordText(ActXWord,end_out_str,Style,[0,1]);%enter after tex
            end
    
            subplot(2,2,3);
            hold on
            scatter3(time, data(:,feat_num),1:length(time), 8, 'blue', 'filled');
            yline(perc50,'Color','k','LineStyle','--','LineWidth',2)
            yline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
            yline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
            legend(['equalized ' feat_names{feat_num}],['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'')
            grid on
            xlabel('time [h]')
            ylabel_str = [feat_names{feat_num} ' [' feat_units{feat_num} ']'];
            ylabel_str(1) = upper(ylabel_str(1));
            ylabel(ylabel_str)
%             ylim([min([outliers_thresh_low,sorted_feat_data(1)])*1.1,max([outliers_thresh_high,sorted_feat_data(end)])*1.1]);
            xlim([0 max([max(time), max(time)])])
            global dataset_name
            title(['Distr. of ' feat_names{feat_num} ' through time']);
            saveas(gcf, [dataset_fig_folder dataset_name '_equalized_' feat_names_conn{feat_num} '_in_time_removed_outliers'], 'fig')
            
            if ~isnumeric(ActXWord)
                FigureIntoWord(ActXWord); %% Write figure
            end
    
            %% Show distribution per 10% of samples and statistical properties: mean, std, perc10, perc 90
            subplot(2,2,4);
            grid on
            histogram(data(:,feat_num),'Normalization','probability');
    %         feat_mean = mean(data(:,feat_num));
    %         feat_std_3 = 3*std(data(:,feat_num));
            xline(perc50,'Color','k','LineStyle','--','LineWidth',2)
            xline(outliers_thresh_high,'Color','r','LineStyle','--','LineWidth',2)
            xline(outliers_thresh_low,'Color','r','LineStyle','--','LineWidth',2)
            legend('',['50th percentile of signal = ' num2str(perc50)],['Low and High Tresholds = [' num2str(outliers_thresh_low,'%1.2e') ' , ' num2str(outliers_thresh_high,'%1.2e') ']'],'')
            title(['Histogram of ' feat_names{feat_num} ' distribution']);
            xlabel(ylabel_str)
%             xlim([min([outliers_thresh_low,sorted_feat_data(1)])*1.1,max([outliers_thresh_high,sorted_feat_data(end)])*1.1]);
            ylabel('Percentage of feature points / 100')
            saveas(gcf, [dataset_fig_folder dataset_name '_equalized_' feat_names_conn{feat_num} '_histogram_removed_outliers'], 'fig')
       
            if ~isnumeric(ActXWord)
                FigureIntoWord(ActXWord); %% Write figure
            end
        end
    end
%    close all
end