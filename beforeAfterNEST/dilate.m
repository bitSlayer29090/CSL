function [dilatedD] = dilate(trialN, ptN, dilN, totalData)
% dilate

% no dilation
ECRdil0 = 1;
ECUdil0 = 1;
FCRdil0 = 1;
EDCdil0 = 1;

% attempt to reproduce dilation 1 ; based on controls_EMG_wrist.sto
ECRdil = 5.5;
ECUdil = 5.5;
FCRdil = 5.5;
EDCdil = 5.5; %10; %55;

% decreased dilation so OS can proceed
ECRdil2 = 2;
ECUdil2 = 2;
FCRdil2 = 2;
EDCdil2 = 2; %4;

% dilation to match MoBL mod4 wrist .sto magnitude
ECRdil3 = 1.15;
ECUdil3 = 1.15;
FCRdil3 = 1.15;
EDCdil3 = 1.15;

% based on rawProcessedEMG_MoBLMOtoNMSmine_compare google sheet
% dilN4
% dilate for trialN to match avg_MoBL_mean
if(dilN==4)
    if(trialN==3.1 && ptN==-1)
        dil4=0.1975;
    elseif(trialN==3.1)
        error("ptN of trial3.1 should be -1");
    elseif(trialN==4 && ptN==1)
        dil4=0.27599;
    elseif(trialN==4 && ptN==2)
        dil4=0.18594;
    elseif(trialN==4)
        error("ptN of trial4 should be 1 or 2");
    end
    % dilN5
    % dilate for trialN to match avg_MOtoNMS_mean
elseif(dilN==5)
    if(trialN==3.1 && ptN==-1)
        dil5=0.0000599;
    elseif(trialN==3.1)
        error("ptN of trial3.1 should be -1");
    elseif(trialN==4 && ptN==1)
        dil5=0.0000838;
    elseif(trialN==4 && ptN==2)
        dil5=0.0000564;
    elseif(trialN==4)
        error("ptN of trial4 should be 1 or 2");
    end
end

%{
% old dil before certainlyMax1
% if trial3.1, ECRB uses var 'currentECRdil'
if dilN==0
    currentECRdil = ECRdil0;
    currentFCRdil = FCRdil0;
    currentECUdil = ECUdil0;
    currentEDCdil = EDCdil0;
elseif dilN==1
    currentECRdil = ECRdil;
    currentFCRdil = FCRdil;
    currentECUdil = ECUdil;
    currentEDCdil = EDCdil;
elseif dilN==2
    currentECRdil = ECRdil2;
    currentFCRdil = FCRdil2;
    currentECUdil = ECUdil2;
    currentEDCdil = EDCdil2;
elseif dilN==3
    currentECRdil = ECRdil3;
    currentFCRdil = FCRdil3;
    currentECUdil = ECUdil3;
    currentEDCdil = EDCdil3;
else
    disp("Invalid dilation number")
    % sets current dils to dil 1 so compiles
    currentECRdil = ECRdil;
    currentFCRdil = FCRdil;
    currentECUdil = ECUdil;
    currentEDCdil = EDCdil;
end

sizeTotal = size(totalData);

dilatedD = totalData;
currentChannel = 1;
%if(timing)
%    toc % toc3 = start dilate
%end

switch trialN
    case 1
        % ECR
        for j=1:sizeTotal(1,1) % for each ms
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentECRdil;
        end
        currentChannel= currentChannel+1;
    case 2
        % ECR, FCR, ECU
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentECRdil;
        end
        currentChannel= currentChannel+1;
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentFCRdil;
        end
        currentChannel= currentChannel+1;
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentECUdil;
        end
        currentChannel= currentChannel+1;
    case 3
        % ECU, FCR, ECR % and pretend EDC
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentECUdil;
        end
        currentChannel= currentChannel+1;
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentFCRdil;
        end
        currentChannel= currentChannel+1;
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentECRdil;
        end
        currentChannel= currentChannel+1;
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentEDCdil;
        end
        currentChannel= currentChannel+1;
    case 3.1
        % FCR, ECRB, EDC
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentFCRdil;
        end
        currentChannel= currentChannel+1;
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentECRdil;
        end
        currentChannel= currentChannel+1;
        for j=1:sizeTotal(1,1)
            dilatedD(j,currentChannel)=totalData(j,currentChannel)*currentEDCdil;
        end
        currentChannel= currentChannel+1;
    otherwise
end
%if(timing)
%    toc % toc4 = end dilate
%end

% save files for use in making DrJones tuning curves with myData
%save('withMoBLDilation', 'dilatedD');
%}

% new dil after certainlyMax1
if(dilN==4)
    dilatedD=totalData*dil4;
elseif(dilN==5)
    dilatedD=totalData*dil5;
end
end
