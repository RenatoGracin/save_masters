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
for i=1:expNum
 %i = 7;   
    figure
    indices = results{i,1}(1,:,3, 4, 4);
    
    colors = ['b','r','g','y','c','m','k'];
    for x=1:max(indices)
        scatter(DATA{i,1}(:,2), DATA{i,1}(:,1),'.','b');
        hold on
    end
    clear indices;
    ylim([ 25 350]);
    xlim([0 max(DATA{i,1}(:,2))]);
    title(sprintf('Sintetički set podataka %d', i));
    grid on
    ylabel('frekvencija [kHz]');
    xlabel('vrijeme [h]');
    set(gca,'box', 'on');
    %savefig(sprintf('eksperiment_%d.fig',i)); 
end

%% rezultati

boxSizeArr = [ 100, 200, 500, 1000, 2000];
crossPointPerc = [ 0.10, 0.15, 0.20, 0.30, 0.50];
epsilon = [3, 5, 7, 10, 15];
NminPerc = [ 0.02, 0.03, 0.04, 0.05, 0.07];

%for i=1:expNum
%for i= [1,2,3,4,16,17]
 i=15;
    x = 3; y=2; z=2; q=3;
    figure
    indices = results{i,1}(q,:,x, y, z);
    
    colors = ['b','r','g','y','c','m','k'];
    for j=1:max(indices)
        scatter(DATA{i,1}(indices==j,2), DATA{i,1}(indices==j,1),'.',colors(mod(j-1,7)+1));
        hold on
    end
    clear indices;
    ylim([ 25 350]);
    xlim([0 max(DATA{i,1}(:,2))]);
    xlabel('vrijeme [h]');
    ylabel('frekvencija [kHz]');
    grid on
    set(gca,'box','on');
    title(sprintf('Set podataka %d, vel. proz. %d, preklapanje %d %%, Nmin %d %%, eps %d',i ,boxSizeArr(x), crossPointPerc(y)*100,NminPerc(q)*100, epsilon(z) )); 
%end

%%

boxSizeArr = [ 100, 200, 500, 1000, 2000];
crossPointPerc = [ 0.10, 0.15, 0.20, 0.30, 0.50];
epsilon = [3, 5, 7, 10, 15];
NminPerc = [ 0.02, 0.03, 0.04, 0.05, 0.07];

STATS = zeros(4, 4, expNum, 5, 5, 5, 5); % TP FP FN TN
RESULTS = zeros(4, 4, expNum, 5, 5, 5, 5); % recall precision accuracy F1-score
MACRO_RESULTS = zeros(1, 4, expNum, 5, 5, 5, 5);

for i=1:expNum
    
%i=14;
    TESTindices = HAND_Indices{i,1};
    experiment=results{i,1};
    expSize = size(DATA{i,1},1);
    clustNum = max(TESTindices);
    
    for x=1:5
        for y=1:5
            for z=1:5
                for q=1:5

