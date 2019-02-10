function [totalData] = EMGprocessingPolymorphic(trialN, showGraphs, badPart,ptN,winsize,wininc,noMVC,movement,doGetMVC)
% EMG processing =
%   34th order high pass filter
%   FIR highpass filter example <https://www.mathworks.com/help/signal/ref/fir1.html#bulla96>
%   rectify
%   linear envelope
%   normalize to MVC max absolute value away from 0

% trial1 = section 2
% trial2 = section 3
% trial3 = section 8
% trial1 'C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial1\ECR_trial1_10excitation_atEnd1MVC_electrodesCopyToOperateOn.mat'
% trial2 'C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial2\trial2_electrodes2.mat'
% trial3 'C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial3\trial3_2.mat'
%4 ('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial4\trial4_onlyActiveChannels.mat');
%5 C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial5\trial5lowPassFiltered_toUseWithMATLAB.mat

if trialN == 1
    sectionN = 2;
    load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial1\ECR_trial1_10excitation_atEnd1MVC_electrodesCopyToOperateOn.mat');
    %outputDir = 'C:\InteruserWorkspace\EMGrelated\MATLABscripts\trial1\';
elseif trialN == 2
    sectionN = 3;
    load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial2\trial2_electrodes2.mat');
    %outputDir = 'C:\InteruserWorkspace\EMGrelated\MATLABscripts\trial2\';
elseif trialN == 3.1
    sectionN = 8;
    load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial3\trial3_2.mat');
    %outputDir = 'C:\InteruserWorkspace\EMGrelated\MATLABscripts\trial3\';
elseif trialN == 4
    % note trial 4 all channels got digital filter 50 Hz low pass from
    % labchart before going into labchart produced .mat
    if(ptN==1)
        sectionN = 12;
    elseif(ptN==2)
        sectionN=13;
    end
    load('C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial4\trial4_onlyActiveChannels.mat');
