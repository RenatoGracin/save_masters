clear all

addpath('C:\Users\Darjan\Desktop\Rezultati Sint');
addpath('C:\Users\Darjan\Desktop\moj_optics');
addpath('C:\Users\Darjan\Desktop\moj_optics\data');
addpath('C:\Users\Darjan\Desktop\SintData');

expNum=17;

for i=1:expNum

if i<10
 results{i,1}=cell2mat(struct2cell(load(sprintf('Mat_Sint_0%d', i))));

 HAND_Indices{i,1}=cell2mat(struct2cell(load(sprintf('SintIndices_0%d', i))));
 DATA{i,1}=cell2mat(struct2cell(load(sprintf('SintData_0%d', i))));
else
 results{i,1}=cell2mat(struct2cell(load(sprintf('Mat_Sint_%d', i))));

 HAND_Indices{i,1}=cell2mat(struct2cell(load(sprintf('SintIndices_%d', i))));
 DATA{i,1}=cell2mat(struct2cell(load(sprintf('SintData_%d', i))));
end

end

%% originalni podaci
%for i=1:expNum
 i = 15;   
    figure
    indices = results{i,1}(1,:,4, 5, 3);
    
    colors = ['b','r','g','y','c','m','k'];
    for x=1:max(indices)
        scatter(DATA{i,1}(:,2), DATA{i,1}(:,1),'.','b');
        hold on
    end
    clear indices;
    ylim([ 0 max(DATA{i,1}(:,1))]);
    xlim([0 max(DATA{i,1}(:,2))]);
    title(sprintf('experiment %d', i));
    grid on
    ylabel('frekvencija [kHz]');
    xlabel('vrijeme [h]');
    %savefig(sprintf('eksperiment_%d.fig',i)); 
%end

%% rezultati

boxSizeArr = [ 100, 200, 500, 1000, 2000];
crossPointPerc = [ 0.10, 0.15, 0.20, 0.30, 0.50];
epsilon = [3, 5, 7, 10, 15];
NminPerc = [ 0.02, 0.03, 0.04, 0.05, 0.07];

%for i=1:expNum
figure('Renderer', 'painters', 'Position', [500 500 900 300])
k=1;
ahh = [2,4,4];

for i=[ 15 16 17]   
    subplot(1,3,k);
    
    indices = results{i,1}(1,:,4, 5, ahh(k));
    k=k+1;
    
    colors = ['b','r','g','y','c','m','k'];
    for x=1:max(indices)
        scatter(DATA{i,1}(indices==x,2), DATA{i,1}(indices==x,1),'.',colors(mod(x-1,7)+1));
        hold on
    end
    
    ylim([ 25 350]);
    xlim([0 max(DATA{i,1}(:,2))]);
    xlabel('vrijeme [h]');
    ylabel('frekvencija [kHz]');
    title(sprintf('Sintetički set podataka %d', i) ); 
    grid on
    set(gca,'box','on');
    scatter(DATA{i,1}(indices==0,2), DATA{i,1}(indices==0,1),8,[0.8 0.8 0.8],'filled'); 
    clear indices;
    axis square
end

%%

for i=1:expNum
    
    experiment=results{i,1};
    expSize = size(DATA{i,1},1);
    
    for x=1:5
        for y=1:5
            for z=1:5
                for q=1:5

