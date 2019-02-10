function [] = tTest(trialN,ptN,plotMovement)
% make confidence intervals of firing rates for each trial, for each muscle,
% for ext/fle (x-axis) and rad/uln (y-axis) to determine stat sig

%for each trial, for each movement, for each muscle, for each nFile, min max avg std
%SE= s/sqrt(n)
%confidence interval = xbar+-(z*SE)

%trialN=4;
%ptN=1;
trialOther="";
%"mod7_bs_7_results";
alpha=0.05;
if(alpha==0.05)
    z=1.96;
end
moreMoBL=false;
noMVC=true;
if(noMVC)
    %movement="uln"; % "fle","rad","uln"
    movements=["ext" "fle" "rad" "uln"];
    extInd=1;
    fleInd=2;
    ulnInd=3;
    radInd=4;
end
%plotMovement="rad";
if(trialN==3.1 && ptN==-1)
    %activeMuscles = {'FCR', 'ECRB', 'EDCM'}; % order from
    %writeIncrementalControlsFiles, where order doesnt matter
    activeMuscles = {'EDCM','ECRB','FCR'}; % order from getStats, where
    % order does matter
    % 1 EDCM ; 2 ECRB ; 3 FCR
    EDCMind=1;
    ECRBind=2;
    FCRind=3;
    maxNfiles=4;
    tTestsIa=zeros(maxNfiles,6*4); %ncols * n movements (ext,fle,uln,rad)
    tTestsII=zeros(maxNfiles,6*4);
elseif(trialN==4)
    activeMuscles = {'EDCM', 'ECRB', 'FCU', 'FCR'}; % order from getStats, where
    % order does matter ; also same order in writeIncrementalControlsFiles,
    % although writeIncrementalControlsFiles order doesnt matter
    % 1 EDCM ; 2 ECRB ; 3 FCU ; 4 FCR
    EDCMind=1;
    ECRBind=2;
    FCUind=3;
    FCRind=4;
    if(ptN==1) maxNfiles=4;
    elseif(ptN==2) maxNfiles=2;
    end
    tTestsIa=zeros(maxNfiles,6*4);
    tTestsII=zeros(maxNfiles,6*4);
end

% n optLengths = n 10 ms increments = n per movement per trial
% trial3.1
% 	for all ECRB,FCR,EDCM
% 	ext	fle	uln	rad
% 1	801	768	751	772
% 2	752	875	732	697
% 3	163	172	-	-
% trial4pt1
% 	for all ECRB,FCR,EDCM,FCU
% 	ext	fle	uln	rad
% 1	799	784	778	810
% 2	798	668	750	799
% 3	828	92	90	532
% 4	90	-	-	-
% trial4pt2
% 	for all ECRB,FCR,EDCM,FCU
% 	ext	fle	uln	rad
% 1	767	740	791	826
% 2	10	535	268	680

% row=movement,col=nFile
if(trialN==3.1 && ptN==-1)
    nForMovementForNfile=[801 752 163; 768 875 172; 751 732 -1; 772 697 -1];
    % trial3.1
    % 	for all ECRB,FCR,EDCM
    % 	ext	fle	uln	rad
    % 1	801	768	751	772
    % 2	752	875	732	697
    % 3	163	172	-	-
elseif(trialN==4)
    if(ptN==1)
        nForMovementForNfile=[799 798 828 90; 784 668 92 -1; 778 750 90 -1; 810 799 532 -1];
        % trial4pt1
        % 	for all ECRB,FCR,EDCM,FCU
        % 	ext	fle	uln	rad
        % 1	799	784	778	810
        % 2	798	668	750	799
        % 3	828	92	90	532
        % 4	90	-	-	-
    elseif(ptN==2)
        nForMovementForNfile=[767 10; 740 535; 791 268; 826 680];
        % trial4pt2
        % 	for all ECRB,FCR,EDCM,FCU
        % 	ext	fle	uln	rad
        % 1	767	740	791	826
        % 2	10	535	268	680
    end
end

if(noMVC)
    longDir="E:\moreR\noMVCextract\";
    %longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\noMVCextract\";
    fileStr=strcat("trial",num2str(trialN),"pt",num2str(ptN));
end

