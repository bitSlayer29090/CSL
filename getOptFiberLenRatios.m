% get muscleLen/optFiberLen over t

clear all
% import trialN ptN from main processEMGtoLengths
trialOther="mod2_bs_allpassivemuscles_bs_2_shoulder"; %"MoBLmod4wrist";
%moreMoBL=true; % things related to moreMoBL commented out since only 
% started to modify file to work with moreMoBL (didnt modify anything other
% than top part)
trialN=-1;

%if(trialOther=="MoBLmod4wrist" && ~moreMoBL)
inputDir="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLcompareResultsMod4wrist\incrementalProcessLengthsDir\";
outputDir="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLcompareResultsMod4wrist\incrementalProcessLengthsDir\lenToOptFiberLenRatios\";
%elseif(moreMoBL) %&& doSplit )
%    longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\moreMoBL\collect_states_deg_bs_ModelFiles\";
%    inputDir=strcat(longDir,trialOther,"\incrementalFDoutputDir\splitTo10msIncrements\");
%end

if trialN == 3.1
    activeMuscles = {'time', 'FCR', 'ECRB', 'EDCM'};
elseif trialN == 4
    activeMuscles = {'time', 'EDCM', 'ECRB', 'FCU', 'FCR'};
end
if trialOther=="MoBLmod4wrist"
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
    fileStr="MoBLmod4wrist";
    nFiles=65;
else
    fileStr=strcat("trial", num2str(trialN), "pt",num2str(ptN));
    nFiles=-1;
end
%{
if(moreMoBL)
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
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
    fileStr=trialOther;
end
%}
muscleNames = {'time','DELT1','DELT2','DELT3','SUPSP','INFSP','SUBSC',...%7
    'TMIN','TMAJ','PECM1','PECM2','PECM3','LAT1','LAT2','LAT3','CORB',...%16
    'TRIlong','TRIlat','TRImed','ANC','SUP','BIClong','BICshort','BRA',...%24
    'BRD','ECRL','ECRB','ECU','FCR','FCU','PL','PT','PQ','FDSL','FDSR',...%35
    'FDSM','FDSI','FDPL','FDPR','FDPM','FDPI','EDCL','EDCR','EDCM','EDCI',...%45
    'EDM','EIP','EPL','EPB','FPL','APL'};

%muscleCols = {1, 43, 45, 47, 49, 51,53,55,57,59,61,63,65,67,69,71,73,75,...
%77,79,81,83,85,87,89,91,93,95,97,99,101,103,105,107,109,111,113,115,...
%117,119,121,123,125,127,129,131,133,135,137,139,141};

%26 'ECRL', 27'ECRB', 28'ECU', 29'FCR', 30'FCU', 44'EDCM'};
optFiberLengths={-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,...
    -1,-1,-1,-1,-1,-1,0.081,0.0585,0.0622,0.0628,0.0509,-1,-1,-1,-1,-1,-1,...
    -1,-1,-1,-1,-1,-1,-1,0.0724,-1,-1,-1,-1,-1,-1,-1};

% startNum = 42;
muscleMap = containers.Map(muscleNames, optFiberLengths);

sizeA=size(activeMuscles);

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

% myV rows, myC cols
stats=zeros(nFiles,(sizeA(2)-1)*4); % *4 for avg, min, max, std -1 for time

%[statsFile,message]=fopen(strcat(outputDir,"stats.txt"),'w');
%message
%s=strcat(outputDir,"stats.txt");
%statsFile=fopen(s,'w');
%if statsFile==-1
%  error('Cannot open file for writing');
%end

% for myV , for myC , div each by optFiberLen, write ; also take avg std max min
for i=1:nFiles
    for j=1:sizeA(2)
        if(not(activeMuscles(j)=="time"))
            myFilename=strcat(outputDir,fileStr,"_",num2str(i),"_",activeMuscles(j),"lenToOptFiberLenRatio.txt");
            inputFilename=strcat(inputDir,fileStr,"_",num2str(i),"_",activeMuscles(j),"lengths.mot");
            inputFile=importdata(inputFilename);
            
            myFile=fopen(myFilename,'w');
            sizeF=size(inputFile);
            a=activeMuscles(j);
            for k=1:sizeF(1)
                myRatio=inputFile(k,1)/muscleMap(a{1,1}); % current fiber len/opt fiber len
                fprintf(myFile,'%.9f\n',myRatio);
            end
            % store stats
            myTotalRatio=inputFile/muscleMap(a{1,1});
            %myTotalRatio=[1,2,3,4];
            myMax=max(myTotalRatio); %4
            myMin=min(myTotalRatio); %1
            myAvg=mean(myTotalRatio); %2.5
            myStdev=std(myTotalRatio);
            stats(i,(j-2)*4+1)=myMax;
            stats(i,(j-2)*4+1+1)=myMin;
            stats(i,(j-2)*4+1+1+1)=myAvg;
            stats(i,(j-2)*4+1+1+1+1)=myStdev;
        end
        fclose("all");
    end
end
stats(66,:)=mean(stats,1);