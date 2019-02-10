% take stats
clear all
close all

doMoTONMS=false;
doMyADIEMG=false;
doMyProcessedEMG=false;
doOlderStuff=false;
doDats=true;
if doMoTONMS
    % dont delete commented section
    % MoTONMS
    
    nFilesProduced = 8; % ( = n muscles ? )
    
    rawMean=zeros(nFilesProduced,16);
    rawMax=zeros(nFilesProduced,16);
    rawMin=zeros(nFilesProduced,16);
    rawStd=zeros(nFilesProduced,16);
    
    for f=1:nFilesProduced
        % raw files
        myFilename=strcat("C:\InteruserWorkspace\EMGrelated\MOtoNMS v2.2\src\DataProcessing\mine\mats\EMGDataRawZeroMean_",num2str(f),".mat");
        load(myFilename);
        %take min max avg std into files
        rawMean(f,:)=mean(EMGDataRawZeroMean(:,:));
        rawMax(f,:)=max(EMGDataRawZeroMean(:,:));
        rawMin(f,:)=min(EMGDataRawZeroMean(:,:));
        rawStd(f,:)=std(EMGDataRawZeroMean(:,:));
        
        clear EMGDataRawZeroMean
    end
    
    totalRawMean=mean(rawMean(:,:));
    totalRawMax=max(rawMax(:,:));
    totalRawMin=min(rawMin(:,:));
    totalRawStd=std(rawStd(:,:));
    
    % processed files
    processedMean=zeros(nFilesProduced,16);
    processedMax=zeros(nFilesProduced,16);
    processedMin=zeros(nFilesProduced,16);
    processedStd=zeros(nFilesProduced,16);
    
    for f=1:nFilesProduced
        % raw files
        myFilename=strcat("C:\InteruserWorkspace\EMGrelated\MOtoNMS v2.2\src\DataProcessing\mine\mats\LinEnvEMGAll_",num2str(f),".mat");
        load(myFilename);
        %take min max avg std into files
        processedMean(f,:)=mean(LinEnvEMGAll(:,:));
        processedMax(f,:)=max(LinEnvEMGAll(:,:));
        processedMin(f,:)=min(LinEnvEMGAll(:,:));
        processedStd(f,:)=std(LinEnvEMGAll(:,:));
        
        clear LinEnvEMGAll
    end
    
    totalProcessedMean=mean(processedMean(:,:));
    totalProcessedMax=max(processedMean(:,:));
    totalProcessedMin=min(processedMean(:,:));
    totalProcessedStd=std(processedMean(:,:));
