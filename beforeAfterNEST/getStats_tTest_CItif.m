function [tTest2Ia, tTest2II] = getStats_tTest_CItif(trialN, ptN, movement)
% take stats, below is only old 'doDats' section

%trialN=4;
%ptN=2;
trialOther="";
%"mod7_bs_7_results";
alpha=0.05;
if(alpha==0.05)
    z=1.96;
end
doPlot=true;
savePlot=true;
moreMoBL=false;
noMVC=true;
%movement="uln"; % "fle","rad","uln"
if(moreMoBL)
    longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\moreMoBL\collect_states_deg_bs_ModelFiles\";
    trialN=-1;
    ptN=-1;
    inputDir=strcat(longDir,trialOther,"\afferentOutputDir\");
    fileStr=strcat("trial",num2str(trialN),"pt",num2str(ptN));
end

tTest2avgIndex=1;
tTest2stddevIndex=2;
tTest2nIndex=3;
tTest2seIndex=4;
tTest2lowCIIndex=5;
tTest2highCIIndex=6;

tTest2header=["iAmAstring"];
tTest2header(1,1)="movement";
tTest2header(2,1)="current muscle for given (function called with) movement";
tTest2header(3,tTest2avgIndex)="average";
tTest2header(3,tTest2stddevIndex)="standard deviation";
tTest2header(3,tTest2nIndex)="n";
tTest2header(3,tTest2seIndex)="standard error";
tTest2header(3,tTest2lowCIIndex)="confidence interval lower bound";
tTest2header(3,tTest2highCIIndex)="confidence interval higher bound";

tTest2Ia=[];
tTest2II=[];

if(noMVC)
    longDir="E:\moreR\noMVCextractInterval1\";
    %longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\noMVCextract\";
    inputDir=strcat(longDir,"trial",num2str(trialN),"_dilN0_pt",num2str(ptN),"\",movement,"\noPlottingAfferentOutputDir\");
    fileStr=strcat("trial",num2str(trialN),"pt",num2str(ptN));
    
    % don't attempt to open files of tooLowOrHighOptLen
    if(trialN==3.1 && ptN==-1)
        if(movement=="ext") tooHighOrLowOptLen=[];
        elseif(movement=="fle") tooHighOrLowOptLen=[];
        elseif(movement=="rad") tooHighOrLowOptLen=[];
        elseif(movement=="uln") tooHighOrLowOptLen=[];
        end
    elseif(trialN==4)
        if(ptN==1)
            if(movement=="ext") tooHighOrLowOptLen=[2,2,0;4,2,1];
            elseif(movement=="fle") tooHighOrLowOptLen=[1,2,0;2,2,0;3,2,1];
            elseif(movement=="rad") tooHighOrLowOptLen=[1,1,1;1,2,1;1,3,1;2,2,0;3,2,0];
            elseif(movement=="uln") tooHighOrLowOptLen=[1,2,1];
            end
        end
        if(ptN==2)
            if(movement=="ext") tooHighOrLowOptLen=[2,2,1];
            elseif(movement=="fle") tooHighOrLowOptLen=[];
            elseif(movement=="rad") tooHighOrLowOptLen=[1,2,1;2,2,0];
            elseif(movement=="uln") tooHighOrLowOptLen=[1,2,0;2,2,1];
            end
        end
    end
    
    % made to pool data for given trial for given movement for curr muscles
    % from all nFiles, in order to take stdev, avg of Ia,II in all nFiles,
    % in order to get confidence interval (for given trial for given
    % movement for curr muscles) across all nFiles
    poolHeader=["iAmAstring"];
    poolHeader(1,1)="current muscle for given (function called with) movement";
    poolHeader(2,1)="Ia or II pool";
    
    fc=1; % figure counter
    %c1=0;
    if(doPlot)
        figure(fc);
        %fc=fc+1;
        title(fileStr+" "+movement+" Ia alpha="+num2str(alpha)+" confidence interval");
        xlabel("muscles");
        ylabel("impulses/s")
        hold on
    end
    if trialN==3.1 && ptN==-1
        nFiles=31;
        maxNfiles=4;
        if(noMVC) && trialN==3.1
            if(movement=="ext")
                nFiles=2+1;
                leftover=2;
            elseif(movement=="fle")
                nFiles=2+1;
                leftover=2;
            elseif(movement=="uln")
                nFiles=2;
                leftover=0;
            elseif(movement=="rad")
                nFiles=1+1;
                leftover=8;
            end
        end
        activeMuscles = {'time', 'EDCM','ECRB','FCR'};
        
        % myV rows, myC cols
        % copy paste below statsHeader part into Command Window to get statsHeader
        statsHeader=["iAmAString"];
        %statsHeader(1,1)="nFile";
        % note rows are nFile, but no extra col to indicate that so not
        % indicated
        statsHeader(1,1)="EDCM";
        statsHeader(1,1+4)="ECRB";
        statsHeader(1,1+4+4)="FCR";
        statsHeader(2,1)="max";
        statsHeader(2,2)="min";
        statsHeader(2,3)="avg";
        statsHeader(2,4)="stdev";
    elseif trialN==4 && (ptN==1 || ptN==2)
        if ptN==1
            nFiles=17;
            maxNfiles=4;
            if(noMVC)
                if(movement=="ext")
                    nFiles=3+1;
                    leftover=1;
                elseif(movement=="fle")
                    nFiles=2+1;
                    leftover=1;
                elseif(movement=="uln")
                    nFiles=2+1;
                    leftover=1;
                elseif(movement=="rad")
                    nFiles=2+1;
                    leftover=6;
                end
            end
        elseif ptN==2
            nFiles=11;
            maxNfiles=2;
            if(noMVC)
                if(movement=="ext")
                    nFiles=2;
                    leftover=0;
                elseif(movement=="fle")
                    nFiles=1+1;
                    leftover=7;
                elseif(movement=="uln")
                    nFiles=1+1;
                    leftover=9;
                elseif(movement=="rad")
                    nFiles=1+1;
                    leftover=8;
                end
            end
        end
        activeMuscles = {'time', 'EDCM', 'ECRB', 'FCU', 'FCR'};
        
        % myV rows, myC cols
        statsHeader=["iAmAString"];
        statsHeader(1,1)="nFile";
        statsHeader(1,2)="EDCM";
        statsHeader(1,2+4)="ECRB";
        statsHeader(1,2+4+4)="FCR";
        statsHeader(1,2+4+4+4)="FCU";
        statsHeader(2,2)="max";
        statsHeader(2,3)="min";
        statsHeader(2,4)="avg";
        statsHeader(2,5)="stdev";
    end
    
    sizeA=size(activeMuscles);
    
    % myV rows, myC cols
    statsIa=zeros(nFiles,(sizeA(2)-1)*4); % *4 for avg, min, max, std -1 for 'time'
    statsII=zeros(nFiles,(sizeA(2)-1)*4);
    
    poolIa=zeros(10000000,1);
    % *6 for Ia pool, II pool, Ia avg, Ia stddev, II avg, II stdev -1 for 'time'
    % really large n Rows to hopefully surpass the number of rows
    % of all .dat files ( as opposed to opening every file just to
    % get nRows, summing all nRows, and initializing poolIa with
    % that sum nRows
    poolII=zeros(10000000,1);
    poolIaCounter=1; % counter to know which rows in poolIa,II are actual
    % data, not zeros created in making poolIa,II
    poolIICounter=1;
    
    IaCol=3;
    IICol=4;
    
    % take max min avg stdev of each file , save in array
    for j=1:sizeA(2)
        if(j==1) % time
            continue
        end
        currentMuscle=activeMuscles(j);
        currentMuscleStr=currentMuscle{1};
%         if(currentMuscleStr=="ECRB")
%             "hi"
%         end
        tooHighOrLowCounter=0;
        for i=1:nFiles
            %if(i==4 && currentMuscle{1}=="FCU")
            %    "hi"
            %end
            tooHighOrLow=false;
            if(trialN==3.1 && ptN==-1)
                for x=1:size(tooHighOrLowOptLen,1)
                    tooHighOrLowOptLenMyV=tooHighOrLowOptLen(x,1);
                    tooHighOrLowOptLenMyC=tooHighOrLowOptLen(x,2);
                    % 3main.py currentMuscles = [0 "FCR", 1 "ECRB", 2 "EDCM"],
                    % activeMuscles = {1 'time', 2 'EDCM', 3 'ECRB',4 'FCR'};
                    % thus neither is in same order, and can't easily
                    % change order of activeMuscles ; likely can easily change
                    % order of 3main.py currentMuscles, but then would need
                    % to rerun all , thus
                    if(tooHighOrLowOptLenMyC==0) % if myC==0 , FCR
                        tooHighOrLowOptLenMyC=4;
                    elseif(tooHighOrLowOptLenMyC==1) % if myC==1 , ECRB
                        tooHighOrLowOptLenMyC=3;
                    elseif(tooHighOrLowOptLenMyC==2) % if myC==2 , EDCM
                        tooHighOrLowOptLenMyC=2;
                    end
                    if(tooHighOrLowOptLenMyV==nFiles && tooHighOrLowOptLenMyC==j)
                        % note that with above adjustments, obv python
                        % myC 0-indexing vs MATLAB j 1 indexing already
                        % accounted for
                        tooHighOrLow=true;
                        break;
                    end
                end
            elseif(trialN==4 && (ptN==1||ptN==2))
%                 if(ptN==2 && currentMuscleStr=="FCU")
%                     "hi"
%                 end
                for x=1:size(tooHighOrLowOptLen,1)
                    tooHighOrLowOptLenMyV=tooHighOrLowOptLen(x,1);
                    tooHighOrLowOptLenMyC=tooHighOrLowOptLen(x,2);
                    % 3main.py currentMuscles=[0 "EDCM", 1 "ECRB", 2 "FCU", 3 "FCR"],
                    % activeMuscles = {1 'time', 2 'EDCM', 3 'ECRB', 4 'FCU',
                    % 5 'FCR'}
                    % thus neither is in same order, and can't easily
                    % change order of activeMuscles ; likely can easily change
                    % order of 3main.py currentMuscles, but then would need
                    % to rerun all , thus just match each muscle
                    if(tooHighOrLowOptLenMyC==0) % if myC==0 , EDCM
                        tooHighOrLowOptLenMyC=2;
                    elseif(tooHighOrLowOptLenMyC==1) % if myC==1 , ECRB
                        tooHighOrLowOptLenMyC=3;
                    elseif(tooHighOrLowOptLenMyC==2) % if myC==2 , FCU
                        tooHighOrLowOptLenMyC=4;
                    elseif(tooHighOrLowOptLenMyC==3) % if myC==3 , FCR
                        tooHighOrLowOptLenMyC=5;
                    end
                    if(tooHighOrLowOptLenMyV==i && tooHighOrLowOptLenMyC==j)
                        % note that for myV, python myV starts at 1 and
                        % MATLAB i starts at 1 so no adjustment for python
                        % 0-indexing vs MATLAB 1 indexing necessary
                        % for myC, with above adjustments, obv python
                        % myC 0-indexing vs MATLAB j 1 indexing already
                        % accounted for
                        tooHighOrLow=true;
                        break;
                    end
                end
            end
            if(tooHighOrLow)
                %{
                                    statsIa(i,(j-2)*4+1)=-1;
                statsIa(i,(j-2)*4+1+1)=-1;
                statsIa(i,(j-2)*4+1+1+1)=-1;
                statsIa(i,(j-2)*4+1+1+1+1)=-1;
                                    statsII(i,(j-2)*4+1)=-1;
                statsII(i,(j-2)*4+1+1)=-1;
                statsII(i,(j-2)*4+1+1+1)=-1;
                statsII(i,(j-2)*4+1+1+1+1)=-1;
                %}
                %break;
                tooHighOrLowCounter=tooHighOrLowCounter+1;
                continue
            end
            %currentMuscle=activeMuscles(j);
            strcat(inputDir,fileStr,"_",num2str(i),"_",currentMuscleStr,"afferents-104-0.dat")
            myInputFile=importdata(strcat(inputDir,fileStr,"_",num2str(i),"_",currentMuscleStr,"afferents-104-0.dat"));
            
            %test=[1,2,3,4];
            myMax=max(myInputFile(:,IaCol)); %4
            myMin=min(myInputFile(:,IaCol)); %1
            myAvg=mean(myInputFile(:,IaCol)); %2.5
            myStdev=std(myInputFile(:,IaCol));
            statsIa(i,(j-2)*4+1)=myMax;
            statsIa(i,(j-2)*4+1+1)=myMin;
            statsIa(i,(j-2)*4+1+1+1)=myAvg;
            statsIa(i,(j-2)*4+1+1+1+1)=myStdev;
            
            myMax=max(myInputFile(:,IICol)); %4
            myMin=min(myInputFile(:,IICol)); %1
            myAvg=mean(myInputFile(:,IICol)); %2.5
            myStdev=std(myInputFile(:,IICol));
            statsII(i,(j-2)*4+1)=myMax;
            statsII(i,(j-2)*4+1+1)=myMin;
            statsII(i,(j-2)*4+1+1+1)=myAvg;
            statsII(i,(j-2)*4+1+1+1+1)=myStdev;
            
            poolIa(poolIaCounter:(poolIaCounter+size(myInputFile,1)-1),1)=myInputFile(:,IaCol);
            poolII(poolIICounter:(poolIICounter+size(myInputFile,1)-1),1)=myInputFile(:,IICol);
            poolIaCounter=poolIaCounter+size(myInputFile,1);
            poolIICounter=poolIICounter+size(myInputFile,1);
            
            fclose("all");
        end
        
        % if all files with currentMuscle were tooHighOrLow, then don't
        % plot avg (as opposed to plotting currMuscle avg at zero, which isnt true)
        if(tooHighOrLowCounter==nFiles)
            continue
        end
        
        % get confidence interval (for given trial for given
        % movement for curr muscles) across all nFiles
        
        "movement "+movement+" trial "+num2str(trialN)+" ptN "+num2str(ptN)+" muscle "+currentMuscleStr
        "poolIaCounter "+num2str(poolIaCounter)
        % t-test confidence interval ;
        % x bar is givenTrialGivenMovementAllnFilesAvgIa,II
        % stddev is givenTrialGivenMovementAllnFilesStddevIa,II
        % n is poolIa,IICounter
        
        %Ia
        givenTrialGivenMovementAllnFilesAvgIa=sum(poolIa(1:poolIaCounter,1))/poolIaCounter
        givenTrialGivenMovementAllnFilesStddevIa=std(poolIa(1:poolIaCounter,1))
        if(poolIaCounter~=0) % n==0 should never happen
            % standard error = standard deviation / sqrt(n)
            SE=givenTrialGivenMovementAllnFilesStddevIa/sqrt(poolIaCounter); % standard error
        end
        % confidence interval low, high bounds= x bar +- (z*standard
        % error)
        givenTrialGivenMovementAllnFilesCIlowIa=givenTrialGivenMovementAllnFilesAvgIa-(z*SE); % low bound of confidence interval
        givenTrialGivenMovementAllnFilesCIhighIa=givenTrialGivenMovementAllnFilesAvgIa+(z*SE); % high bound
        
        % j-2 since j==1 at activeMuscle "time", j==2 for 1st muscle, but
        % for 1st muscle to map to 1st index despite *6, subtract 1 
        tTest2Ia(1,(j-2)*6+tTest2avgIndex)=givenTrialGivenMovementAllnFilesAvgIa;
        tTest2Ia(1,(j-2)*6+tTest2stddevIndex)=givenTrialGivenMovementAllnFilesStddevIa;
        tTest2Ia(1,(j-2)*6+tTest2nIndex)=poolIaCounter;
        tTest2Ia(1,(j-2)*6+tTest2seIndex)=SE;
        tTest2Ia(1,(j-2)*6+tTest2lowCIIndex)=givenTrialGivenMovementAllnFilesCIlowIa;
        tTest2Ia(1,(j-2)*6+tTest2highCIIndex)=givenTrialGivenMovementAllnFilesCIhighIa;
        
        %II
        givenTrialGivenMovementAllnFilesAvgII=sum(poolII(1:poolIICounter,1))/poolIICounter
        givenTrialGivenMovementAllnFilesStddevII=std(poolII(1:poolIICounter,1))
        if(poolIICounter~=0) % n==0 should never happen
            % standard error = standard deviation / sqrt(n)
            SE=givenTrialGivenMovementAllnFilesStddevII/sqrt(poolIICounter); % standard error
        end
        % confidence interval low, high bounds= x bar +- (z*standard
        % error)
        givenTrialGivenMovementAllnFilesCIlowII=givenTrialGivenMovementAllnFilesAvgII-(z*SE); % low bound of confidence interval
        givenTrialGivenMovementAllnFilesCIhighII=givenTrialGivenMovementAllnFilesAvgII+(z*SE); % high bound

        % j-2 since j==1 at activeMuscle "time", j==2 for 1st muscle, but
        % for 1st muscle to map to 1st index despite *6, subtract 1 
        tTest2II(1,(j-2)*6+tTest2avgIndex)=givenTrialGivenMovementAllnFilesAvgII;
        tTest2II(1,(j-2)*6+tTest2stddevIndex)=givenTrialGivenMovementAllnFilesStddevII;
        tTest2II(1,(j-2)*6+tTest2nIndex)=poolIICounter;
        tTest2II(1,(j-2)*6+tTest2seIndex)=SE;
        tTest2II(1,(j-2)*6+tTest2lowCIIndex)=givenTrialGivenMovementAllnFilesCIlowII;
        tTest2II(1,(j-2)*6+tTest2highCIIndex)=givenTrialGivenMovementAllnFilesCIhighII;
        
        if(doPlot)
            % upward pointing triangle is confidence interval high bound
            % downward pointing triangle is confidence interval low bound
            % star is average
            % Ia red II blue
            
            plot(j,givenTrialGivenMovementAllnFilesCIlowIa,'Marker','v','Color','r');
            line([0,6],[givenTrialGivenMovementAllnFilesCIlowIa,givenTrialGivenMovementAllnFilesCIlowIa],'Color','r');
            %refline(0,currCIhigh,'Color','b');
            plot(j,givenTrialGivenMovementAllnFilesAvgIa,'Marker','*','Color','r');
            plot(j,givenTrialGivenMovementAllnFilesCIhighIa,'Marker','^','Color','r');
            line([0,6],[givenTrialGivenMovementAllnFilesCIhighIa,givenTrialGivenMovementAllnFilesCIhighIa],'Color','r');
            text(j,givenTrialGivenMovementAllnFilesAvgIa,...
                currentMuscleStr+" Ia "+movement);
            
            plot(j,givenTrialGivenMovementAllnFilesCIlowII,'Marker','v','Color','b');
            line([0,6],[givenTrialGivenMovementAllnFilesCIlowII,givenTrialGivenMovementAllnFilesCIlowII],'Color','b');
            %refline(0,currCIhigh,'Color','b');
            plot(j,givenTrialGivenMovementAllnFilesAvgII,'Marker','*','Color','b');
            plot(j,givenTrialGivenMovementAllnFilesCIhighII,'Marker','^','Color','b');
            line([0,6],[givenTrialGivenMovementAllnFilesCIhighII,givenTrialGivenMovementAllnFilesCIhighII],'Color','b');
            text(j,givenTrialGivenMovementAllnFilesAvgII,...
                currentMuscleStr+" II "+movement);
        end
        poolIa=zeros(10000000,1);
        poolII=zeros(10000000,1);
        poolIaCounter=1;
        poolIICounter=1;
    end
    if(doPlot)
        legend('CIlow', 'avg', 'CIhigh');
        text(1,-3,"Ia red, II blue");
        if(savePlot) 
            saveas(fc,strcat(longDir,"tTestDir\",...
                fileStr,"\tTest_",movement,...
                "_IaAndII_allMuscles_withOverlapLines_madeWithGetStats.tif"));
        end
    end
    hold off
elseif trialOther=="MoBLmod4wrist"
    nFiles=65;
    fileStr="MoBLmod4wrist";
    inputDir="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLcompareResultsMod4wrist\afferentOutputDir\in100msIncrements\simulate10ms\";
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
    %badMyVifCis0={"9","10","11","12","13","14","15","16","17","18","19","20","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48"};
    
    % myV rows, myC cols
    statsHeader=["iAmAString"];
    statsHeader(1,1)="nFile";
    statsHeader(1,2)="ECRL";
    statsHeader(1,2+4)="ECRB";
    statsHeader(1,2+4+4)="ECU";
    statsHeader(1,2+4+4+4)="FCR";
    statsHeader(1,2+4+4+4+4)="FCU";
    statsHeader(2,2)="max";
    statsHeader(2,3)="min";
    statsHeader(2,4)="avg";
    statsHeader(2,5)="stdev";
    
    sizeA=size(activeMuscles);
    
    % myV rows, myC cols
    statsIa=zeros(nFiles,(sizeA(2)-1)*4); % *4 for avg, min, max, std -1 for 'time'
    statsII=zeros(nFiles,(sizeA(2)-1)*4);
    
    IaCol=3;
    IICol=4;
    
    % take max min avg stdev of each file , save in array
    for i=1:nFiles
        for j=1:sizeA(2)
            if(j==1) % time
                continue
            elseif(trialOther=="MoBLmod4wrist" && ((i>8 && i<21)||(i>26 && i<49)) && j==3)
                % for MoBLmod4wrist, myV myC in these conditions made Killed
                % pyNEST so afferent file invalid so don't put in stats
                continue
            end
            currentMuscle=activeMuscles(j);
            myInputFile=importdata(strcat(inputDir,fileStr,"_",num2str(i),"_",currentMuscleStr,"afferents-104-0.dat"));
            
            %test=[1,2,3,4];
            myMax=max(myInputFile(:,IaCol)); %4
            myMin=min(myInputFile(:,IaCol)); %1
            myAvg=mean(myInputFile(:,IaCol)); %2.5
            myStdev=std(myInputFile(:,IaCol));
            statsIa(i,(j-2)*4+1)=myMax;
            statsIa(i,(j-2)*4+1+1)=myMin;
            statsIa(i,(j-2)*4+1+1+1)=myAvg;
            statsIa(i,(j-2)*4+1+1+1+1)=myStdev;
            
            myMax=max(myInputFile(:,IICol)); %4
            myMin=min(myInputFile(:,IICol)); %1
            myAvg=mean(myInputFile(:,IICol)); %2.5
            myStdev=std(myInputFile(:,IICol));
            statsII(i,(j-2)*4+1)=myMax;
            statsII(i,(j-2)*4+1+1)=myMin;
            statsII(i,(j-2)*4+1+1+1)=myAvg;
            statsII(i,(j-2)*4+1+1+1+1)=myStdev;
            fclose("all");
        end
    end
elseif moreMoBL
    if trialOther=="mod2_bs_allpassivemuscles_bs_2_shoulder"
        nFiles=138;
    elseif trialOther=="mod4_bs_4_articleResults"
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Elbow"
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Shoulder"
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Wrist"
        nFiles=651;
    elseif trialOther=="mod6_bs_SimulationResults"
        nFiles=433;
    elseif trialOther=="mod7_bs_7_results"
        nFiles=398;
    end
    fileStr=trialOther;
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};%,'EDCM'};
    %badMyVifCis0={"9","10","11","12","13","14","15","16","17","18","19","20","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48"};
    
    % myV rows, myC cols
    statsHeader=["iAmAString"];
    statsHeader(1,1)="nFile";
    statsHeader(1,2)="ECRL";
    statsHeader(1,2+4)="ECRB";
    statsHeader(1,2+4+4)="ECU";
    statsHeader(1,2+4+4+4)="FCR";
    statsHeader(1,2+4+4+4+4)="FCU";
    %statsHeader(1,2+4+4+4+4+4)="EDCM";
    statsHeader(2,2)="max";
    statsHeader(2,3)="min";
    statsHeader(2,4)="avg";
    statsHeader(2,5)="stdev";
    
    sizeA=size(activeMuscles);
    
    % myV rows, myC cols
    statsIa=zeros(nFiles,(sizeA(2)-1)*4); % *4 for avg, min, max, std -1 for 'time'
    statsII=zeros(nFiles,(sizeA(2)-1)*4);
    
    IaCol=3;
    IICol=4;
    
    % take max min avg stdev of each file , save in array
    for j=1:sizeA(2)
        if(j==1) % time
            continue
            %elseif(trialOther=="mod4_bs_SimulationResults_bs_Wrist" && j==7)
            %    % for mod4_bs_SimulationResults_bs_Wrist, myV myC in these conditions were often Killed
            %    % pyNEST so afferent file invalid so don't put in stats
            %    continue
        end
        currentMuscle=activeMuscles(j);
        for i=1:nFiles
            
            a=strcat(inputDir,num2str(i),"_",currentMuscleStr,"afferents-104-0.dat")
            
            if((trialOther=="mod4_bs_4_articleResults" && currentMuscleStr=="ECRB" && i>111 && i<500) ...
                    || (trialOther=="mod4_bs_SimulationResults_bs_Elbow" && currentMuscleStr=="ECRB" && i==115) ...
                    || (trialOther=="mod4_bs_SimulationResults_bs_Shoulder" && currentMuscleStr=="ECRB" && i==115) ...
                    || (trialOther=="mod4_bs_SimulationResults_bs_Wrist" && i>72 && i<600))
                % '-1's don't pull down avg and other stats since avgs
                % dont have another avg over all avgs or other stats
                % like that
                
                myMaxIa=-1;
                myMinIa=-1;
                myAvgIa=-1;
                myStdevIa=-1;
                
                myMaxII=-1;
                myMinII=-1;
                myAvgII=-1;
                myStdevII=-1;
            else
                "imported"
                myInputFile=importdata(strcat(inputDir,num2str(i),"_",currentMuscleStr,"afferents-104-0.dat"));
                
                %test=[1,2,3,4];
                
                myMaxIa=max(myInputFile(:,IaCol)); %4
                myMinIa=min(myInputFile(:,IaCol)); %1
                myAvgIa=mean(myInputFile(:,IaCol)); %2.5
                myStdevIa=std(myInputFile(:,IaCol));
                
                myMaxII=max(myInputFile(:,IICol)); %4
                myMinII=min(myInputFile(:,IICol)); %1
                myAvgII=mean(myInputFile(:,IICol)); %2.5
                myStdevII=std(myInputFile(:,IICol));
            end
            statsIa(i,(j-2)*4+1)=myMaxIa;
            statsIa(i,(j-2)*4+1+1)=myMinIa;
            statsIa(i,(j-2)*4+1+1+1)=myAvgIa;
            statsIa(i,(j-2)*4+1+1+1+1)=myStdevIa;
            
            statsII(i,(j-2)*4+1)=myMaxII;
            statsII(i,(j-2)*4+1+1)=myMinII;
            statsII(i,(j-2)*4+1+1+1)=myAvgII;
            statsII(i,(j-2)*4+1+1+1+1)=myStdevII;
            
            fclose("all");
        end
    end
end
%save("C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLmod4wrist_statsIa","statsIa");
%save("C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLmod4wrist_statsII","statsII");
% yes, even though it is output, it is going in inputDir
save(strcat(inputDir,fileStr,"_statsIa.mat"),"statsIa");
save(strcat(inputDir,fileStr,"_statsII.mat"),"statsII");

%load handel
%sound(y,Fs)

clearvars -except tTest2Ia tTest2II 
close all
end