%                  x=3;
%                  y=2;
%                  z=3;
%                  q=4;
                   
                   clear indices;
                   
                   TP=0;
                   FP=0;
                   TN=0;
                   FN=0;
                   
                   indices = experiment(q,:,x,y,z);
                   
                   compMatrix = zeros(max(indices),clustNum);
                   pom = zeros(max(indices),1);
                   pom2 = zeros(clustNum,1);
                   usedClusters = zeros(clustNum,1);
                   
                   boxSize = boxSizeArr(x);
                   crosPointNum = ceil(boxSize*crossPointPerc(y));
                   Nmin = ceil(boxSize*NminPerc(q));
                   
                   if expSize<boxSize || Nmin==1
                      continue;
                   end
                   
                   totalStages = floor((expSize-crosPointNum)/(boxSize-crosPointNum));
                   expLength = totalStages*(boxSize-crosPointNum)+crosPointNum;

                   for point=1:expLength
                    
                       % corectly clustered or wrongly clustered
                       if indices(point)~=0 && TESTindices(point)~=0
                           compMatrix(indices(point),TESTindices(point))=compMatrix(indices(point),TESTindices(point))+1;   
                       end
                   end
                                     
                   for cluster=1:clustNum
                       
                       pom = compMatrix(:,cluster);

                       maximum = 0;

                       for point = 1:length(pom)
                          if pom(point)>maximum && ~(ismember(point,usedClusters))
                            maximum=pom(point);
                            usedClusters(cluster)=point;
                          end
                       end

                       if maximum ~= 0
                           pom2 = compMatrix(usedClusters(cluster),:);
                           
                           TP = maximum;
                           FN = sum(pom)-maximum; 
                           FP = sum(pom2)-maximum;
                           
                           for point=1:expLength
                               if indices(point)==cluster && TESTindices(point)==0
                                   FP = FP+1;  
                               end
                               if indices(point)==0 && TESTindices(point)==cluster
                                   FN = FN+1;  
                               end 
                           end
                           
                           TN = expLength-TP-FN-FP;
                           
                           % Nmin, :, experiment, boxSize, crosPoint, epsilon
                           STATS(cluster,:,i,x,y,z,q)=[TP FP FN TN];
                       else
                           TP = 0;
                           FN = numel(find(TESTindices(1:expLength,1)==cluster));
                           FP = 0;
                           TN = expLength-TP-FN-FP;
                           STATS(cluster,:,i,x,y,z,q)=[TP FP FN TN];
                       end
                   
                       
                       if ~all(STATS(cluster,:,i,x,y,z,q)==0)

                           if TP ==0
                           RESULTS(cluster,1,i,x,y,z,q)=0; %recall
                           RESULTS(cluster,2,i,x,y,z,q)=0; %precision  
                           RESULTS(cluster,4,i,x,y,z,q)=0; %F1-score
                           else
                           RESULTS(cluster,1,i,x,y,z,q)=TP/(TP+FN)*100; %recall
                           RESULTS(cluster,2,i,x,y,z,q)=TP/(TP+FP)*100; %precision
                           RESULTS(cluster,4,i,x,y,z,q)=2*RESULTS(cluster,1,i,x,y,z,q)*RESULTS(cluster,2,i,x,y,z,q)/(RESULTS(cluster,1,i,x,y,z,q)+RESULTS(cluster,2,i,x,y,z,q)); %F1-score
                           end

                           RESULTS(cluster,3,i,x,y,z,q)=(TP+TN)/(TP+FP+FN+TN)*100; %accuracy

                       end
                   end
                   
                   for j=1:4
                       for cluster=1:clustNum
                           MACRO_RESULTS(1,j,i,x,y,z,q) = MACRO_RESULTS(1,j,i,x,y,z,q)+RESULTS(cluster,j,i,x,y,z,q);
                       end
                       MACRO_RESULTS(1,j,i,x,y,z,q) = MACRO_RESULTS(1,j,i,x,y,z,q)/clustNum;
                   end
                       
                end
            end
        end
    end
   
end


%% Nmin and eps

string = ["Macro-recall", "Macro-precision", "Macro-accuracy", "Macro-F1"];

%for k=1:4
    k=4;
   
    for x=1:5
        for y=2
            
            TEST=zeros(5,5);
            number=zeros(5,5);
    
            for i=[1,2,3,4,16,17]
            %for i=17
                
                for z=1:5
                    for q=1:5                       
                      
                        TEST(z,q)=MACRO_RESULTS(1,k,i,x,y,z,q)+TEST(z,q);
                        number(z,q)=number(z,q)+1;
                    end
                end
            end
            
            TEST=TEST./number(z,q);

            figure
            surf(NminPerc*100, epsilon, TEST) % pazi!!! obrnuto!!!
            title(sprintf('Velicina prozora = %d, preklapanje (post.) = %d',boxSizeArr(x), crossPointPerc(y)*100));
            %savefig(sprintf('Nmin_eps0%d',k));
            zlabel(sprintf('%s',string(k)));
            xlabel('Nmin postotak [%]');
            ylabel('eps');
            zlim([0 100]);
            xlim([2 7]);
        end
    end