elseif doMyADIEMG
    
    % ADI EMG .mat
    
    trialN = 3.1;
    ptN=-1;
    
    badPart=zeros(1,4);
    % badPart(1) = 'there is bad part at end' ,bool
    % 2 = 'length of bad part at end'
    % 3 = 'there is bad part at start',bool
    % 4 = 'length of bad part at start'
    nMin=-1;
    if(trialN==3.1)
        %only want up to 160 s since afterwards is straight
        %hand movements, which dont care about since likely not in Dr. Jones study
        % =up to and including fileN 16
        sectionEndMin=5;
        sectionEndSec=13.68;
        cutoffMin = 0;
        cutoffSec=0;
        badPart(1)=0; % 0 = there is no stuff to cut out at the front
        badPart(2)=0;
        cutoffMin = 2;
        cutoffSec=40;
        badPart(3)=1;
        badPart(4)=((60*cutoffMin)+cutoffSec)*(1000/1); % convert to ms
    elseif(trialN==4)
        if(ptN==1)
            %7:01-end for chn4, apply to all chns
            badPart(1)=1; % 1 = there is stuff to cut out
            %badPart(2)=2; % which channel to cut out ; in trial4, cut out all chns
            %since what would be done with potentially corrupted channels in
            %processing anyways
            sectionEndMin=7;
            sectionEndSec=28.638;
            cutoffMin = 7;
            cutoffSec=1;
            badPart(2)=(((60*sectionEndMin)+sectionEndSec)*(1000/1))-(((60*cutoffMin)+cutoffSec)*(1000/1)); % convert to ms
            badPart(3)=0;
            badPart(4)=0;
        elseif(ptN==2)
            %0-0:10, 2:20-end, apply to all chns
            sectionEndMin=2;
            sectionEndSec=32.25;
            cutoffMin = 2;
            cutoffSec=20;
            badPart(1)=1; % 1 = there is stuff to cut out
            badPart(2)=(((60*sectionEndMin)+sectionEndSec)*(1000/1))-(((60*cutoffMin)+cutoffSec)*(1000/1)); % convert to ms
            cutoffMin = 0;
            cutoffSec=20;%10;
            badPart(3)=1;
            badPart(4)=((60*cutoffMin)+cutoffSec)*(1000/1); % convert to ms
        end
    end
    
    % dont delete commented section
    %% raw
    % trial1 = section 2
    % trial2 = section 3
    % trial3 = section 8
    % trial1 'C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial1\ECR_trial1_10excitation_atEnd1MVC_electrodesCopyToOperateOn.mat'
    % trial2 'C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial2\trial2_electrodes2.mat'
    % trial3 'C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial3\trial3_2.mat'
    if trialN == 1
        sectionN = 2;
        load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial1\ECR_trial1_10excitation_atEnd1MVC_electrodesCopyToOperateOn.mat');
        %outputDir = 'C:\InteruserWorkspace\EMGrelated\MATLABscripts\trial1\';
    elseif trialN == 2
        sectionN = 3;
        load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial2\trial2_electrodes2.mat');
        %outputDir = 'C:\InteruserWorkspace\EMGrelated\MATLABscripts\trial2\';
    elseif trialN == 3 || trialN == 3.1
        sectionN = 8;
        load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial3\trial3_2.mat');
        %outputDir = 'C:\InteruserWorkspace\EMGrelated\MATLABscripts\trial3\';
    elseif trialN == 4
        load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial4\trial4_onlyActiveChannels.mat');
        if ptN==1
            sectionN = 12;
        elseif ptN==2
            sectionN = 13;
        end
    end
    
    % key
    % trial1
    % channel3 = ECR ; channelN = 1
    % trial2
    % channel3 = ECR ; channelN = 1
    % channel4 = FCR ; channelN = 2
    % channel8 = ECU ; channelN = 3
    % trial3
    % channel4 = ECU ; channelN = 1 % into fake EDC z
    % channel7 = FCR ; channelN = 2
    % channel8 = ECR ; channelN = 3
    % trial3.1 z
    % channel4 = 'ECU' > not used; channelN = 1
    % channel7 = 'FCR' > FCR; channelN = 2 z
    % channel8 = 'ECR' > ECRB,EDC ; channelN = 3
    
    sizeA = size(titles);
    
    totalRawTrialMean=zeros(sizeA(1),1);
    totalRawTrialMax=zeros(sizeA(1),1);
    totalRawTrialMin=zeros(sizeA(1),1);
    totalRawTrialStd=zeros(sizeA(1),1);
    
    if(trialN==3.1)% trial 3.1, discard first channel
        startA=2;
    else
        startA=1;
    end
    
    for channelN=startA:sizeA(1,1)
        if(not(badPart(1)))
            actualData = data(datastart(channelN, sectionN):dataend(channelN, sectionN));
        end
        if(not(badPart(3)))
            %if(channelN==badPart(2))
            % actualData = from current start to (cutoff (badPart(2)) +
            % n previous sections*each sectionSize (sectionSize * nChannels past))
            actualData = data(datastart(channelN, sectionN):(dataend(channelN,sectionN)-badPart(2)));
            %end
        else
            actualData = data((datastart(channelN, sectionN)+badPart(4)):(dataend(channelN,sectionN)-badPart(2)));
        end
        
        %take min max avg std into files
        totalRawTrialMean(channelN,:)=mean(actualData(:,:));
        totalRawTrialMax(channelN,:)=max(actualData(:,:));
        totalRawTrialMin(channelN,:)=min(actualData(:,:));
        totalRawTrialStd(channelN,:)=std(actualData(:,:));
        
        clear actualData
    end
    
    % yes they should all be mean()
    avgTotalRawTrialMean=mean(totalRawTrialMean(:,1));
    avgTotalRawTrialMax=mean(totalRawTrialMax(:,1));
    avgTotalRawTrialMin=mean(totalRawTrialMin(:,1));
    avgTotalRawTrialStd=mean(totalRawTrialStd(:,1));
    
