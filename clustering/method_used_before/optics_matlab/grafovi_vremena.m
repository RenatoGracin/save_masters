addpath('C:\Users\Darjan\Desktop\moj_optics\data');
addpath('C:\Users\Darjan\Desktop\moj_optics\functions');
addpath('C:\Users\Darjan\Desktop\Eksperimenti\Eksperiment 2_V2');

load('TIME.mat'); % preklapanje/(total, avg, max, min)/set/vel. prozora

boxSizeArr = [ 50 75 100 125 150 175 200 300 400 500 600 700 800 900 1000 1200 1400 1600 1800 2000];
crossPointPerc = [ 0.02 0.04 0.06 0.08 0.1 0.12 0.14 0.16 0.18 0.20 0.22 0.24 0.26 0.28 0.30 0.32 0.34 0.36 0.38 0.40];

%%
time=zeros(20,1);
for i=1:20
    time(i)=mean(TIME(:,2,:,i),[1,3]);   
end

figure
plot(boxSizeArr,time,'linewidth',2,'marker','o');
grid on
title('Trajanje algoritma u ovisonsti o veličini prozora');
xlabel('veličina prozora');
ylabel('prosječno vrijeme po prozoru [s]');
set(gca,'box','on');
%set(gca,'FontSize',14)
%%
time=zeros(20,1);
boxSizeS=[3, 10, 15];
figure
hold on

for i=1:3
    for j=1:20
        boxSize=boxSizeArr(boxSizeS(i));
        crosPointNum=ceil(crossPointPerc(j)*boxSize);
        totalStages = floor((2000-crosPointNum)/(boxSize-crosPointNum));
        expLength = totalStages*(boxSize-crosPointNum)+crosPointNum;
        %expLength = totalStages*boxSize;
        time(j)=mean(TIME(j,1,:,boxSizeS(i)))/expLength;
        %time(j)=mean(TIME(j,1,:,boxSizeS(i)))/(boxSize*totalStages+(totalStages-1)*crosPointNum);
    end
    
    plot(crossPointPerc*100,time*10^6,'linewidth',2,'marker','o','DisplayName',sprintf('vel. prozora = %d',boxSize));
    grid on
    title('Trajanje algoritma u ovisonsti o preklapanju prozora');
    xlabel('preklapanje prozora [%]');
    ylabel('prosječno vrijeme po emisiji [us]');
    legend show 
    legend('Location','northwest');
    set(gca,'box','on');
end

%%
addpath('C:\Users\Darjan\Desktop\Eksperimenti\Eksperiment 4');

load('C:\Users\Darjan\Desktop\Eksperimenti\Eksperiment 4\TIME.mat'); % preklapanje/(total, avg, max, min)/set/vel. prozora

time=zeros(8,1);

for i=1:40
   point=mod(i,8);
   if point==0
      point=8; 
   end 
   time(point)=time(point)+TIME(i);
end

time=time/5;
figure 
title('Trajanje algoritma u ovisnosti o broju grupa');
plot(time,'linewidth',2,'marker','o');
grid on;

