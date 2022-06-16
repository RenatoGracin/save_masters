clear all
close all

addpath('C:\Users\Darjan\Desktop\SintData');
addpath('C:\Users\Darjan\Desktop\moj_optics\data');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions_help');

sat=24;

%load('UAE_data_exp_13_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
%load('UAE_data_exp_09_2018_07_23.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
load('UAE_data_exp_07_2018_07_16_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');   %dosta sumovit
%load('UAE_data_exp_08_2018_07_19.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
%load('UAE_data_exp_10_25_07_2018_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
%load('UAE_data_exp_10_25_07_2018_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
%load('UAE_data_exp_12_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');     
%load('UAE_data_exp14_part_01.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
%load('UAE_data_exp14_part_02.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
%load('UAE_data_exp14_part_03.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');
%load('UAE_data_exp_06_2018_06_05_complete.mat','UAE_single_t_mat_hr','UAE_single_f_mat','UAE_multi_t_mat_hr','UAE_multi_f_mat','UAE_broad_t_mat_hr','UAE_broad_f_mat','event_rate_hr','cumul_events_hr');

data_all(1,:) = [UAE_single_f_mat; UAE_multi_f_mat(:,1);UAE_multi_f_mat((~isnan(UAE_multi_f_mat(:,2))),2);UAE_multi_f_mat((~isnan(UAE_multi_f_mat(:,3))),3)]/1e3;
data_all(2,:) = [UAE_single_t_mat_hr; UAE_multi_t_mat_hr; UAE_multi_t_mat_hr(~isnan(UAE_multi_f_mat(:,2))); UAE_multi_t_mat_hr(~isnan(UAE_multi_f_mat(:,3)))];  

data_all = sortrows(data_all',2);
gustoca=event_rate_hr/(1*750);

% figure
% scatter( data_all(:,2), data_all(:,1), 'b','.');
% title('Ulazni podaci za grupiranje');
% ylabel('frekvencija [h]');
% xlabel('vrijeme [h]');
% set(gca,'Box','on');
% 
% figure
% plot(cumul_events_hr);
% hold on
% plot(event_rate_hr);

%% prva adaptivna metoda

% eps=10;
% totRate=0;
% avgEmm=0;
% 
% number=0;
% 
% for i=1:sat
% 
%        totRate=totRate+event_rate_hr(i);
%        
%        if event_rate_hr(i)~=0
%           number=number+1; 
%        end   
%        
%        avgEmm=totRate/number; 
%        
% end
% 
% Nmin=ceil(10+avgEmm/10*30);
% 
% 
% 
% printf('Nmin = %d',Nmin);

%% druga adaptivna metoda
% 
eps=10;
totRate=0;
avgEmm=0;
cnt=0;

number=0;

for i=1:length(event_rate_hr)
    EMnumber=zeros(10,1);
    for j=1:size(data_all,1)
        if data_all(j,2)>=i-1 && data_all(j,2)<i
            
            freq=data_all(j,1)-50;
            
            EMnumber(ceil(freq/100))=EMnumber(ceil(freq/100))+1;
        
        else
            continue;
        end
    end
    
    maxDens(i)=max(EMnumber)/100;
    
end

NminArr=maxDens.*(eps^2*pi);

figure
plot(NminArr);
grid on

for i=1:length(event_rate_hr)

       totRate=totRate+cumul_events_hr(i);
       
       avgEmm=totRate/i; 
        
    if cumul_events_hr(i)>4*avgEmm && i>sat 
          Nmin=ceil(mean(NminArr(NminArr(1:i)~=0)));
          %Nmin=ceil(NminArr(i));
          break;      
    end
    
end

printf('Nmin = %d',Nmin);