elseif doMyProcessedEMG
    %% processed
    whatToDo="linEnvWinsize1000";
    %"recheckMaxs";
    %"dilated3";
    %"MoBLdilated";
    %notNormalized
    %notDilated
    %dilated2
    %dilated3
    
    linEnvWinsize1000homeDir="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\mats\linEnvWinsize1000\";
    if whatToDo=="linEnvWinsize1000"
        if trialN==3.1
            d=linEnvWinsize1000homeDir+"trial3.1_dilN0_pt-1.mat";
            load(d);
            data=totalData;
        elseif trialN==4
            if ptN==1
                d=linEnvWinsize1000homeDir+"trial4_dilN0_pt1.mat";
                load(d);
                data=totalData;
            elseif ptN==2
                d=linEnvWinsize1000homeDir+"trial4_dilN0_pt2.mat";
                load(d);
                data=totalData;
            end
        end
    else
        error("not verified operation");
        %{
elseif trialN == 3
    if(whatToDo=="notNormalized")
        outhiAbsA=0;
        load("C:\InteruserWorkspace\EMGrelated\MATLABscripts\betterEMGprocessingMoTONMS\outhiAbsA.mat");
        data=outhiAbsA;
    elseif(whatToDo=="notDilated")
        totalData=0;
        load("C:\InteruserWorkspace\EMGrelated\MATLABscripts\puttingTogetherNoFileReferences\noDilation.mat");
        data=totalData;
    elseif(whatToDo=="dilated2")
        dilatedD=0;
        load("C:\InteruserWorkspace\EMGrelated\MATLABscripts\puttingTogetherNoFileReferences\withDilation.mat");
        data=dilatedD;
    elseif(whatToDo=="MoBLdilated")
        dilatedD=0;
        load("C:\InteruserWorkspace\EMGrelated\MATLABscripts\puttingTogetherNoFileReferences\withMoBLdilation.mat");
        data=dilatedD;
    elseif(whatToDo=="dilated3")
        dilatedD=0;
        load("C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\dilation3polymorphic.mat");
        data=dilatedD;
    end
elseif trialN==3.1
    if whatToDo=="recheckMaxs"
        dilatedD=0;
        load("C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\trial3.1dilN0dilatedD.mat");
        data=dilatedD;
    end
        %}
    end
    
    % processed doesnt need badPart since already accounted for in
    % EMGprocessingPolymorphic.m
    
    sizeA=size(totalData);
    
    totalTrialMean=zeros(sizeA(1),1);
    totalTrialMax=zeros(sizeA(1),1);
    totalTrialMin=zeros(sizeA(1),1);
    totalTrialStd=zeros(sizeA(1),1);
    
    % trial 3.1 first channel already discarded
    
    %take min max avg std into files
    totalTrialMean=mean(totalData(:,:)); % should all be ones
    totalTrialMax=max(totalData(:,:));
    totalTrialMin=min(totalData(:,:));
    totalTrialStd=std(totalData(:,:));
    
    % yes they should all be mean()
    avgTotalTrialMean=mean(totalTrialMean); % should be 1
    avgTotalTrialMax=mean(totalTrialMax);
    avgTotalTrialMin=mean(totalTrialMin);
    avgTotalTrialStd=mean(totalTrialStd);
