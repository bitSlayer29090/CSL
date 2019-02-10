% extract noMVC parts from trial3.1 and 4pt1

trialN=4;
ptN=2;
% hand pose
%pose="curled"; % "straight"
if(trialN==3.1 && ptN==-1)
    saveDir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize1000\trial3.1pt-1\dilN0\noChn0\noMVC\trial3.1_dilN0_pt-1\";
elseif(trialN==4)
    if(ptN==1)
        saveDir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize1000\trial4pt1\dilN0\noChn0\noMVC\trial4_dilN0_pt1\";
    elseif(ptN==2)
        saveDir="E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\winsize1000\trial4pt2\dilN0\noChn0\noMVC\trial4_dilN0_pt2\";
    end
end

if trialN == 3.1
    %trial3.1 noMVCparts
    %curled
    %29-52 ext
    %62-85 fle
    %96-117 rad
    %127-146 uln
    %
    %straight starts at 160
    %186-208 ext
    %220-238 fle
    %248-266 rad
    %274-295 uln
    
    % c = curled
    cNoMVCstart=[29,62,96,127];
    cNoMVCend=[52,85,117,146];
    cNoMVCstartSize=size(cNoMVCstart);
    cNoMVCendSize=size(cNoMVCend);
    
    % s = straight
    sNoMVCstart=[186,220,248,274];
    sNoMVCend=[208,238,266,295];
    sNoMVCstartSize=size(sNoMVCstart);
    sNoMVCendSize=size(sNoMVCend);
    
    % curled is main one
    noMVCstart=cNoMVCstart;
    noMVCend=cNoMVCend;
    noMVCstartSize=cNoMVCstartSize;
    noMVCendSize=cNoMVCendSize;
    
    sectionN = 8;
    load("C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial3\trial3_2.mat");
elseif trialN == 4
    if(ptN==1)
        %trial4pt1 noMVCparts
        %curled
        %39-71 ext
        %83-105 fle
        %117-142 rad
        %153-180 uln
        %
        %straight
        %190-198 ext
        %231-255 fle
        %266-294 rad
        %305-335 uln
        
        % c = curled
        cNoMVCstart=[39,83,117,153];
        cNoMVCend=[71,105,142,180];
        
        % s = straight
        sNoMVCstart=[190,231,266,305];
        sNoMVCend=[198,255,353,335];
        
        cNoMVCstartSize=size(cNoMVCstart);
        cNoMVCendSize=size(cNoMVCend);
        
        sNoMVCstartSize=size(sNoMVCstart);
        sNoMVCendSize=size(sNoMVCend);
        
        % curled is main one
        noMVCstart=cNoMVCstart;
        noMVCend=cNoMVCend;
        noMVCstartSize=cNoMVCstartSize;
        noMVCendSize=cNoMVCendSize;
        
        sectionN = 12;
    elseif(ptN==2)
        
        % cs = between curled, straight
        % cutout=0-0:10, 2:20-end
        csNoMVCstart=[23,45,63,83];
        csNoMVCend=[44,63,83,102];
        
        csNoMVCstartSize=size(csNoMVCstart);
        csNoMVCendSize=size(csNoMVCend);
        
        % curled straight is main one
        noMVCstart=csNoMVCstart;
        noMVCend=csNoMVCend;
        noMVCstartSize=csNoMVCstartSize;
        noMVCendSize=csNoMVCendSize;
        
        sectionN=13;
    end
    load("C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial4\trial4_onlyActiveChannels.mat");
end

if(noMVCstartSize(2)~=noMVCendSize(2))
        error("start n should = end n");
end

%{
% extract each part
if trialN==3.1 && ptN==-1
    noMVC3.1=
elseif trialN==4
    if ptN==1
    elseif ptN==2
    end
end
%}

%{
sizeD=size(data);

sizeA = size(titles);

noMVC3point1=zeros(sizeA(1),sizeD(2));

figureCounter=1;
if trialN == 3.1
    startChannel=2;
else
    startChannel=1;
end
for channelN=startChannel:sizeA(1,1)
    actualData = data(datastart(channelN, sectionN):dataend(channelN, sectionN));
    for a=1:cNoMVCstartSize(2) % for each section , plot EMG
    figure(figureCounter);
    figureCounter=figureCounter+1;
    plot(actualData(cNoMVCstart(a)*1000:cNoMVCend(a)*1000)); % *1000 to convert to ms
    title(["channel ",num2str(channelN)," section ",a]);
    end
%{
    for i=1:cNoMVCstartSize
        currData=data[noMVCstart[i],noMVCend[i]];
        figure(figureCounter);
        figureCounter=figureCounter+1;
        plot(currData);
%}
end
%}