%                  x=4;
%                  y=6;
%                  z=6;
%                  q=4;
                   
                   clear indices TESTindices;
                   NC=0;
                   CC=0;
                   WC=0;
                   SBC=0;
                   NP=0;
                   
                   
                   indices = experiment(q,:,x,y,z);
                   TESTindices = HAND_Indices{i,1};
                   clustNum = max(TESTindices);
                   compMatrix = zeros(max(indices),clustNum);
                   pom = zeros(max(indices),1);
                   usedClusters = zeros(clustNum,1);
                   
                   boxSize = boxSizeArr(x);
                   crosPointNum = ceil(boxSize*crossPointPerc(y));
                   Nmin = ceil(boxSize*NminPerc(q));
                   
                   if expSize<boxSize || Nmin==1
                      STATS(q,:,i,x,y,z)=[0 0 0 0];
                      continue;
                   end
                   
                   totalStages = floor((expSize-crosPointNum)/(boxSize-crosPointNum));
                   expLength = totalStages*(boxSize-crosPointNum)+crosPointNum;

                   for point=1:expLength
                       
                       % noise point
                       if indices(point)==0 && TESTindices(point)==0
                           NP=NP+1;
                       end
                       
                       % not clustered but should be
                       if indices(point)==0 && TESTindices(point)~=0
                           NC=NC+1;
                       end
                       % shouldnt be clustered
                       if indices(point)~=0 && TESTindices(point)==0
                           SBC=SBC+1;
                       end
                       
                       % corectly clustered or wrongly clustered
                       if indices(point)~=0 && TESTindices(point)~=0
                           compMatrix(indices(point),TESTindices(point))=compMatrix(indices(point),TESTindices(point))+1;   
                       end
                   end
                   
                   for cluster=1:clustNum
                       pom=compMatrix(:,cluster);
                       
                       if max(pom)~=0
                           maximum = 0;

                           for point = 1:length(pom)
                              if pom(point)>maximum && ~(ismember(point,usedClusters))
                                maximum=pom(point);
                                usedClusters(cluster)=point;
                              end
                           end

                           CC = CC+maximum;
                           WC = WC+sum(pom)-maximum;                     
                       end  
                   end
                   
                   total= WC+CC+NC+SBC+NP;
                   
                   % Nmin, :, experiment, boxSize, crosPoint, epsilon
                   STATS(q,:,i,x,y,z)=[WC/total (CC+NP)/total NC/total SBC/total];
                   
                   
                end
            end
        end
    end
   
end


%% Nmin and eps
clear indices

string = ["Wrongly clustered (Incorrectly identified, FP)", "Correctly clustered (Correctly identified, TP)", "Not clustered but should be (Incorrectly rejected, FN)", "Shouldn't be clustered"];
% k = WC/total (CC+NP)/total NC/total SBC/total
%for k=1:4
    k=2;
    
    bestParMat=zeros(5,5);
    
    for x=1:5
        for y=1:5
            
            TEST=zeros(5,5);
            number=zeros(5,5);
    
            %for i=1:expNum
            for i=7
                for z=1:5
                    for q=1:5
                        indices=STATS(q,:,i,x,y,z);
                        if ~all(indices==0)
                            TEST(z,q)=TEST(z,q)+ indices(k);
                            number(z,q)=number(z,q)+1;
                        end
                    end
                end
            end
            
            TEST=(TEST./number)*100;
            [~,point]=max(TEST,[],'all', 'linear');
            
            if ~(sum(number,'all')==0)
            bestParMat(point)=bestParMat(point)+1;
            end
            
            figure
            surf(NminPerc, epsilon, TEST) % pazi!!! obrnuto!!!
            title(sprintf('%s, %d %f', string(k),boxSizeArr(x), crossPointPerc(y)));
            %savefig(sprintf('Nmin_eps0%d',k));
            zlabel('TP, perc.');
            xlabel('Nmin');
            ylabel('eps');
            zlim([0 100]);
        end
    end
%end

%% Window size and intersect point perc. 
clear indices

string = ["wrongly clustered", "correctly clustered (correctly identified)", "not clustered but should be", "shouldnt be clustered"];
% k = WC/total (CC+NP)/total NC/total SBC/total
%for k=1:4
    
    k=2;
    bestParMat=zeros(5,5);
    
    for z=1:5
        for q=1:5
            
            TEST=zeros(5,5);
            number=zeros(5,5);
            
            for i=1:expNum
                for x=1:5
                    for y=1:5
                        indices=STATS(q,:,i,x,y,z);
                        if ~all(indices==0)
                            TEST(x,y)=TEST(x,y)+ indices(k);
                            number(x,y)=number(x,y)+1;
                        end     
                    end
                end
            end
            
            TEST=(TEST./number)*100;
            [~,point]=max(TEST,[],'all', 'linear');

            if ~(sum(number,'all')==0)
            bestParMat(point)=bestParMat(point)+1;
            end

            figure
            surf(crossPointPerc,boxSizeArr, TEST) % pazi!!! obrnuto!!!
            title(sprintf('%s, %d %f', string(k), epsilon(z), NminPerc(q)));
            %savefig(sprintf('Prozor_presjek0%d',k));
            zlabel('TP, perc.');
            ylabel('velicina prozora');
            xlabel('preklapanje post.');
            zlim([0 100]);
    
        end
    end


%end

%% Nmin

clear indices

string = ["wrongly clustered", "correctly clustered (correctly identified)", "not clustered but should be", "shouldnt be clustered"];
% k = WC/total (CC+NP)/total NC/total SBC/total
 