% 1 EDCM ; 2 ECRB ; 3 FCR % 1 EDCM ; 2 ECRB ; 3 FCU ; 4 FCR
statsHeader=["iAmAString"];
%statsHeader(1,1)="nFile";
% note rows are nFile, but no extra col to indicate that so not
% indicated
statsHeader(1,1)="3.1: EDCM, 4: EDCM";
statsHeader(1,1+4)="3.1: ECRB, 4: ECRB";
statsHeader(1,1+4+4)="3.1: FCR, 4: FCU";
statsHeader(1,1+4+4+4)="3.1: -, 4: FCR";
statsHeader(2,1)="max";
statsHeader(2,2)="min";
statsHeader(2,3)="avg";
statsHeader(2,4)="stdev";

%for each trial, for each movement, for each muscle, for each nFile, min max avg std
tTestHeader=["iAmAString"];
tTestHeader(1,1)="ext";
tTestHeader(1,1+6)="fle";
tTestHeader(1,1+6+6)="uln";
tTestHeader(1,1+6+6+6)="rad";
tTestHeader(2,1)="avg";
tTestHeader(2,2)="stdev";
tTestHeader(2,3)="n";
tTestHeader(2,4)="standard error";
tTestHeader(2,5)="confidenceIntervalLowBound";
tTestHeader(2,6)="confidenceIntervalHighBound";

% 7 cols since col1 = muscle nFile, col2= Ia CIlow, col3= Ia avg, col4=Ia
% CIhigh, col5= II CI low, col6= II avg, col7= II CI high
% extPlot=zeros(size(activeMuscles,2)*maxNfiles,7);
% flePlot=zeros(size(activeMuscles,2)*maxNfiles,7);
% ulnPlot=zeros(size(activeMuscles,2)*maxNfiles,7);
% radPlot=zeros(size(activeMuscles,2)*maxNfiles,7);
% extPlotStr=["iAmAString"];
% flePlotStr=["iAmAString"];
% ulnPlotStr=["iAmAString"];
% radPlotStr=["iAmAString"];