% get the largest n rows just for matlab, who can't handle dynamic arrays
sizeA = size(titles);
figureCounter = 1;
nRows=zeros(1,noMVCstartSize(2));
nRowsLen=0;
for channelN=1:1
    tempData=data(datastart(channelN, sectionN):dataend(channelN, sectionN));
    for a=1:noMVCstartSize(2) % for each noMVC section
        tempData1=tempData(noMVCstart(a)*1000:noMVCend(a)*1000); % *1000 to convert to ms
        nRows(1,nRowsLen+1)=size(tempData1,2);
        nRowsLen=nRowsLen+1;
    end
end
%maxNrows=max(nRows);

%for channelN=1:sizeA(1,1)
% trial 3.1, discard first channel
if trialN == 3.1
    startChannel=2;
else
    startChannel=1;
end
segments=cell(1,4);
segments(1,1)={zeros(1,nRows(1))};
segments(1,2)={zeros(1,nRows(2))};
segments(1,3)={zeros(1,nRows(3))};
segments(1,4)={zeros(1,nRows(4))};

totalDataCell=cell(1,4);
totalDataCell(1,1)={zeros(1,nRows(1))};
totalDataCell(1,2)={zeros(1,nRows(2))};
totalDataCell(1,3)={zeros(1,nRows(3))};
totalDataCell(1,4)={zeros(1,nRows(4))};

channelCounter=1;
for channelN=startChannel:sizeA(1,1)
    %    if noMVC==1
    actualDataNoMVC = data(datastart(channelN, sectionN):dataend(channelN, sectionN));
    for a=1:noMVCstartSize(2) % for each noMVC section
        %figure(figureCounter);
        %figureCounter=figureCounter+1;
        %plot(actualDataNoMVC(cNoMVCstart(a)*1000:cNoMVCend(a)*1000))
        %title([" actual data channel ",num2str(channelN)," section ",a]);
        
        segments(channelCounter,a)={actualDataNoMVC(noMVCstart(a)*1000:noMVCend(a)*1000)}; % *1000 to convert to ms
        
        %segmentNcols=segmentNcols+1;
        figure(figureCounter);
        figureCounter=figureCounter+1;
        plot(actualDataNoMVC(noMVCstart(a)*1000:noMVCend(a)*1000))
        title(["channel ",num2str(channelN)," section ",a]);
    end
    channelCounter=channelCounter+1;
    %    end
end

% trial3.1pt-1,trial4pt1,trial4pt2 curled order = ext,fle,rad,uln, thus may name in that order

% get 4 channels at each movement into cols of matrix
extArray=zeros(nRows(1,1),1);
fleArray=zeros(nRows(1,2),1);
ulnArray=zeros(nRows(1,3),1);
radArray=zeros(nRows(1,4),1);

for col=1:4 %(each movement)
    for row=1:size(segments,1) %(each channel)
        if col==1
            temp=segments(row,col);
            extArray(:,row)=temp{1};
        elseif col==2
            temp=segments(row,col);
            fleArray(:,row)=temp{1};
        elseif col==3
            temp=segments(row,col);
            ulnArray(:,row)=temp{1};
        elseif col==4
            temp=segments(row,col);
            radArray(:,row)=temp{1};
        end
    end
end

currentMovementArray=extArray;
save(strcat(saveDir,"ext\trial",num2str(trialN),"pt",num2str(ptN),"_noMVC_ext.mat"),'currentMovementArray');
currentMovementArray=fleArray;
save(strcat(saveDir,"fle\trial",num2str(trialN),"pt",num2str(ptN),"_noMVC_fle.mat"),'currentMovementArray');
currentMovementArray=radArray;
save(strcat(saveDir,"rad\trial",num2str(trialN),"pt",num2str(ptN),"_noMVC_rad.mat"),'currentMovementArray');
currentMovementArray=ulnArray;
save(strcat(saveDir,"uln\trial",num2str(trialN),"pt",num2str(ptN),"_noMVC_uln.mat"),'currentMovementArray');