elseif doOlderStuff
    s="mats\trial4dilN3pt1.mat";
    load(s);
    s
    
    data = dilatedD;
    
    sizeA=size(data);
    whatToDo="null";
    
    if(whatToDo=="notNormalized")
        totalProcessedTrial3Mean=zeros(1,sizeA(1));
        totalProcessedTrial3Max=zeros(1,sizeA(1));
        totalProcessedTrial3Min=zeros(1,sizeA(1));
        totalProcessedTrial3Std=zeros(1,sizeA(1));
        
        for i=1:sizeA(1)
            totalProcessedTrial3Mean(1,i)=mean(data(i,:));
            totalProcessedTrial3Max(1,i)=max(data(i,:));
            totalProcessedTrial3Min(1,i)=min(data(1,:));
            totalProcessedTrial3Std(1,i)=std(data(1,:));
        end
    else
        totalProcessedTrial3Mean=zeros(1,sizeA(2));
        totalProcessedTrial3Max=zeros(1,sizeA(2));
        totalProcessedTrial3Min=zeros(1,sizeA(2));
        totalProcessedTrial3Std=zeros(1,sizeA(2));
        
        for i=1:sizeA(2)
            %take min max avg std into files
            totalProcessedTrial3Mean(1,i)=mean(data(:,i));
            totalProcessedTrial3Max(1,i)=max(data(:,i));
            totalProcessedTrial3Min(1,i)=min(data(:,i));
            totalProcessedTrial3Std(1,i)=std(data(:,i));
        end
    end
