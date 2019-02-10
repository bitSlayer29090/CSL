% setup
% for each channel in trial
%   34th order high pass filter
%   FIR highpass filter example <https://www.mathworks.com/help/signal/ref/fir1.html#bulla96>
%   rectify
%   linear envelope ( as MoBL does as evident from EMG data, although it doesnt mention linear env in article; see below 'MoBL 'filtered ... ')
%   normalize to MVC max absolute value away from 0
% end
% show graphs if desired
% dilate so my trial's average roughly equals literature's EMG file's average
% print all channels to single OS formatted .sto file
% perform Forward Dynamics
% process muscle lengths into separate files
% report time

% MoBL 'filtered with 39th order Hamming-window linear phase high pass filter (0.2Hz cutoff frequency),
% rectified, and normalized to the recorded maximum voluntary contraction (MVC) for each
% muscle'

% (find 'user changes')
% user changes timing, showGraphs, trialN, dilN, secToBeWritten, osimDir
% (containing setup .xml, model .osim), myDir (contains .sto, lengths
% files) //typically not resultsDir, controlsFilename, finalTime
% >> take out make EDC
% note EDC is currently copy of ECU
%% setup

close all
clearvars

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
% trial4
% channel3 = EDC ; channelN = 1
% channel4 = ECRB ; channelN = 2
% channel7 = FCU ; channelN = 3
% channel8 = FCR ; channelN = 4
% trial5
%>> take pic
% trial5 pt 1-12 ; section 4-18, excluding section 7,12,15, thus
% pt1 section4
% pt2 section5
% pt3 section6
% pt4 section8
% pt5 section9
% pt6 section10
% pt7 section11
% pt8 section13
% pt9 section14
% pt10 section16
% pt11 section17
% pt12 section18

timing = false;
showGraphs = true;

trialN=5;
ptN=1; % means trial4 part1,2 (sectionN=12,13), trial5 pt 1-12 (section 4-18,
% excluding section 7,12,15
trialOther="";
% trialOther="MoBLmod4wrist" uses nFile count from compareResults
moreMoBL=false;
if moreMoBL
    splitIncrement=10; % ms
    if trialOther=="mod2_bs_allpassivemuscles_bs_2_shoulder"
        filenameStr="MoBL_ARMS_module2_4_allmuscles_states_degrees.mot";
        nFiles=138;
    elseif trialOther=="mod4_bs_4_articleResults"
        filenameStr="MoBL_ARMS_module2_4_allmuscles_wrist_states_degrees.mot";
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Elbow"
        filenameStr="MoBL_ARMS_module2_4_allmuscles_elbow_states_degrees.mot";
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Shoulder"
        filenameStr="MoBL_ARMS_module2_4_allmuscles_shoulder_states_degrees.mot";
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Wrist"
        filenameStr="MoBL_ARMS_module2_4_allmuscles_wrist_states_degrees.mot";
        nFiles=651;
    elseif trialOther=="mod6_bs_SimulationResults"
        filenameStr="CMC_Reach8_controls_states.sto";
        nFiles=433;
    elseif trialOther=="mod7_bs_7_results"
        filenameStr="FDS_states_degrees.mot";
        nFiles=138;
    end
    toSplitFilename=strcat("C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\moreMoBL\collect_states_deg_bs_ModelFiles\",trialOther,"\incrementalFDoutputDir\",filenameStr);
    splitOutputDir=strcat("C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\moreMoBL\collect_states_deg_bs_ModelFiles\",trialOther,"\incrementalFDoutputDir\splitTo",num2str(splitIncrement),"msIncrements\");
end

% certainlyMax1 previous meaning = normalized data's max is certainly 1 , since normalized ; no dilation
% certainlyMax1 current meaning = after MoBL email and after checking and controlling max, which
% should usually be 1
certainlyMax1= true;
% not 'do lin env' but 'is it lin env' , aka, making false will just cause
% errors
linEnv=true; % changing this wont change that doProcessEMG performs linEnv; must change EMGprocessingPolymorphic for that
% RMS lin env
winsize=1000;
wininc=1;
removeMuscleChnN=0;
dilN = 0; % dilation number
% dilN 4 = avg MoBL mean
% dilN 5 = avg MOtoNMS mean
noMVC=true;
movement=-1;
if(noMVC)
    movement="ext"; %"ext","fle","uln","rad"
end
%splitInto100msIncrements=true; % into splitFiles.m

% also change dilN, make folder with fileStr and 'incrementalFDoutputDir' so
% forth folders inside, change MoBL modelFilename,
% check fileStr, incrementalControlsFilesDir
doProcessEMG=true;
if(noMVC && trialN==5)
    doGetMVC=true;
end
doDilate=false;
doMakeEDC = false;
if(doDilate) % EMG must be processed to have data to dilate, but doDilate = true or false still user choice  z
    doProcessEMG= true;
    doMakeEDC = false;
end
if(trialN==3.1 && doProcessEMG) % 3.1 dependent on doMakeEDC
    doMakeEDC=true;
end
doWriteIncrementalControlsFiles=false;
doIncrementalFD=false;
doSplit=false;
doIncrementalProcessLengths=false;

%testing
%{
switch1=false;
if(switch1)
    doProcessEMG=true;
    doWriteIncrementalControlsFiles=true;
    doIncrementalFD=false;
else
    doProcessEMG=false;
    doWriteIncrementalControlsFiles=false;
    doIncrementalFD=true;
end

if(not(doProcessEMG))
    doDilate=false;
end
%}

%{
doProcessEMG=false;
doDilate=false;
doMakeEDC = false;
if(doProcessEMG) % EMG must be processed to have data to dilate, but doDilate = true or false still user choice  z
    doDilate= false;
    doMakeEDC = false;
end
doWriteIncrementalControlsFiles=false;
doIncrementalFD=false;
doIncrementalProcessLengths=true;
%}

%if(timing)
%    % start timer for entire program, including displaying graphs if(showGraphs)
%    tic;
%vend

set(0,'DefaultFigureVisible','off');

% path of dependencies
addpath('C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\')
%homeDir="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\";
% data path
homeDir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\";

% z

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
if(doProcessEMG)
    [totalData] = EMGprocessingPolymorphic(trialN, showGraphs, badPart,ptN,winsize,wininc,noMVC,movement,doGetMVC);
end
%% make EDC
% trial 3, ECU = channel 1
%totalData(:,4) = totalData(:,1);
% trial 3.1, ECU = channel 1
% channel8 = 'ECR' > ECRB,EDC ; channelN = 3
if(doMakeEDC && (doDilate || doWriteIncrementalControlsFiles))
    % note that '&& (doDilate || doWriteIncrementalControlsFiles)' is necessary
    % but if trial3.1 or any other trials further manipulated by columns after
    % processEMG is used after the above line, obv the columns wont have been
    % manipulated unless doDilate || doWriteIncrementalControlsFiles
    if trialN==3.1
        totalData = totalData(:,2:3);
        totalData(:,3) = totalData(:,2);
    elseif trialN==3
        totalData(:,4) = totalData(:,3);
    end
end
%save("C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\mats\linEnvWinsize1000\trial"+num2str(trialN)+"_dilN0_pt"+num2str(ptN)+".mat","totalData");
%% dilate
clearvars -except totalData trialN showGraphs timing doProcessEMG doDilate ...
    doWriteIncrementalControlsFiles doIncrementalFD homeDir ...
    doIncrementalProcessLengths doMakeEDC ptN badPart certainlyMax1 linEnv...
    removeMuscleChnN winsize wininc dilN noMVC trialOther doSplit ...
    toSplitFilename splitOutputDir splitIncrement nFiles moreMoBL movement

%if(certainlyMax1 && not(dilN==0))
%    error("certainlyMax1 but dilN not 0");
%end

% MoBLmod4model = MoBL ARMS module 4 model (MoBL_ARMS_module2_4_allmuscles.osim)
% wristModel = comes with OpenSim 3.3 > Models > WristModel (wristModel.osim)
myModel="MoBLmod4model";

myModelVariant="MoBL_ARMS_module6_7_allmuscles_trial4revisedCoords_lockedExceptWristFlexionDeviation_clampedWristFlexionDeviation";
%"trial4revisedCoords_lockedExceptWristFlexionDeviation_clampedWristFlexionDeviation";
%"wrist_noCoords_noConstraints";
%"coordsMoBLconstraintElbow_lockedElv_angleShoulder_elv_clampedUnlocked";
%"trial3.1revisedCoords_lockedExceptWristFlexionDeviation"

if(myModel=="MoBLmod4model" && certainlyMax1 && linEnv)
    if(~noMVC)
        fileStr=strcat(homeDir,myModel,"\certainlyMax1dilN0\linEnv\winsize",...
            num2str(winsize),"\trial",num2str(trialN),"pt",num2str(ptN),...        %"\MoBLmod6_7model
            "\dilN",num2str(dilN),"\noChn",num2str(removeMuscleChnN),...
            "\trial",num2str(trialN),"_dilN",num2str(dilN),"_pt",num2str(ptN),"\");%,"\normalizeToPoint5\"); %myModelVariant,"\");
    else
        fileStr=strcat(homeDir,myModel,"\certainlyMax1dilN0\linEnv\winsize",...
            num2str(winsize),"\trial",num2str(trialN),"pt",num2str(ptN),...        %"\MoBLmod6_7model
            "\dilN",num2str(dilN),"\noChn",num2str(removeMuscleChnN),"\noMVC\trial",...
            num2str(trialN),"_dilN",num2str(dilN),"_pt",num2str(ptN),"\",movement,"\");%,"\normalizeToPoint5\"); %myModelVariant,"\");
    end
    % shouldnt be doing anything but certainlyMax1 so let throw error about
    % fileStr DNE if else
    
else
    error("should be certainlyMax1");
end
disp(["fileStr "])
disp([fileStr])
% breakpoint

if(doDilate)
    [dilatedD] = dilate(trialN, ptN, dilN, totalData);
    totalData=dilatedD;
end

figureCounter=50;
if(doProcessEMG)
    for l=1:size(totalData,2)
        dataMean=mean(totalData(:,l));
        disp(["dataMax should be 1 for each column, since normalized to MVC, unless futher dilating to MoBL or MOtoNMS; also dataMax shouldnt be 1 if noMVC since max (1) should occur in MVC, and noMVC doesn't include MVC"])
        % disp used for displaying data with no "ans = "
        dataMax=max(totalData(:,l))
        disp([dataMax])
        dataMin=min(totalData(:,l));
        dataStd=std(totalData(:,l));
    end
    figure(figureCounter);
    figureCounter=figureCounter+1;
    tdSize=size(totalData(:,l));
    totalDataCompensateForWininc=totalData(1:wininc:tdSize(1),:);
    plot(totalDataCompensateForWininc);
    %title("All Muscle Signals After sEMG Processing"); % scif png title
    title("data before writeIncrementalControlsFiles");
    xlabel("milliseconds/window increment (ms)");% "ms / wininc ; winsize typically 1");
    ylabel("Signal voltage/MVC maximum voltage (unitless)");
    
    %{
    if(removeMuscleChnN==1)
        if(trialN==4 && ptN==2)
            totalData=totalData(:,2:4);
        elseif(trialN==3.1)
            totalData=totalData(:,2:3);
        end
        disp(["channel 1 removed"])
    elseif(removeMuscleChnN==2)
        if(trialN==4 && ptN==2)
            totalData=horzcat(totalData(:,1),totalData(:,3:4));
        elseif(trialN==3.1)
            totalData=horzcat(totalData(:,1),totalData(:,3));
        end
        disp(["channel 2 removed"])
    elseif(removeMuscleChnN==3)
        if(trialN==4 && ptN==2)
            totalData=horzcat(totalData(:,1:2),totalData(:,4));
        elseif(trialN==3.1)
            totalData=totalData(:,1:2);
        end
        disp(["channel 3 removed"])
    elseif(removeMuscleChnN==4)
        if(trialN==4 && ptN==2)
            totalData=totalData(:,1:3);
        elseif(trialN==3.1)
            error("trial3.1 has no chn4 to remove but removeMuscleChnN==4");
        end
        disp(["channel 4 removed"])
    elseif(not(removeMuscleChnN==0))
        error("muscle channel bad")
    else
        disp(["no muscle channels removed"])
    end
    %}
end

%save("trial"+num2str(trialN)+"dilN"+num2str(dilN)+"pt"+num2str(ptN)+".mat", "dilatedD");
%% print OS formatted to file
% user changes seconds to be written to .sto file

if(~noMVC)
    if trialN==3
        secToBeWritten = 303.5;
    elseif trialN==3.1
        secToBeWritten = 303.5;
    elseif trialN==4
        totalBadPart=(badPart(2)+badPart(4))*(1/1000); % convert to s
        if ptN==1
            secToBeWritten=448.638-totalBadPart;
        elseif ptN==2
            secToBeWritten=152-totalBadPart;
        end
    end
else
    %totalData len
    %trialNptN	ext	fle	uln	rad
    %3.1		22002	22002	20002	18002
    %4pt1		31002	21002	21002	26002
    %4pt2		20002	17002	19002	18002
    
    % floor(x/1000)
    %trialNptN	ext	fle	uln	rad
    %3.1		22	22	20	18
    %4pt1		31	21	21	26
    %4pt2		20	17	19	18
    
    % nFiles,leftover
    %trialNptN	ext	fle	uln	rad
    %3.1		2,2	2,2	2,0	1,8
    %4pt1		3,1	2,1	2,1	2,6
    %4pt2		2,0	1,7	1,9	1,8
    
    if trialN==3.1
        if(movement=="ext")
            secToBeWritten=floor(22002/1000); % /1000 convert to ms
        elseif(movement=="fle")
            secToBeWritten=floor(22002/1000);
        elseif(movement=="uln")
            secToBeWritten=floor(20002/1000);
        elseif(movement=="rad")
            secToBeWritten=floor(18002/1000);
        end
    elseif trialN==4
        if ptN==1
            if(movement=="ext")
                secToBeWritten=floor(31002/1000);
            elseif(movement=="fle")
                secToBeWritten=floor(21002/1000);
            elseif(movement=="uln")
                secToBeWritten=floor(21002/1000);
            elseif(movement=="rad")
                secToBeWritten=floor(26002/1000);
            end
        elseif ptN==2
            if(movement=="ext")
                secToBeWritten=floor(20002/1000);
            elseif(movement=="fle")
                secToBeWritten=floor(17002/1000);
            elseif(movement=="uln")
                secToBeWritten=floor(19002/1000);
            elseif(movement=="rad")
                secToBeWritten=floor(18002/1000);
            end
        end
    end
end

%directory to contain controls .sto
% for complete run
incrementalControlsFilesDir = strcat(fileStr,"incrementalControlsFilesDir\");
% for FD testing
%elseif(dilN==3)
%    if(trialN==3.1)
%        incrementalControlsFilesDir = "C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\trial3.1\dilN3\trial3.1_dilN3_pt-1\";
%   elseif(trialN==4 && ptN==1)
%       incrementalControlsFilesDir = "C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\trial4pt1\dilN3\polymorphicTrial4_dilN3\";
%   elseif(trialN==4 && ptN==2)
%       incrementalControlsFilesDir = "C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\trial4pt2\dilN3\trial4_dilN3_pt2\";
%   end
%   incrementalControlsFilesDir=strcat(incrementalControlsFilesDir,"incrementalControlsFilesDir\");S
disp(["incrementalControlsFilesDir "])
disp([incrementalControlsFilesDir])
% breakpoint

%increments of n s
increment = 10;

if(doWriteIncrementalControlsFiles)
    [nFiles, leftover] = writeIncrementalControlsFiles(myModel, trialN, ...
        totalData, secToBeWritten, incrementalControlsFilesDir, increment,...
        removeMuscleChnN);
    % if trial4 pt1, throws below err after writing each incrementalControlFile
    % including leftover
    % 'Index exceeds matrix dimensions.
    %
    %Error in writeIncrementalControlsFiles (line 216)
    %                    fprintf(file, '\t%.9f', a{1,1}(m+1));
    %
    %Error in processEMGtoLengthsPolymorphic (line 232)
    %    [nFiles, leftover] = writeIncrementalControlsFiles(myModel, trialN, ...'
    
end

%% forward dynamics

%{
% user changes
%directory containing model .osim, FD setup .xml
osimDir = "C:\InteruserWorkspace\EMGrelated\MATLABscripts\puttingTogether\osimDir\";
% .xml setup filename
setupFilename = "MATLABforwardDynamicsSetup.xml";
% .osim model filename
modelFilename = strcat(myModel,"s\",myModelVariant,".osim");
disp(["modelFilename "])
disp([modelFilename])
%}

osimDir="C:\InteruserWorkspace\MoBL_ARMS_OpenSim33tutorial\MoBL_ARMS_tutorial_33\MoBL-ARMS OpenSim tutorial_33\ModelFiles\";
setupFilename="-1";
setupPath="C:\InteruserWorkspace\EMGrelated\MATLABscripts\puttingTogether\osimDir\MATLABforwardDynamicsSetup.xml";
modelFilename="MoBL_ARMS_module6_7_CMC - Copy_usedForWrist_trial4revisedCoords_lockedExceptWristFleDev_clampedFleDev.osim";

% FD lengths output dir
FDoutputDir = strcat(fileStr,"incrementalFDoutputDir\");
disp(["FDoutputDir "])
disp([FDoutputDir])
% breakpoint

% since MoBLmod2_4model and 6_7 take same controls files
%incrementalControlsFilesDir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize1000\trial4pt2\MoBLmod2_4model\dilN0\noChn0\trial4_dilN0_pt2\incrementalControlsFilesDir\";

if(~doWriteIncrementalControlsFiles && ~moreMoBL)
    if(~noMVC) % nFiles includes leftover file
        if(trialN==3.1)
            %nFiles=31;
            nFiles=16;
            leftover=3.5;
        elseif(trialN==4)
            if(ptN==1)
                nFiles=43;
                leftover=1;
            else
                nFiles=12;
                leftover=10;
            end
        end
    else
        % nFiles includes +1 for leftover (obv unless leftover=0)
        % nFiles,leftover
        %trialNptN	ext	fle	uln	rad
        %3.1		2,2	2,2	2,0	1,8
        %4pt1		3,1	2,1	2,1	2,6
        %4pt2		2,0	1,7	1,9	1,8
        
        if trialN==3.1
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
        elseif trialN==4
            if ptN==1
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
            elseif ptN==2
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
    end
    if(trialOther=="MoBLmod4wrist") % using compareResults and my produced states_degrees using given controls wrist EMG, split into 100 ms sections
        nFiles=65;
    end
end

if(doIncrementalFD)
    incrementalFD(trialN, secToBeWritten, nFiles, osimDir, FDoutputDir, ...
        setupFilename, setupPath, modelFilename, leftover, incrementalControlsFilesDir,...
        increment);
end
%% split if necessary

if(doSplit)
    [nFiles]=splitFiles(toSplitFilename,splitOutputDir, splitIncrement, moreMoBL)
end

%% process lengths

processLengthsInputDir = strcat(fileStr,"incrementalFDoutputDir\"); % FD output
processLengthsOutputDir = strcat(fileStr,"incrementalProcessLengthsDir\");

% for MoBL wrist
%fileStr="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLcompareResultsMod4wrist\";
%processLengthsInputDir = strcat(fileStr,"incrementalFDoutputDir\increments100ms\"); % FD output
%processLengthsOutputDir = strcat(fileStr,"incrementalProcessLengthsDir\");

% for MoBLmod6_7 osim used trial4pt2 and others
%processLengthsInputDir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize5000\trial3.1pt-1\dilN0\noChn0\trial3.1_dilN0_pt-1\incrementalFDoutputDir\";
%processLengthsOutputDir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize5000\trial3.1pt-1\dilN0\noChn0\trial3.1_dilN0_pt-1\incrementalProcessLengthsDir\";

if(moreMoBL)
    processLengthsInputDir=splitOutputDir;
    processLengthsOutputDir=strcat("C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\moreMoBL\collect_states_deg_bs_ModelFiles\",trialOther,"\incrementalProcessLengthsDir\");
end

if(doIncrementalProcessLengths)
    incrementalProcessLengths(processLengthsInputDir, processLengthsOutputDir,...
        trialN, ptN, trialOther, nFiles, moreMoBL);
end

%load handel
%sound(y,Fs)