elseif trialN==5
    load("C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial5\trial5lowPassFiltered_toUseWithMATLAB.mat");
    load(chnMVCmovement.mat");
end
if(noMVC)
    if(trialN==3.1 && ptN==-1)
        noMVCdir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize1000\trial3.1pt-1\dilN0\noChn0\noMVC\trial3.1_dilN0_pt-1\";
    elseif(trialN==4)
        if(ptN==1)
            noMVCdir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize1000\trial4pt1\dilN0\noChn0\noMVC\trial4_dilN0_pt1\";
        elseif(ptN==2)
            noMVCdir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize1000\trial4pt2\dilN0\noChn0\noMVC\trial4_dilN0_pt2\";
        end
    end
    load(strcat(noMVCdir,movement,"\trial",num2str(trialN),"pt",num2str(ptN),"_noMVC_",movement,".mat"));
end

% if(noMVC && trialN==5 && doGetMVC)
%     getMVC(trialN,ptN,movement)
% end

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
% channel = EDC ; channelN =
% channel = ECRB ; channelN =
% channel = FCU ; channelN =
% channel = FCR ; channelN =

%clearvars -except actualData channelN sectionN trialN datastart dataend;
%clear blocktimes com comtext firstsampleoffset rangemax rangemin samplerate tickrate unittext unittextmap

%if(timing)
%    toc % toc1 = start processEMG
%end

%outhiAbsA = zeros(sizeA(1,1),313700); % to get all outhiAbs (no normalize) into separate .mat

% trial 3.1, discard first channel
if trialN == 3.1
    startChannel=2;
else
    startChannel=1;
end
if(noMVC) % noMVC sections already exclude badPart
    if(trialN==3.1 && ptN==-1)
        currentMovementArray(:,3)=currentMovementArray(:,2);
        currentMovementArray(:,2)=currentMovementArray(:,1);
        currentMovementArray(:,1)=zeros(size(currentMovementArray,1),1);
    end
    badPart=[0,0,0,0];
    nChannels=size(currentMovementArray,2);
else
    nChannels = size(titles,1);   % n channels
end
if(~noMVC)
    if(not(badPart(1)) && not(badPart(3))) % no bad parts
        totalData = zeros((dataend(1, sectionN) - datastart(1, sectionN) + 1) - (winsize -1), nChannels);
    elseif(not(badPart(3)) && badPart(1)) % bad start
        totalData = zeros((dataend(1, sectionN) - badPart(2) - datastart(1, sectionN) + 1) - (winsize -1), nChannels);
    elseif(not(badPart(1)) && badPart(3)) %  bad end
        totalData = zeros((dataend(1, sectionN) - badPart(4) - datastart(1, sectionN) + 1) - (winsize -1), nChannels);
    elseif(badPart(1) && badPart(3)) % bad start and bad end
        totalData = zeros((dataend(1, sectionN) - badPart(2) - badPart(4) - datastart(1, sectionN) + 1) - (winsize -1), nChannels);
    end
end

figureCounter = 1;
%for channelN=1:nChannels(1,1)

for channelN=startChannel:nChannels
    if(~noMVC)
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
    else
        actualData=currentMovementArray(:,channelN);
    end
    %% high pass filter
    % <https://www.mathworks.com/help/signal/ref/fir1.html#bulla96>
    %Fs = sample rate
    %Nyguist freq = sample rate/2 = 1000/2 = 500
    %Fs/4 = Nyquist freq/2
    %Fs = 2*Nyquist freq = 2*500 = 1000
    %sample rate = 1000
    
    Fs = 1000;
    t = (0:length(actualData)-1)/Fs;
    %take out 'chebwin' because I want a Hamming filter, not Chebyshev window
    %cutoff freq = 0.10
    bhi = fir1(34,0.10,'high'); %%34th order, 0.10 cutoff freq (Hz ? ), highpass
    
    %figure(figureCounter);
    %h(figureCounter) = figure;
    %figureCounter = figureCounter+1;
    f = freqz(bhi,1);
    outhi = filter(bhi,1,actualData);
    
    figure(figureCounter);
    %h(figureCounter) = figure;
    figureCounter = figureCounter+1;
    subplot(2,1,1);
    plot(t,actualData);
    title('Original/Raw');
    ys = ylim;
    subplot(2,1,2);
    plot(t,outhi);
    title('Highpass Filtered');
    xlabel('Time (s)');
    ylabel('Voltage (V)');
    %ylim(ys);
    %% rectify
    outhiAbs = abs(outhi);
    figure(figureCounter);
    figureCounter = figureCounter+1;
    plot(outhiAbs)
    title("Rectified");
    xlabel('Time (ms)');
    ylabel('Voltage (V)');
    %outhiAbsA(channelN,:)=outhiAbs; % to get all outhiAbs (no normalize)
    %into separate .mat
    %% linear envelope
    if(~noMVC)
        outhiAbs=transpose(outhiAbs);
    end
    [RMSlinEnv,figureCounter]=websiteRMSlinEnv(outhiAbs, winsize, wininc,figureCounter);
    if(channelN==startChannel)
        totalData=zeros(size(RMSlinEnv,1),nChannels);
    end
    %% normalize to MVC max
    % RMSlinEnv (= filtered, rectified, linear env EMG)
    % outhiAbs max (including abs(max neg) due to
    % rectifying) is 8.0709*10^-4 (idk if also true for RMSlinEnv)
    % outhiAbs max corresponds to labchart reader max neg (in MVC)
    % thus max abs value in EMG occurs in MVC
    % set max = 8.0709*10^-4 V = 1
    
    % MVCstart = 30000;
    % MVCend = 38351;
    %MVCmax = max(outhiAbs(MVCstart:MVCend));
    if(~noMVC)
        %% line directly below this comment is the one to use if MVC is included in file ;
        sectionMax = max(RMSlinEnv); % assuming MAX occurs in MVC, thus scanning entire .adicht
        % normalize to .5 instead
        %sectionMax=sectionMax*2;
        % normalize to .25 instead
        %sectionMax=sectionMax*4;
    else
        if(trialN==3.1 && ptN==-1)
            if(channelN==2)
                sectionMax=0.000333320812851069;
            elseif(channelN==3)
                sectionMax=0.0000670335393658964;
            end
        elseif(trialN==4)
            if(ptN==1)
                if(channelN==1)
                    sectionMax=0.0000106285901616837;
                elseif(channelN==2)
                    sectionMax=0.0000479451643972325;
                elseif(channelN==3)
                    sectionMax=0.0000593174561156328;
                elseif(channelN==4)
                    sectionMax=0.0000904984400830522;
                end
            elseif(ptN==2)
                if(channelN==1)
                    sectionMax=0.00000603190657956234;
                elseif(channelN==2)
                    sectionMax=0.0000329986315994505;
                elseif(channelN==3)
                    sectionMax=0.0000397071787937732;
                elseif(channelN==4)
                    sectionMax=0.0000635445168984170;
                end
            end
        elseif(trialN==5)
            if(ptN==1)
            elseif(ptN==2)
            elseif(ptN==3)
            elseif(ptN==4)
            elseif(ptN==5)
            elseif(ptN==6)
            elseif(ptN==7)
            elseif(ptN==8)
            elseif(ptN==9)
            elseif(ptN==10)
            elseif(ptN==11)
            elseif(ptN==12)
            end
        end
    end
    
    % outhiAbs[i] = (x)(MVCmax)
    % x = MVCmax/outhiAbs[i]
    normalData = RMSlinEnv/sectionMax;
    
    figure(figureCounter);
    %h(figureCounter) = figure;
    figureCounter = figureCounter+1;
    plot(normalData);
    title("Normalized");
    xlabel("(milliseconds-(window size-1))/window inc (ms)");% "winsize
    % changes x axis by subtracting (winsize-1) from x axis, while wininc
    % (likely, havent tested) changes x axis by dividing by wininc
    ylabel("Signal voltage/MVC maximum voltage (unitless)");
    %plot(normalData((size(normalData,1)-(winsize-1)),:));
    % dont need to change above plot command to
    % "plot(normalData((size(normalData,1)-(winsize-1))/wininc,:));" since
    % matlab scales automatically
    
    totalData(:,channelN) = normalData(:,1);
end
%if(timing)
%    toc % toc2 = end processEMG
%end

if(showGraphs)
    set(0,'DefaultFigureVisible','on');
    for i=1:figureCounter-1
        figure(i);
    end
end
end