%for k=1:4   
    k=2;
    
    
    for x=1:5
        for y=1:5
            figure
            
                for z=1:5
                    
                    TEST=zeros(5,1);
                    number=zeros(5,1);
                    
                    for i=1:expNum
                        for q=1:5
                            indices=STATS(q,:,i,x,y,z);
                            if ~all(indices==0)
                                TEST(q)=TEST(q)+ indices(k);
                                number(q)=number(q)+1;
                            end
                        end
                    end
           
                    TEST=(TEST./number)*100;

                    plot(NminPerc , TEST,'marker','o','linewidth', 2,'DisplayName',sprintf('eps=%d',epsilon(z))); 
                    hold on
                    title(sprintf('%s, %d %f', string(k),boxSizeArr(x), crossPointPerc(y)));
                    grid on
                    xlabel('Nmin precentage');
                    ylabel(sprintf('%s perc.',string(k)));
                    
                    ylim([0 100]);
                    %savefig(sprintf('Nmin0%d',k));
                end
                
            legend show  
        end
    end
%end

%% epsilon

clear indices

string = ["wrongly clustered", "correctly clustered (correctly identified)", "not clustered but should be", "shouldnt be clustered"];
% k = WC/total (CC+NP)/total NC/total SBC/total
 
%for k=1:4   
    k=2;
    
    
    for x=1:5
        for y=1:5
            figure
            
                for q=1:5
                    
                    TEST=zeros(5,1);
                    number=zeros(5,1);
                    
                    %for i=1:expNum
                    for i=7
                        for z=1:5
                            
                            indices=STATS(q,:,i,x,y,z);
                            if ~all(indices==0)
                                TEST(z)=TEST(z)+ indices(k);
                                number(z)=number(z)+1;
                            end
                        end
                    end
           
                    TEST=(TEST./number)*100;

                    plot(epsilon , TEST,'marker','o','linewidth', 2,'DisplayName',sprintf('NminPerc=%f',NminPerc(q))); 
                    hold on
                    title(sprintf('%s, %d %f', string(k),boxSizeArr(x), crossPointPerc(y)));
                    grid on
                    xlabel('epsilon');
                    ylabel(sprintf('%s perc.',string(k)));
                    
                    ylim([0 100]);
                    %savefig(sprintf('Nmin0%d',k));
                end
                
            legend show  
        end
    end

%% window size ///wrooonggg

clear indices

string = ["wrongly clustered", "correctly clustered (correctly identified)", "not clustered but should be", "shouldnt be clustered"];
% k = WC/total (CC+NP)/total NC/total SBC/total

%for k=1:4   
    k=2;
    
    
    for z=1:5
        for q=1:5
            figure
            
                for y=1:5
                    
                    TEST=zeros(5,1);
                    number=zeros(5,1);
                    
                    for i=1:expNum
                    %for i=7
                        for x=1:5
                            indices=STATS(q,:,i,x,y,z);
                            if ~all(indices==0)
                                TEST(x)=TEST(x)+ indices(k);
                                number(x)=number(x)+1;
                            end
                        end
                    end
           
                    TEST=(TEST./number)*100;

                    plot(boxSizeArr , TEST,'marker','o','linewidth', 2,'DisplayName',sprintf('presjek=%f',crossPointPerc(y))); 
                    hold on
                    title(sprintf('%s, %d %f', string(k), epsilon(z), NminPerc(q)));
                    grid on
                    xlabel('Window size');
                    ylabel(sprintf('%s perc.',string(k)));
                    
                    ylim([0 100]);
                    %savefig(sprintf('Nmin0%d',k));
                end
                
            legend show  
        end
    end

%% intersect perc. ///wrooonggg

clear indices

string = ["wrongly clustered", "correctly clustered (correctly identified)", "not clustered but should be", "shouldnt be clustered"];
% k = WC/total (CC+NP)/total NC/total SBC/total

for k=1:4  
    
    TEST=zeros(7,1);
    number=zeros(7,1);
    
    for i=1:9
        for x=1:8
            for y=1:7
                for z=1:7
                    for q=1:7
                        indices=STATS(q,:,i,x,y,z);
                        if ~all(indices==0)
                            TEST(y)=TEST(y)+ indices(k);
                            number(y)=number(y)+1;
                        end
                    end
                end
            end
        end
    end
    TEST=TEST./number;

    figure
    plot(crossPointPerc, TEST,'marker','o'); 
    title(sprintf('%s', string(k)));
    grid on
    xlabel('intersect perc.');
end

%% times