%end

%% Window size and intersect point perc. 
clear indices

string = ["Macro-recall", "Macro-precision", "Macro-accuracy", "Macro-F1"];

%for k=1:4
    k=4;
   
    for q=1:5
        for z=1:5
            
            TEST=zeros(5,5);
            number=zeros(5,5);
    
            %for i=[1,2,3,4,16,17]
            for i=7
                
                for x=1:5
                    for y=1:5                       
                      
                        TEST(x,y)=MACRO_RESULTS(1,k,i,x,y,z,q)+TEST(x,y);
                        number(x,y)=number(x,y)+1;
                    end
                end
            end
            
            TEST=TEST./number(x,y);

            figure
            surf(crossPointPerc*100,boxSizeArr, TEST) % pazi!!! obrnuto!!!
            title(sprintf('Nmin %d %%, epsilon %d', uint8(NminPerc(q)*100), epsilon(z)));
            %savefig(sprintf('Nmin_eps0%d',k));
            zlabel(sprintf('%s',string(k)));
            xlabel('preklapanje [%]');
            ylabel('velicina prozora');
            zlim([0 100]);

        end
    end
%end


%end

%% Nmin 

clear indices

string = ["Macro-recall", "Macro-precision", "Macro-accuracy", "Macro-F1"];

%for k=1:4   
    k=4;
    
    
    for x=1:5
        for y=2
            figure
                for z=1:5
                    
                    TEST=zeros(5,1);
                    number=zeros(5,1);
                    
                    for i = 1:expNum
                        for q=1:5

                                TEST(q,1)=MACRO_RESULTS(1,k,i,x,y,z,q)+TEST(q,1);
                                number(q,1)=number(q,1)+1;
                        end
                    end
                    
                    TEST=TEST./number;
                    
                    plot(NminPerc*100 , TEST,'marker','o','linewidth', 2,'DisplayName',sprintf('eps=%d',epsilon(z))); 
                    hold on
                    title(sprintf('Velicina prozora = %d, preklapanje (post.) = %d',boxSizeArr(x), crossPointPerc(y)*100));
                    grid on
                    xlabel('Nmin postotak [%]');
                    ylabel(sprintf('%s',string(k)));
                    xlim([2 7]);
                    ylim([0 100]);
                    %savefig(sprintf('Nmin0%d',k));
                end
   
            legend show 
            legend('Location','southeast');
        end
    end
%end

%% epsilon 

clear indices

string = ["Macro-recall", "Macro-precision", "Macro-accuracy", "Macro-F1"];

%for k=1:4   
    k=4;
    
    
    for x=3:4
        for y=2
            figure
                for q=1:5
                    
                    TEST=zeros(5,1);
                    number=zeros(5,1);
                    
                    for i = [1,2,3,4,16,17]
                        for z=1:5

                                TEST(z,1)=MACRO_RESULTS(1,k,i,x,y,z,q)+TEST(z,1);
                                number(z,1)=number(z,1)+1;
                        end
                    end
                    
                    TEST=TEST./number;
                    
                    plot(epsilon , TEST,'marker','o','linewidth', 2,'DisplayName',sprintf('Nmin = %d %%',uint8(NminPerc(q)*100))); 
                    hold on
                    title(sprintf('Veličina prozora %d, preklapanje %d %%',boxSizeArr(x), crossPointPerc(y)*100));
                    grid on
                    xlabel('epsilon');
                    ylabel(sprintf('%s',string(k)));
                    xlim([3 15]);
                    ylim([0 100]);
                    %savefig(sprintf('Nmin0%d',k));
                end
   
            legend show 
            legend('Location','southeast');
        end
    end
%end


%% times