fc=1;
figure(fc);
c1=1;
for i=1:size(activeMuscles,2)
    
    % get avg of avgs of nFiles for this trial for each muscle for all movements
    currTrialCurrMuscleAllMovementsSumOfAvgsIa=0;
    currTrialCurrMuscleAllMovementsSumOfAvgsCounterIa=0;
    currTrialCurrMuscleAllMovementsSumOfNsIa=0;
    
    currTrialCurrMuscleAllMovementsSumOfAvgsII=0;
    currTrialCurrMuscleAllMovementsSumOfAvgsCounterII=0;
    currTrialCurrMuscleAllMovementsSumOfNsII=0;
    
    % get avg of avgs of nFiles for this trial for this movement for each muscle
    currSumOfAvgsIa=0;
    currSumOfAvgsCounterIa=0;
    currSumOfNsIa=0;
    
    currSumOfAvgsII=0;
    currSumOfAvgsCounterII=0;
    currSumOfNsII=0;
    
    activeMuscle=activeMuscles(i);
    activeMuscleStr=activeMuscle{1};
    if(trialN==3.1 && ptN==-1)
        % 1 EDCM ; 2 ECRB ; 3 FCR
        if(activeMuscleStr=="EDCM") muscleInd=EDCMind;
        elseif(activeMuscleStr=="ECRB") muscleInd=ECRBind;
        elseif(activeMuscleStr=="FCR") muscleInd=FCRind;
        end
    elseif(trialN==4)
        % 1 EDCM ; 2 ECRB ; 3 FCU ; 4 FCR
        if(activeMuscleStr=="EDCM") muscleInd=EDCMind;
        elseif(activeMuscleStr=="ECRB") muscleInd=ECRBind;
        elseif(activeMuscleStr=="FCU") muscleInd=FCUind;
        elseif(activeMuscleStr=="FCR") muscleInd=FCRind;
        end
    end
    for j=1:size(movements,2) % note unlike python, MATLAB a:b evaluates to a,...,b NOT a,...,b-1
        movement=movements(j);
        if(movement=="ext") movementInd=extInd;
        elseif(movement=="fle") movementInd=fleInd;
        elseif(movement=="uln") movementInd=ulnInd;
        elseif(movement=="rad") movementInd=radInd;
        end
        inputDir=strcat(longDir,"trial",num2str(trialN),"_dilN0_pt",num2str(ptN),"\",movement,"\afferentOutputDir\");
        
        % breakpoint here to check file names
        statsIa=importdata(strcat(inputDir,fileStr,"_statsIa.mat"));
        statsII=importdata(strcat(inputDir,fileStr,"_statsII.mat"));
        
        %figure(fc);
        %fc=fc+1;
        %title(movement+" "+fileStr+" "+activeMuscleStr+" 0.05 confidence interval");
        
        title(fileStr+" Ia 0.05 confidence interval");
        xlabel("nFiles");
        ylabel("impulses/s")
        hold on
        
        for currNfile=1:size(statsIa,1) % statsIa n cols (aka nFiles)
            % should be same as statsII n cols (aka nFiles)
            
            % note if max==0, its not that nFile doesnt exist for this movement,
            % but instead that nFiles is all zeros
            
            % Ia
            currAvg=statsIa(currNfile,((muscleInd-1)*4)+3);
            % -1 for MATLAB 1 indexing to still provide 0 for first one,
            % *4 for n cols in stats Ia,
            % +2 to get to col for avg, as in statsHeader
            currStdev=statsIa(currNfile,((muscleInd-1)*4)+4);
            % above comments and +3 to get to col for stdev, as in
            % statsHeader
            currN=nForMovementForNfile(movementInd,currNfile);
            if(currN~=0) % currN==0 should never happen
                currSE=currStdev/sqrt(currN); % standard error
            end
            currCIlow=currAvg-(z*currSE); % low bound of confidence interval
            currCIhigh=currAvg+(z*currSE);
            
            % put Ia into plot matricies
            %             if(movement=="ext")
            %                 extPlotStr(i*currNfile,1)=activeMuscleStr+" "+currNfile;
            %                 extPlot(i*currNfile,2)= currAvg;
            %                 extPlot(i*currNfile,3)= currCIlow;
            %                 extPlot(i*currNfile,4)= currCIhigh;
            %             elseif(movement=="fle")
            %                 flePlotStr(i*currNfile,1)=activeMuscleStr+" "+currNfile;
            %                 flePlot(i*currNfile,2)= currAvg;
            %                 flePlot(i*currNfile,3)= currCIlow;
            %                 flePlot(i*currNfile,4)= currCIhigh;
            %             elseif(movement=="uln")
            %                 ulnPlotStr(i*currNfile,1)=activeMuscleStr+" "+currNfile;
            %                 ulnPlot(i*currNfile,2)= currAvg;
            %                 ulnPlot(i*currNfile,3)= currCIlow;
            %                 ulnPlot(i*currNfile,4)= currCIhigh;
            %             elseif(movement=="rad")
            %                 radPlotStr(i*currNfile,1)=activeMuscleStr+" "+currNfile;
            %                 radPlot(i*currNfile,2)= currAvg;
            %                 radPlot(i*currNfile,3)= currCIlow;
            %                 radPlot(i*currNfile,4)= currCIhigh;
            %             end
            
            % upward pointing triangle is confidence interval high bound
            % downward pointing triangle is confidence interval low bound
            % star is average
            % Ia red II blue
            if(movement==plotMovement)
                plot(((currNfile-1)*maxNfiles)+c1,currCIlow,'Marker','v','Color','r');
                line([0,30],[currCIlow,currCIlow],'Color','r'); %refline(0,currCIlow,'Color','r');
                plot(((currNfile-1)*maxNfiles)+c1,currAvg,'Marker','*','Color','r');
                plot(((currNfile-1)*maxNfiles)+c1,currCIhigh,'Marker','^','Color','r');
                line([0,30],[currCIhigh,currCIhigh],'Color','r'); %refline(0,currCIhigh,'Color','r');
                text(((currNfile-1)*maxNfiles)+c1,currAvg,...
                    activeMuscleStr+" "+movement+" nFile="+num2str(currNfile));%,'FontSize',10);
                c1=c1+1;
                
                currSumOfAvgsIa=currSumOfAvgsIa+currAvg;
                currSumOfAvgsCounterIa=currSumOfAvgsCounterIa+1;
                currSumOfNsIa=currSumOfNsIa+currN;
            end
            
            currTrialCurrMuscleAllMovementsSumOfAvgsIa=currTrialCurrMuscleAllMovementsSumOfAvgsIa+currAvg;
            currTrialCurrMuscleAllMovementsSumOfAvgsCounterIa=currTrialCurrMuscleAllMovementsSumOfAvgsCounterIa+1;
            currTrialCurrMuscleAllMovementsSumOfNsIa=currTrialCurrMuscleAllMovementsSumOfNsIa+currN;
            
            tTestsIa(currNfile,((movementInd-1)*6)+1)=currAvg;
            % -1 for MATLAB 1 indexing to still provide 0 for first one,
            % *6 for n cols in tests Ia,
            % +1,2,3,4,5,6 to get col for avg,stdev,n,SE,CIlow,CIhigh
            tTestsIa(currNfile,((movementInd-1)*6)+2)=currStdev;
            tTestsIa(currNfile,((movementInd-1)*6)+3)=currN;
            tTestsIa(currNfile,((movementInd-1)*6)+4)=currSE;
            tTestsIa(currNfile,((movementInd-1)*6)+5)=currCIlow;
            tTestsIa(currNfile,((movementInd-1)*6)+6)=currCIhigh;
            
            % II
            currAvg=statsII(currNfile,((muscleInd-1)*4)+3);
            % -1 for MATLAB 1 indexing to still provide 0 for first one,
            % *4 for n cols in stats II,
            % +2 to get to col for avg, as in statsHeader
            currStdev=statsII(currNfile,((muscleInd-1)*4)+4);
            % above comments and +3 to get to col for stdev, as in
            % statsHeader
            currN=nForMovementForNfile(movementInd,currNfile);
            if(currN~=0) % currN==0 should never happen
                currSE=currStdev/sqrt(currN); % standard error
            end
            currCIlow=currAvg-(z*currSE); % low bound of confidence interval
            currCIhigh=currAvg+(z*currSE);
            
            % put II into plot matricies
            %             if(movement=="ext")
            %                 extPlot(i*currNfile,5)= currAvg;
            %                 extPlot(i*currNfile,6)= currCIlow;
            %                 extPlot(i*currNfile,7)= currCIhigh;
            %             elseif(movement=="fle")
            %                 flePlot(i*currNfile,5)= currAvg;
            %                 flePlot(i*currNfile,6)= currCIlow;
            %                 flePlot(i*currNfile,7)= currCIhigh;
            %             elseif(movement=="uln")
            %                 ulnPlot(i*currNfile,5)= currAvg;
            %                 ulnPlot(i*currNfile,6)= currCIlow;
            %                 ulnPlot(i*currNfile,7)= currCIhigh;
            %             elseif(movement=="rad")
            %                 radPlot(i*currNfile,2)= currAvg;
            %                 radPlot(i*currNfile,3)= currCIlow;
            %                 radPlot(i*currNfile,4)= currCIhigh;
            %             end
            
            % upward pointing triangle is confidence interval high bound
            % downward pointing triangle is confidence interval low bound
            % star is average
            % Ia red II blue
            if(movement==plotMovement)
                plot(((currNfile-1)*maxNfiles)+c1,currCIlow,'Marker','v','Color','b');
                line([0,30],[currCIlow,currCIlow],'Color','b'); %refline(0,currCIlow,'Color','b');
                plot(((currNfile-1)*maxNfiles)+c1,currAvg,'Marker','*','Color','b');
                plot(((currNfile-1)*maxNfiles)+c1,currCIhigh,'Marker','^','Color','b');
                line([0,30],[currCIhigh,currCIhigh],'Color','b'); %refline(0,currCIhigh,'Color','b');
                text(((currNfile-1)*maxNfiles)+c1,currAvg,...
                    activeMuscleStr+" "+movement+" nFile="+num2str(currNfile));
                c1=c1+1;
                
                currSumOfAvgsII=currSumOfAvgsII+currAvg;
                currSumOfAvgsCounterII=currSumOfAvgsCounterII+1;
                currSumOfNsII=currSumOfNsII+currN;
            end
            
            currTrialCurrMuscleAllMovementsSumOfAvgsII=currTrialCurrMuscleAllMovementsSumOfAvgsII+currAvg;
            currTrialCurrMuscleAllMovementsSumOfAvgsCounterII=currTrialCurrMuscleAllMovementsSumOfAvgsCounterII+1;
            currTrialCurrMuscleAllMovementsSumOfNsII=currTrialCurrMuscleAllMovementsSumOfNsII+currN;
            
            tTestsII(currNfile,((movementInd-1)*6)+1)=currAvg;
            % -1 for MATLAB 1 indexing to still provide 0 for first one,
            % *6 for n cols in tests II,
            % +1,2,3,4,5,6 to get col for avg,stdev,n,SE,CIlow,CIhigh
            tTestsII(currNfile,((movementInd-1)*6)+2)=currStdev;
            tTestsII(currNfile,((movementInd-1)*6)+3)=currN;
            tTestsII(currNfile,((movementInd-1)*6)+4)=currSE;
            tTestsII(currNfile,((movementInd-1)*6)+5)=currCIlow;
            tTestsII(currNfile,((movementInd-1)*6)+6)=currCIhigh;
        end
        %         txt1 = ['upward pointing triangle is confidence interval high bound'];
        %         txt2 = ['downward pointing triangle is confidence interval low bound'];
        %         txt3 = ['star is average'];
        %         text(35,250,txt1);
        %         text(35,250,txt2);
        %         text(35,250,txt3);
        %         if(fileStr=="trial3.1pt-1")
        %             xticks([0 1 2 3 4 5]);
        %             %xlim([0,5]);
        %         elseif(fileStr=="trial4pt1" || fileStr=="trial4pt2")
        %             xticks([0 1 2 3]);
        %             %xlim([0,3]);
        %         end
        %hold off
    end
    
    % wanted output file = one Ia,II for each muscle, with rows of trials and
    % cols of movement, subcols of stats (avg,stdev,n,SE,CIlow,CIhigh)
    % uncomment below 2 lines if want to save mats
    %save(strcat(longDir,"tTestDir\",fileStr,"\",activeMuscleStr,"_tTestsIa.mat"),"tTestsIa");
    %save(strcat(longDir,"tTestDir\",fileStr,"\",activeMuscleStr,"_tTestsII.mat"),"tTestsII");
    
%     disp([activeMuscleStr])
%     
%     %Ia
%     disp([currSumOfAvgsIa])
%     disp([currSumOfAvgsCounterIa]) % not necessary data to store, but wanted to see
%     disp([currSumOfNsIa])
%     %avgOfAvgsIa=currSumOfAvgsIa/currSumOfNsIa;
%     avgOfAvgsIa=currSumOfAvgsIa/currSumOfAvgsCounterIa;
%     disp([avgOfAvgsIa])
%     
%     %II
%     disp([currSumOfAvgsII])
%     disp([currSumOfAvgsCounterII]) % not necessary data to store, but wanted to see
%     disp([currSumOfNsII])
%     %avgOfAvgsII=currSumOfAvgsII/currSumOfNsII;
%     avgOfAvgsII=currSumOfAvgsII/currSumOfAvgsCounterII;
%     disp([avgOfAvgsII])
    
    % plot avg of avgs for curr muscle
    line([0 30],[avgOfAvgsIa avgOfAvgsIa+1],'Color','g');
    text(-30,avgOfAvgsIa,activeMuscleStr+" Ia");
    line([0 30],[avgOfAvgsII avgOfAvgsII+1],'Color','g');
    text(-30,avgOfAvgsII,activeMuscleStr+" II");
end

legend('CIlow', 'avg', 'CIhigh');
text(1,-3,"Ia red, II blue");
%saveas(fc,strcat(longDir,"tTestDir\",fileStr,"\tTest_",plotMovement,"_IaAndII_allMuscles_allNfiles.tif"));
%%%saveas(fc,strcat(longDir,"tTestDir\",fileStr,"\tTest_",plotMovement,"_IaAndII_allMuscles_allNfiles_noWords.tif"));
% uncomment below line if want to save tif
saveas(fc,strcat(longDir,"tTestDir\",fileStr,"\tTest_",plotMovement,"_IaAndII_allMuscles_withOverlapLines.tif"));

close all
clear all %-except avgOfAvgsIa avgOfAvgsII currSumOfNsIa currSumOfNsII
