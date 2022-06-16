clear all

currAct = 22600*10^-6;
currPas = 256*10^-6;
V=3.3;

t_500 =0.1993;
t_1000=0.8315;
t_2000=3.2352;

emissRate=[10 200 400 600 800 1000 1200 1400 1600 1800 2000 2500 3000 3500 4000 4500 5000 6000 7000 8000 9000 10000];

Tmir500=60*60*500./emissRate; % u sekundama
Tmir1000=60*60*1000./emissRate; % u sekundama
Tmir2000=60*60*2000./emissRate; % u sekundama

for i=1:length(emissRate)
    avgPow500(i)=(currAct*t_500+currPas*Tmir500(i))/(t_500+Tmir500(i));
end

for i=1:length(emissRate)
    avgPow1000(i)=(currAct*t_1000+currPas*Tmir1000(i))/(t_1000+Tmir1000(i));
end

for i=1:length(emissRate)
    avgPow2000(i)=(currAct*t_2000+currPas*Tmir2000(i))/(t_2000+Tmir2000(i));
end

%% srednja struja
figure
plot(emissRate,avgPow500*10^6,'marker','o','linewidth',2,'DisplayName',sprintf('vel. prozora = %d',500));
grid on
hold on
plot(emissRate,avgPow1000*10^6,'marker','o','linewidth',2,'DisplayName',sprintf('vel. prozora = %d',1000));
plot(emissRate,avgPow2000*10^6,'marker','o','linewidth',2,'DisplayName',sprintf('vel. prozora = %d',2000));

legend show 
legend('Location','northwest');
ylabel('srednja struja [uA]');
xlabel('broj emisija po satu');
title('Ovisnost potrošnje o satnom broju emisija');
set(gca,'box','on');

%% srednja snaga
figure
plot(emissRate,avgPow500*10^6*V,'marker','o','linewidth',2,'DisplayName',sprintf('vel. prozora = %d',500));
grid on
hold on
plot(emissRate,avgPow1000*10^6*V,'marker','o','linewidth',2,'DisplayName',sprintf('vel. prozora = %d',1000));
plot(emissRate,avgPow2000*10^6*V,'marker','o','linewidth',2,'DisplayName',sprintf('vel. prozora = %d',2000));

legend show 
legend('Location','northwest');
ylabel('snaga [uW]');
xlabel('broj emisija po satu');
title('Ovisnost potrošnje o satnom broju emisija');
set(gca,'box','on');
%set(gca,'FontSize',14)

%% srednja snaga, preklapanje
preklapanje=[0 0.1 0.3 0.5];
emissRate=[10 200 400 600 800 1000 1200 1400 1600 1800 2000 2500 3000 3500 4000 4500 5000 6000 7000 8000 9000 10000];
Tmir1000=60*60*1000./emissRate;

figure
for j=1:length(preklapanje)
    
    t_new = Tmir1000.*(1-preklapanje(j));
    for i=1:length(emissRate)
       avgPow1000(i)=(currAct*t_1000+currPas*t_new(i))/(t_1000+t_new(i));
    end
    
    plot(emissRate,avgPow1000*10^6*V,'marker','o','linewidth',2,'DisplayName',sprintf('preklapanje = %d %%',preklapanje(j)*100));
    hold on
    grid on
end

legend show 
legend('Location','northwest');
ylabel('snaga [uW]');
xlabel('broj emisija po satu');
title('Ovisnost potrošnje o satnom broju emisija');
set(gca,'box','on');