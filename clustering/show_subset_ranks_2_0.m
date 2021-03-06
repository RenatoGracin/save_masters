function show_subset_ranks_2_0(dataset,dataset_name,feat_names,saved_Nmin,saved_epsilon,scoring_limit,subsets,validity_indices,index_name,index_min,time_hr,real_dataset,guid)
    max_eps = strrep(num2str(max(saved_epsilon,[],"all")),'.','_');
    min_eps = strrep(num2str(min(saved_epsilon,[],"all")),'.','_');
    max_Nmin = num2str(max(saved_Nmin,[],"all"));
    min_Nmin = num2str(min(saved_Nmin,[],"all"));

    save([ dataset_name '_feature_selection_with_' index_name '_for_Nmin_' min_Nmin '_' max_Nmin '_Eps_' min_eps '_' max_eps  '_' guid],'validity_indices','saved_Nmin','saved_epsilon','subsets','time_hr','real_dataset')

    %% Open new word document to save feature selection results
    addpath('..\clustering\Word_support\')
    WordFileName=[ dataset_name '_feature_selection_results_with_' index_name '_for_Nmin_' min_Nmin '_' guid '.doc'];
    CurDir=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\documentation\feature_selection'];
    FileSpec = fullfile(CurDir,WordFileName);
    %% Delete if Word document already exists
    if exist(FileSpec, 'file')==2
        delete(FileSpec);
    end
    [ActXWord,WordHandle]=StartWord(FileSpec);

    disp(['Saving word to:' FileSpec])

    %% Write headline
    Style='Naslov 1'; %NOTE! if you are using an English version of MSWord use 'Heading 1'. 
    TextString=['Feature selection results for ' dataset_name ' and Nmin = ' num2str(saved_Nmin(1))];
    WordText(ActXWord,TextString,Style,[0,2]);%two enters after text
    ActXWord.Selection.Font.Size=9; 

    colors = [[1,0,0];[0.2,0.8,1.00];[1,1,0];[0,1,0];[1,0,1];[0,0,0];[0,1,1];[0.64,0.08,0.18];[1.00,0.41,0.16];[0.93,0.69,0.13]];

    for ranks = 1:scoring_limit
        [best_index_val,best_index_ind] = max(validity_indices,[],"all");
        [~,best_subset_ind] = max(max(validity_indices,[],2));
        epsilon = saved_epsilon(best_index_ind);
        Nmin = saved_Nmin(best_index_ind);
        features = subsets{best_subset_ind};
        
        labels= optics_with_clustering(dataset(:,features),Nmin,epsilon);
        labels(labels<1) = -1;

        show_3D_clustering(real_dataset(:,features),labels);
        single_peak = find(real_dataset(:,20) == 1);
        scatter3(real_dataset(single_peak,features(1)),real_dataset(single_peak,features(2)),real_dataset(single_peak,features(3)),50,colors(length(unique(labels))+1,:),'filled','x','LineWidth',1.5,'MarkerEdgeColor','flat');
        xlabel(strrep(feat_names{features(1)},'_',' '))
        ylabel(strrep(feat_names{features(2)},'_',' '))
        zlabel(strrep(feat_names{features(3)},'_',' '))
        title({['Rank: ' num2str(ranks) ' , Index value: ' num2str(best_index_val)],['Estimated Eps: ' num2str(Estimate_Epsilon(dataset(:,features),Nmin)) ' , Picked Eps: ' num2str(epsilon) ' , MinNumPoints: ' num2str(Nmin)]})
        legend(gca,'Location','north');
%         width_norm = 0.5;
%         height_norm = 0.7;
%         pos_width = 0.5 - width_norm/2; 
%         pos_height = 0.5 - height_norm/2; 
%         set(gcf, 'Units', 'Normalized', 'OuterPosition', [pos_width pos_height width_norm height_norm]);
        dataset_fig_folder=['C:\Users\bujak\Desktop\FER\5_godina\DIPLOMSKI_PROJEKT\DILPOMSKI_RAD\plant_AE_classification\figures\feature_selection\' dataset_name '_' index_name '_result\' ];
        if ~exist(dataset_fig_folder, 'dir')
           mkdir(dataset_fig_folder)
        end
        saveas(gcf,[dataset_fig_folder index_name '_features_selected_for_Nmin_' min_Nmin '_' max_Nmin '_Eps_' min_eps '_' max_eps '_rank_' num2str(ranks) '_' guid  ],'fig')
    
        feat_str = ['(' feat_names{features(1)} ', ' feat_names{features(2)} ', ' feat_names{features(3)} ')'];
        
        Style='Normal';
        Style_bold = 'Nagla??eno';
     
        rank_feats_str = [ num2str(ranks) '. result: '];
        WordText(ActXWord,rank_feats_str,Style,[0,0]);%enter after text
        disp([rank_feats_str feat_str]);
        ActXWord.Selection.Font.Bold = 1;
        WordText(ActXWord,feat_str,Style_bold,[0,1]);%enter after text
        ActXWord.Selection.Font.Bold = 0;
    
        params_str = ['Estimated Epsilon: ' num2str(Estimate_Epsilon(dataset(:,features),Nmin)) ', Picked Epsilon: ' num2str(epsilon) ', MinNumPoints: ' num2str(Nmin)];
        disp(params_str);
        WordText(ActXWord,params_str,Style,[0,1]);%enter after text
        
        index_str = [index_name ' index value: ' num2str(best_index_val)];
        disp(index_str);
        WordText(ActXWord,index_str,Style,[0,1]);%enter after text

        u_labels = unique(labels); 
        single_peak_labels = labels(single_peak);
        for clust_num = 1:length(u_labels)
            single_peak_per_clust_str = ['cluster ' num2str(u_labels(clust_num)) ' had ' num2str(100*sum(single_peak_labels==u_labels(clust_num))/length(single_peak_labels)) '% single peaks'];
            disp(single_peak_per_clust_str);
            WordText(ActXWord,single_peak_per_clust_str,Style,[0,1]);%enter after text
        end

        FigureIntoWord(ActXWord); %% Write figure

        u_labels = unique(labels);
        if dataset_name == "big_dataset"
            time_interval = 30;
        else
            time_interval = 3;
        end
        max_time_hr = floor(time_hr(end));
        clust_rate = zeros(max_time_hr,length(u_labels));
        single_peak_rate = zeros(max_time_hr,length(u_labels));
        single_peak_hr = floor(time_hr(single_peak));
        for hr = 1:max_time_hr %length(unique(floor(time_hr)))
            hr_ind = hr;
            hr_of_interval = mod(hr,time_interval);
            if hr_of_interval == 0
                hr_of_interval = time_interval;
            end
            hr_of_interval = hr_of_interval - 1;
            if hr_of_interval ~= 0
                hr_ind =  hr - hr_of_interval;
            end
    
            labels_hr = labels(find(floor(time_hr) == hr));
            single_peak_labels_hr = single_peak_labels(find(single_peak_hr == hr));
            for label_ind = 1:length(u_labels)
                single_peak_rate(hr_ind,label_ind) = single_peak_rate(hr_ind,label_ind) + sum(single_peak_labels_hr == u_labels(label_ind));
                clust_rate(hr_ind,label_ind) = clust_rate(hr_ind,label_ind) + sum(labels_hr == u_labels(label_ind)) - sum(single_peak_labels_hr == u_labels(label_ind));
            end
        end
        clust_rate = downsample(clust_rate,time_interval);
        single_peak_rate = downsample(single_peak_rate,time_interval);
            %[0,0,1]
       
        figure;
        hold on;
        xticks = [0:length(clust_rate(:,1))-1].*time_interval;
        x = repelem(xticks',1,[length(u_labels)]);

        b2 = bar(x,single_peak_rate+clust_rate,1,'grouped');

        for i = 1:length(b2)
            if i==1
                legend_str{i} = 'single peaks';
            else
                legend_str{i} = '';
            end
            b2(i).FaceColor = colors(length(u_labels)+1,:);
            xtips = b2(i).XEndPoints;
            ytips = b2(i).YEndPoints;
            single_peak_ydata = single_peak_rate(:,i)';
            clust_ydata = clust_rate(:,i)';
            all_data = single_peak_ydata+clust_ydata;
            all_data(all_data==0) = -1;
            label_tips = strrep(string(all_data),"-1","");
            single_peak_ydata_new = single_peak_ydata;
            single_peak_ydata_new(single_peak_ydata_new==0) = -1;
            label_tips_single = strrep(string(single_peak_ydata_new),"-1","");
            text(xtips,ytips+1,label_tips,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10)
            text(xtips,clust_ydata,label_tips_single,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10)
        end

        b = bar(gca,x,clust_rate,1,'grouped');

        for i = 1:length(b)
            b(i).FaceColor = colors(i,:);
            legend_str{i+length(b2)} = ['cluster ' num2str(u_labels(i))];
%             xtips = b(i).XEndPoints;
%             ytips = b(i).YEndPoints;
%             single_peak_ydata = single_peak_rate(:,i)';
%             ytips(single_peak_ydata~=0) = ytips(single_peak_ydata~=0)/2;
%             label_tips = strrep(string(b(i).YData),'0','');
%             text(xtips,ytips,label_tips,'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',10)
        end

        ylim([0,max(clust_rate+single_peak_rate+10,[],"all")]);
        set(gca,'XTick',x(:,1)');
        grid on
        legend(legend_str);
        ylabel('Number of emissions [#]')
        xlabel('time [h]')
        title({['Rank: ' num2str(ranks) ' , Index value: ' num2str(best_index_val)],'Number of emissions through hours',['Epsilon is: ' num2str(epsilon) ' , MinNumPoints is: ' num2str(Nmin)]})

        legend(gca,'Location','north');
%         width_norm = 0.5;
%         height_norm = 0.6;
%         pos_width = 0.5 - width_norm/2; 
%         pos_height = 0.5 - height_norm/2; 
%         set(gcf, 'Units', 'Normalized', 'OuterPosition', [pos_width pos_height width_norm height_norm]);

        saveas(gcf,['../figures/feature_selection/' dataset_name '_' index_name '_result/' index_name '_features_selected_for_Nmin_' min_Nmin '_' max_Nmin '_Eps_' min_eps '_' max_eps '_rank_' num2str(ranks) '_time_distribution' '_' guid  ],'fig')

        FigureIntoWord(ActXWord);
        ActXWord.Selection.InsertNewPage; 
        

        %% Remove best selection
        validity_indices(best_subset_ind,:) = zeros(1,length(validity_indices(1,:)))-1;
%         validity_indices(best_index_ind) = index_min;
    end
    %% Close and save word document results
    CloseWord(ActXWord,WordHandle,FileSpec);    
    close all;
end