elseif doDats
    trialN=4;
    ptN=2;
    trialOther="";
    %"mod7_bs_7_results";
    %justStdev=true;
    moreMoBL=false;
    noMVC=true;
    movement="uln"; % "fle","rad","uln"
    if(moreMoBL)
        longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\moreMoBL\collect_states_deg_bs_ModelFiles\";
        trialN=-1;
        ptN=-1;
        inputDir=strcat(longDir,trialOther,"\afferentOutputDir\");
        fileStr=strcat("trial",num2str(trialN),"pt",num2str(ptN));
    end
    if(noMVC)
        longDir="E:\moreR\noMVCextract\";
        %longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\noMVCextract\";
        inputDir=strcat(longDir,"trial",num2str(trialN),"_dilN0_pt",num2str(ptN),"\",movement,"\afferentOutputDir\");
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
    end
    
    % made to pool data for given trial for given movement for curr muscles
    % from all nFiles, in order to take stdev, avg of Ia,II in all nFiles,
    % in order to get confidence interval (for given trial for given
    % movement for curr muscles) across all nFiles
    poolHeader=["iAmAstring"];
    poolHeader(1,1)="3.1: EDCM, 4: EDCM";
    poolHeader(1,1+4)="3.1: ECRB, 4: ECRB";
    poolHeader(1,1+4+4)="3.1: FCR, 4: FCU";
    poolHeader(1,1+4+4+4)="3.1: -, 4: FCR";
    poolHeader(2,1)="Iapool";
    poolHeader(2,2)="IIpool";
    poolHeader(2,4)="IaAvg";
    poolHeader(2,4)="IIstdDev";
    poolHeader(2,5)="IIavg";
    poolHeader(2,6)="IIstdDev";
    
    if trialN==3.1 && ptN==-1
        nFiles=31;
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
        
        sizeA=size(activeMuscles);
        
        % myV rows, myC cols
        statsIa=zeros(nFiles,(sizeA(2)-1)*4); % *4 for avg, min, max, std -1 for 'time'
        statsII=zeros(nFiles,(sizeA(2)-1)*4);
        
        poolIa=zeros(1,(sizeA(2)-1)*6); % *6 for Ia pool, II pool, Ia avg, Ia stddev, II avg, II stdev -1 for 'time'
        poolII=zeros(1,(sizeA(2)-1)*6);
        poolIaCounter=1;
        poolIICounter=1;
        
        IaCol=3;
        IICol=4;
        
        % take max min avg stdev of each file , save in array
        for i=1:nFiles
            for j=1:sizeA(2)
                if(j==1) % time
                    continue
                end
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
                        continue % dont need to put in code and bool to 
                        % break since trial3.1 has no tooHighTooLow anyways
                    end
                end
                currentMuscle=activeMuscles(j);
                strcat(inputDir,fileStr,"_",num2str(i),"_",currentMuscle{1},"afferents-104-0.dat")
                myInputFile=importdata(strcat(inputDir,fileStr,"_",num2str(i),"_",currentMuscle{1},"afferents-104-0.dat"));
                
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
                
                %poolIa(:,(j-2)*6+1)=myInputFile(:,IaCol);
                %poolII(:,(j-2)*6+1)=myInputFile(:,IICol);
                
                fclose("all");
            end
        end
    elseif trialN==4 && (ptN==1 || ptN==2)
        if ptN==1
            nFiles=17;
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
        
        sizeA=size(activeMuscles);
        
        % myV rows, myC cols
        statsIa=zeros(nFiles,(sizeA(2)-1)*4); % *4 for avg, min, max, std -1 for 'time'
        statsII=zeros(nFiles,(sizeA(2)-1)*4);
        
        poolIa=zeros(10000000,(sizeA(2)-1)*6);
        % *6 for Ia pool, II pool, Ia avg, Ia stddev, II avg, II stdev -1 for 'time'
        % really large n Rows to hopefully surpass the number of rows
        % of all .dat files ( as opposed to opening every file just to
        % get nRows, summing all nRows, and initializing poolIa with
        % that sum nRows
        poolII=zeros(10000000,(sizeA(2)-1)*6);
        poolIaCounter=1; % counter to know which rows in poolIa,II are actual
        % data, not zeros created in making poolIa,II
        poolIICounter=1;
        
        IaCol=3;
        IICol=4;
        
        % take max min avg stdev of each file , save in array
        for i=1:nFiles
            for j=1:sizeA(2)
                if(j==1) % time
                    continue
                end
                currentMuscle=activeMuscles(j);
                %if(i==4 && currentMuscle{1}=="FCU")
                %    "hi"
                %end
                tooHighOrLow=false;
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
                    break;
                end
                myInputFile=importdata(strcat(inputDir,fileStr,"_",num2str(i),"_",currentMuscle{1},"afferents-104-0.dat"));
                
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
                
                poolIa(poolIaCounter:(poolIaCounter+size(myInputFile,1)-1),(j-2)*6+1)=myInputFile(:,IaCol);
                poolII(poolIICounter:(poolIICounter+size(myInputFile,1)-1),(j-2)*6+1)=myInputFile(:,IICol);
                poolIaCounter=poolIaCounter+size(myInputFile,1);
                poolIICounter=poolIICounter+size(myInputFile,1);
                
                fclose("all");
            end
        end
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
                myInputFile=importdata(strcat(inputDir,fileStr,"_",num2str(i),"_",currentMuscle{1},"afferents-104-0.dat"));
                
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
        for i=1:nFiles
            for j=1:sizeA(2)
                if(j==1) % time
                    continue
                    %elseif(trialOther=="mod4_bs_SimulationResults_bs_Wrist" && j==7)
                    %    % for mod4_bs_SimulationResults_bs_Wrist, myV myC in these conditions were often Killed
                    %    % pyNEST so afferent file invalid so don't put in stats
                    %    continue
                end
                currentMuscle=activeMuscles(j);
                a=strcat(inputDir,num2str(i),"_",currentMuscle{1},"afferents-104-0.dat")
                
                if((trialOther=="mod4_bs_4_articleResults" && currentMuscle{1}=="ECRB" && i>111 && i<500) ...
                        || (trialOther=="mod4_bs_SimulationResults_bs_Elbow" && currentMuscle{1}=="ECRB" && i==115) ...
                        || (trialOther=="mod4_bs_SimulationResults_bs_Shoulder" && currentMuscle{1}=="ECRB" && i==115) ...
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
                    myInputFile=importdata(strcat(inputDir,num2str(i),"_",currentMuscle{1},"afferents-104-0.dat"));
                    
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
    
    % in order to get confidence interval (for given trial for given
    % movement for curr muscles) across all nFiles
    % take avgs, stddev
    if(justStddev)
        "movement "+movement+" trial "+num2str(trialN)+" ptN "+num2str(ptN)+" muscle "+currentMuscle{1}
        givenTrialGivenMovementAllnFilesAvgIa=sum(poolIa(1,poolIaCounter))/poolIaCounter
    end
    
    %save("C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLmod4wrist_statsIa","statsIa");
    %save("C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLmod4wrist_statsII","statsII");
    % yes, even though it is output, it is going in inputDir
    %save(strcat(inputDir,fileStr,"_statsIa.mat"),"statsIa");
    %save(strcat(inputDir,fileStr,"_statsII.mat"),"statsII");
    "hi"
end

load handel
sound(y,Fs)
