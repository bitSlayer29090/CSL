function []=DrJonesMoBLmod4wristComparisonTuningCurves_phaseShift_noMVC(trialN,ptN,doMakeAvgOfAvg, doPlotCartesian)
% Creating tuning curves from microneurographic recordings of muscle
% spindles in human extensor carpi radialis as taken in 'Jones, K. E.,
% Wessberg, J., & Vallbo, Å. B. (2001). Directional tuning of human forearm
% muscle afferents during voluntary wrist movements. The Journal of
% Physiology, 536(2), 635-647.

%{
q = n/ avg n trials per spindle, n spindles, active/passive
muscles = ECR, EDC, EDC, ECR GTO
// for file in  mat folder
gather info
produce polar plot
%}

set(0,'DefaultFigureVisible','on');
%% LOAD IN DATA AND GATHER INFORMATION

%trialN=3.1;
%ptN=-1;
trialOther="";
%"mod4_bs_4_articleResults";%"mod4_bs_SimulationResults_bs_Wrist";
moreMoBL=false;
noMVC=true;
if(~noMVC)
    error("running tuningCurves .m for noMVC, but ~noMVC");
end
movements=["ext" "fle" "rad" "uln"];
longDir=strcat("E:\moreR\noMVCextractInterval1\","trial",num2str(trialN),"_dilN0_pt",num2str(ptN),"\");
%longDir=strcat("C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\noMVCextract\","trial",num2str(trialN),"_dilN0_pt",num2str(ptN),"\");
outputDir=strcat(longDir,"\noMVCtotalTifDir\");

% for each movement, add to to plot, then plot all

% my wanted angles
%fleDir=0;
%extDir=pi/2;
%ulnDir=pi;
%radDir=3*pi/2;

% Dr. Jones angles
%[DrJonesEmail.txt] 'Extension (from neutral starting
% position) is positive and Radial deviation is positive'
% article fig 3 , flexion is pos x , rad dev is pos y
% going with [DrJonesEmail.txt] (pos extension, pos rad) since it pertains
% to the data received
% moreover if [C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\
% revisedPlots\DrJones_ECUphaseShift_polar.tif] shows that uln tuning is
% mostly at pi/2 and MoBLmodwrist-produced [C:\InteruserWorkspace\
% DrJonesAfferentDataPlotsCurrent\revisedPlots\MoBLmod4wrist\
% old_ECU_magnitudeOfAfferent_angleOffleExtUlnRad.tif] tuning at 180 deg
% (uln) then
% uln = neg y (both article fig 3 and [DrJonesEmail.txt] agree)
% ext = pos x ([DrJonesEmail.txt] agrees)
fleDir=pi;
extDir=0;
ulnDir=3*pi/2;
radDir=pi/2;

% fle ext uln rad
% 1=fle,2=ext,3=uln,4=rad ; confirmed nFileToFleExtUlnRad is correct
fleIndex=1;
extIndex=2;
ulnIndex=3;
radIndex=4;

fileStr=strcat("trial",num2str(trialN),"pt",num2str(ptN));

if trialN==3.1 && ptN==-1 && ~moreMoBL
    
    %{
    % trial3.1pt-1 32-54 ext;63-87 fle;94-119 rad;128-149 uln
    trial3p1ext=[3 4 5];
    trial3p1fle=[6 7 8];
    trial3p1uln=[9 10 11];
    trial3p1rad=[13 14];
    
    extFiles=[3 4 5];
    fleFiles=[6 7 8];
    ulnFiles=[9 10 11];
    radFiles=[13 14];
    %}
    
    activeMuscles = {'time', 'EDCM','ECRB','FCR'};
    
    EDCMindex=2;
    ECRBindex=3;
    FCRindex=4;
    
    % MUSCLEIa,II = nFile, avg firing rate at fle ext uln rad
    EDCMIa=zeros(1,4);
    ECRBIa=zeros(1,4);
    FCRIa=zeros(1,4);
    
    EDCMII=zeros(1,4);
    ECRBII=zeros(1,4);
    FCRII=zeros(1,4);
    
    % for each n file, if fle ext uln rad , put muscle avg firing rate to array
    % in fle ext uln rad index
    
    % for each 10 ms step , for each muscle, plot each avg each fle , ext , uln, rad
    
    % for polar
    % col1=direction,col2 = Ia, col3 = II
    Iaind=2;
    IIind=3;
    % direction (based on right hand , thus rad (away from thumb) = 0 deg ,
    % extension = 90 deg
    EDCMplot=zeros(1,3);
    ECRBplot=zeros(1,3);
    FCRplot=zeros(1,3);
    %     EDCMplotC=zeros(1,3); %'C'=cartesian
    %     ECRBplotC=zeros(1,3);
    %     FCRplotC=zeros(1,3);
    
    musclePlotRowCounter=1;
    
    for j=1:size(movements,2) % note unlike python, MATLAB a:b evaluates to a,...,b NOT a,...,b-1
        movement=movements(j);
        inputDir=longDir+movement+"\noPlottingAfferentOutputDir\";
        
        % breakpoint here to check file names
        statsIa=importdata(strcat(inputDir,fileStr,"_statsIa.mat"));
        statsII=importdata(strcat(inputDir,fileStr,"_statsII.mat"));
        
        % 's'=start ; 'e'=end ; nFile takes badPart cut out into account thus
        % times should line up
        %only want up to 160 s since afterwards is straight
        %hand movements, which dont care about since likely not in Dr. Jones study
        % =up to and including fileN 16
        %nFiles=16; %nFiles=31;
        if(trialN==3.1 && noMVC)
            % nFiles includes +1 for leftover (obv unless leftover=0)
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
        
        for i=1:nFiles
            % dont need e,f,u,r for noMVC since all files are ext,fle,uln, or
            % rad
            %{
    % e,f,u,r likely counters so if particular nFiles isnt ext,fle,uln,or
    % rad, still plot point at middle to show that it isn't any of them
    e=0;
    f=0;
    u=0;
    r=0;
            %}
            if(movement=="fle")
                EDCMplot(musclePlotRowCounter,1)=fleDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=fleDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=fleDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                
                %                 EDCMplotC(musclePlotRowCounter,1)=fleDir;
                %                 EDCMplotC(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                %                 EDCMplotC(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                %
                %                 ECRBplotC(musclePlotRowCounter,1)=fleDir;
                %                 ECRBplotC(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                %                 ECRBplotC(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                %
                %                 FCRplotC(musclePlotRowCounter,1)=fleDir;
                %                 FCRplotC(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                %                 FCRplotC(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            elseif(movement=="ext")
                EDCMplot(musclePlotRowCounter,1)=extDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=extDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=extDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            elseif(movement=="uln")
                EDCMplot(musclePlotRowCounter,1)=ulnDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=ulnDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=ulnDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            elseif(movement=="rad")
                EDCMplot(musclePlotRowCounter,1)=radDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=radDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=radDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            end
        end
    end
    
    %figure(10)
    %plot(EDCMplot)
    %figure(11)
    %plot(ECRBplot)
    %figure(12)
    %plot(FCRplot)
    
    %% plot avg of avg firing rates, for fle/ext (x-axis) and uln/rad
    % (y-axis)
    
    %fleDir=pi;
    %extDir=0;
    %ulnDir=3*pi/2;
    %radDir=pi/2;
    
    %Iaind=2;
    %IIind=3;
    
    % EDCM
    EDCMavgIaExtFle=0;
    EDCMavgIaRadUln=0;
    EDCMavgIIExtFle=0;
    EDCMavgIIRadUln=0;
    for a=1:size(EDCMplot,1)
        % Ia
        % x-axis , ext/fle
        if(EDCMplot(a,1)==extDir)
            EDCMavgIaExtFle=EDCMavgIaExtFle+EDCMplot(a,Iaind); % add since ext is pos x-axis
        end
        if(EDCMplot(a,1)==fleDir)
            EDCMavgIaExtFle=EDCMavgIaExtFle-EDCMplot(a,Iaind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(EDCMplot(a,1)==radDir)
            EDCMavgIaRadUln=EDCMavgIaRadUln+EDCMplot(a,Iaind); % add since rad is pos y-axis
        end
        if(EDCMplot(a,1)==ulnDir)
            EDCMavgIaRadUln=EDCMavgIaRadUln-EDCMplot(a,Iaind); % subtract since uln is neg y-axis
        end
        % II
        % x-axis , ext/fle
        if(EDCMplot(a,1)==extDir)
            EDCMavgIIExtFle=EDCMavgIIExtFle+EDCMplot(a,IIind); % add since ext is pos x-axis
        end
        if(EDCMplot(a,1)==fleDir)
            EDCMavgIIExtFle=EDCMavgIIExtFle-EDCMplot(a,IIind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(EDCMplot(a,1)==radDir)
            EDCMavgIIRadUln=EDCMavgIIRadUln+EDCMplot(a,IIind); % add since rad is pos y-axis
        end
        if(EDCMplot(a,1)==ulnDir)
            EDCMavgIIRadUln=EDCMavgIIRadUln-EDCMplot(a,IIind); % subtract since uln is neg y-axis
        end
    end
    if(doMakeAvgOfAvg)
        EDCMavgOfAvg=["trial3.1_EDCMavgIaExtFle",EDCMavgIaExtFle;...
            "trial3.1_EDCMavgIaRadUln",EDCMavgIaRadUln;...
            "trial3.1_EDCMavgIIExtFle",EDCMavgIIExtFle;...
            "trial3.1_EDCMavgIIRadUln",EDCMavgIIRadUln];
        save(strcat(longDir,"noMVCtotalTifDir\trial3.1_EDCMavgOfAvg.mat"),"EDCMavgOfAvg");
    end
    
    fc=1; % figure counter
    figure(fc);
    hold on
    % Ia is orange , II is blue
    EDCMplotAngles=EDCMplot(:,1);
    EDCMplotIa=EDCMplot(:,Iaind);
    EDCMplotII=EDCMplot(:,IIind);
    
    if(~doPlotCartesian)
        % plot Ia avgs
        polarscatter(EDCMplotAngles,EDCMplotIa,'.');
        
        hold on
        % plot II avgs
        polarscatter(EDCMplotAngles,EDCMplotII,'o');
        
        % plot Ia avg of avgs
        % ext,fle in extDir since extDir already added, fleDir magnitudes were already subtracted
        % rad,uln in radDir since radDir already added, ulnDir magnitudes were already subtracted
        
        polarscatter(extDir,EDCMavgIaExtFle,'+'); % Ia avg is +
        polarscatter(radDir,EDCMavgIaRadUln,'+');
        
        % plot II avg of avgs
        polarscatter(extDir,EDCMavgIIExtFle,'x'); % II avg is x
        polarscatter(radDir,EDCMavgIIRadUln,'x');
        
        thetaticks(0:45:315);
        thetaticklabels({0, 45});
    else
        plot(EDCMplotAngles,EDCMplotIa,'.');
        plot(EDCMplotAngles,EDCMplotII,'o');
        plot(extDir,EDCMavgIaExtFle,'+'); % Ia avg is +
        plot(radDir,EDCMavgIaRadUln,'+');
        plot(extDir,EDCMavgIIExtFle,'x'); % II avg is x
        plot(radDir,EDCMavgIIRadUln,'x');
        xlim([-1,(5*pi/2)]);
        xticklabels(["","Ia pos ext neg fle","Ia pos rad neg uln","","II pos ext neg fle","II pos rad neg uln"]);
    end
    legend('II', 'Ia');
    title("EDCM Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(longDir,"noMVCtotalTifDir\EDCM_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    hold off
    fc=fc+1;
    
    % ECRB
    ECRBavgIaExtFle=0;
    ECRBavgIaRadUln=0;
    ECRBavgIIExtFle=0;
    ECRBavgIIRadUln=0;
    for a=1:size(ECRBplot,1)
        % Ia
        % x-axis , ext/fle
        if(ECRBplot(a,1)==extDir)
            ECRBavgIaExtFle=ECRBavgIaExtFle+ECRBplot(a,Iaind); % add since ext is pos x-axis
        end
        if(ECRBplot(a,1)==fleDir)
            ECRBavgIaExtFle=ECRBavgIaExtFle-ECRBplot(a,Iaind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(ECRBplot(a,1)==radDir)
            ECRBavgIaRadUln=ECRBavgIaRadUln+ECRBplot(a,Iaind); % add since rad is pos y-axis
        end
        if(ECRBplot(a,1)==ulnDir)
            ECRBavgIaRadUln=ECRBavgIaRadUln-ECRBplot(a,Iaind); % subtract since uln is neg y-axis
        end
        % II
        % x-axis , ext/fle
        if(ECRBplot(a,1)==extDir)
            ECRBavgIIExtFle=ECRBavgIIExtFle+ECRBplot(a,IIind); % add since ext is pos x-axis
        end
        if(ECRBplot(a,1)==fleDir)
            ECRBavgIIExtFle=ECRBavgIIExtFle-ECRBplot(a,IIind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(ECRBplot(a,1)==radDir)
            ECRBavgIIRadUln=ECRBavgIIRadUln+ECRBplot(a,IIind); % add since rad is pos y-axis
        end
        if(ECRBplot(a,1)==ulnDir)
            ECRBavgIIRadUln=ECRBavgIIRadUln-ECRBplot(a,IIind); % subtract since uln is neg y-axis
        end
    end
    if(doMakeAvgOfAvg)
        ECRBavgOfAvg=["trial3.1_ECRBavgIaExtFle",ECRBavgIaExtFle;...
            "trial3.1_ECRBavgIaRadUln",ECRBavgIaRadUln;...
            "trial3.1_ECRBavgIIExtFle",ECRBavgIIExtFle;...
            "trial3.1_ECRBavgIIRadUln",ECRBavgIIRadUln];
        save(strcat(longDir,"noMVCtotalTifDir\trial3.1_ECRBavgOfAvg.mat"),"ECRBavgOfAvg");
    end
    
    figure(fc);
    hold on
    % Ia is orange , II is blue
    ECRBplotAngles=ECRBplot(:,1);
    ECRBplotIa=ECRBplot(:,Iaind);
    ECRBplotII=ECRBplot(:,IIind);
    
    if(~doPlotCartesian)
        % plot Ia avgs
        polarscatter(ECRBplotAngles,ECRBplotIa,'.');
        
        hold on
        % plot II avgs
        polarscatter(ECRBplotAngles,ECRBplotII,'o');
        
        % plot Ia avg of avgs
        % ext,fle in extDir since extDir already added, fleDir magnitudes were already subtracted
        % rad,uln in radDir since radDir already added, ulnDir magnitudes were already subtracted
        
        polarscatter(extDir,ECRBavgIaExtFle,'+'); % Ia avg is +
        polarscatter(radDir,ECRBavgIaRadUln,'+');
        
        % plot II avg of avgs
        polarscatter(extDir,ECRBavgIIExtFle,'x'); % II avg is x
        polarscatter(radDir,ECRBavgIIRadUln,'x');
        
        thetaticks(0:45:315);
        thetaticklabels({0, 45});
    else
        plot(ECRBplotAngles,ECRBplotIa,'.');
        plot(ECRBplotAngles,ECRBplotII,'o');
        plot(extDir,ECRBavgIaExtFle,'+'); % Ia avg is +
        plot(radDir,ECRBavgIaRadUln,'+');
        plot(extDir,ECRBavgIIExtFle,'x'); % II avg is x
        plot(radDir,ECRBavgIIRadUln,'x');
        xlim([-1,(5*pi/2)]);
        xticklabels(["","Ia pos ext neg fle","Ia pos rad neg uln","","II pos ext neg fle","II pos rad neg uln"]);
    end
    legend('II', 'Ia');
    title("ECRB Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(longDir,"noMVCtotalTifDir\ECRB_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    hold off
    fc=fc+1;
    
    % FCR
    FCRavgIaExtFle=0;
    FCRavgIaRadUln=0;
    FCRavgIIExtFle=0;
    FCRavgIIRadUln=0;
    for a=1:size(FCRplot,1)
        % Ia
        % x-axis , ext/fle
        if(FCRplot(a,1)==extDir)
            FCRavgIaExtFle=FCRavgIaExtFle+FCRplot(a,Iaind); % add since ext is pos x-axis
        end
        if(FCRplot(a,1)==fleDir)
            FCRavgIaExtFle=FCRavgIaExtFle-FCRplot(a,Iaind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(FCRplot(a,1)==radDir)
            FCRavgIaRadUln=FCRavgIaRadUln+FCRplot(a,Iaind); % add since rad is pos y-axis
        end
        if(FCRplot(a,1)==ulnDir)
            FCRavgIaRadUln=FCRavgIaRadUln-FCRplot(a,Iaind); % subtract since uln is neg y-axis
        end
        % II
        % x-axis , ext/fle
        if(FCRplot(a,1)==extDir)
            FCRavgIIExtFle=FCRavgIIExtFle+FCRplot(a,IIind); % add since ext is pos x-axis
        end
        if(FCRplot(a,1)==fleDir)
            FCRavgIIExtFle=FCRavgIIExtFle-FCRplot(a,IIind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(FCRplot(a,1)==radDir)
            FCRavgIIRadUln=FCRavgIIRadUln+FCRplot(a,IIind); % add since rad is pos y-axis
        end
        if(FCRplot(a,1)==ulnDir)
            FCRavgIIRadUln=FCRavgIIRadUln-FCRplot(a,IIind); % subtract since uln is neg y-axis
        end
    end
    if(doMakeAvgOfAvg)
        FCRavgOfAvg=["trial3.1_FCRavgIaExtFle",FCRavgIaExtFle;...
            "trial3.1_FCRavgIaRadUln",FCRavgIaRadUln;...
            "trial3.1_FCRavgIIExtFle",FCRavgIIExtFle;...
            "trial3.1_FCRavgIIRadUln",FCRavgIIRadUln];
        save(strcat(longDir,"noMVCtotalTifDir\trial3.1_FCRavgOfAvg.mat"),"FCRavgOfAvg");
    end
    
    figure(fc);
    hold on
    % Ia is orange , II is blue
    FCRplotAngles=FCRplot(:,1);
    FCRplotIa=FCRplot(:,Iaind);
    FCRplotII=FCRplot(:,IIind);
    
    if(~doPlotCartesian)
        % plot Ia avgs
        polarscatter(FCRplotAngles,FCRplotIa,'.');
        
        hold on
        % plot II avgs
        polarscatter(FCRplotAngles,FCRplotII,'o');
        
        % plot Ia avg of avgs
        % ext,fle in extDir since extDir already added, fleDir magnitudes were already subtracted
        % rad,uln in radDir since radDir already added, ulnDir magnitudes were already subtracted
        
        polarscatter(extDir,FCRavgIaExtFle,'+'); % Ia avg is +
        polarscatter(radDir,FCRavgIaRadUln,'+');
        
        % plot II avg of avgs
        polarscatter(extDir,FCRavgIIExtFle,'x'); % II avg is x
        polarscatter(radDir,FCRavgIIRadUln,'x');
        
        thetaticks(0:45:315);
        thetaticklabels({0, 45});
    else
        plot(FCRplotAngles,FCRplotIa,'.');
        plot(FCRplotAngles,FCRplotII,'o');
        plot(extDir,FCRavgIaExtFle,'+'); % Ia avg is +
        plot(radDir,FCRavgIaRadUln,'+');
        plot(extDir,FCRavgIIExtFle,'x'); % II avg is x
        plot(radDir,FCRavgIIRadUln,'x');
        xlim([-1,(5*pi/2)]);
        xticklabels(["","Ia pos ext neg fle","Ia pos rad neg uln","","II pos ext neg fle","II pos rad neg uln"]);
    end
    legend('II', 'Ia');
    title("FCR Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(longDir,"noMVCtotalTifDir\FCR_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    hold off
    fc=fc+1;
    
elseif trialN==4 && (ptN==1 || ptN==2) && ~moreMoBL
    %{
% pt 1
        %nFiles=17;
        % 's'=start ; 'e'=end ; nFile takes badPart cut out into account thus
        % times should line up
        %trial4pt1 41-71 ext;84-105 fle;119-141 uln;154-179 rad;cutout 7:01-end
        %4-6 8-9-10 120-130 150-170 420
        trial4pt1ext=[4 5 6];
        trial4pt1fle=[8 9 10];
        trial4pt1uln=[12];
        trial4pt1rad=[15 16];
        
        extFiles=[4 5 6];
        fleFiles=[8 9 10];
        ulnFiles=[12];
        radFiles=[15 16];
        
        %pt 2
                %nFiles=11;
        % 's'=start ; 'e'=end ; nFile takes badPart cut out into account thus
        % times should line up
        %trial4pt2 23-44 ext;45-63 fle;63-83 uln;83-102 rad;cutout 0-0:10, 2:20-end
        % 20-40 40-60 60-80 80-100
        % cutout 0-0:10 thus +1 to all filenames
        trial4pt2extFiles=[2+1 3+1];
        trial4pt2fleFiles=[4+1 5+1];
        trial4pt2ulnFiles=[6+1 7+1];
        trial4pt2radFiles=[8+1 9+1];
        
        extFiles=[2+1 3+1];
        fleFiles=[4+1 5+1];
        ulnFiles=[6+1 7+1];
        radFiles=[8+1 9+1];
    %}
    
    activeMuscles = {'time', 'EDCM', 'ECRB', 'FCU', 'FCR'};
    
    EDCMindex=2;
    ECRBindex=3;
    FCUindex=4;
    FCRindex=5;
    
    % MUSCLEIa,II = nFile, avg firing rate at fle ext uln rad
    EDCMIa=zeros(1,4);
    ECRBIa=zeros(1,4);
    FCUIa=zeros(1,4);
    FCRIa=zeros(1,4);
    
    EDCMII=zeros(1,4);
    ECRBII=zeros(1,4);
    FCUII=zeros(1,4);
    FCRII=zeros(1,4);
    
    % for each n file, if fle ext uln rad , put muscle avg firing rate to array
    % in fle ext uln rad index
    
    % for each 10 ms step , for each muscle, plot each avg each fle , ext , uln, rad
    
    % for polar
    % col1=direction,col2 = Ia, col3 = II
    Iaind=2;
    IIind=3;
    % direction (based on right hand , thus rad (away from thumb) = 0 deg ,
    % extension = 90 deg
    EDCMplot=zeros(1,3);
    ECRBplot=zeros(1,3);
    FCRplot=zeros(1,3);
    FCUplot=zeros(1,3);
    
    musclePlotRowCounter=1;
    
    for j=1:size(movements,2) % note unlike python, MATLAB a:b evaluates to a,...,b NOT a,...,b-1
        movement=movements(j);
        inputDir=longDir+movement+"\noPlottingAfferentOutputDir\";
        
        % breakpoint here to check file names
        statsIa=importdata(strcat(inputDir,fileStr,"_statsIa.mat"));
        statsII=importdata(strcat(inputDir,fileStr,"_statsII.mat"));
        
        if ptN==1
            if trialN==4 && ptN==1 && noMVC
                % nFiles includes +1 for leftover (obv unless leftover=0)
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
            if(trialN==4 && ptN==2 && noMVC)
                % nFiles includes +1 for leftover (obv unless leftover=0)
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
        
        for i=1:nFiles
            % dont need e,f,u,r for noMVC since all files are ext,fle,uln, or
            % rad
            %{
        % e,f,u,r likely counters so if particular nFiles isnt ext,fle,uln,or
        % rad, still plot point at middle to show that it isn't any of them
        e=0;
        f=0;
        u=0;
        r=0;
            %}
            
            if(movement=="fle")
                EDCMplot(musclePlotRowCounter,1)=fleDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=fleDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=fleDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                
                FCUplot(musclePlotRowCounter,1)=fleDir;
                FCUplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCUindex-2)*4+1+1+1);
                FCUplot(musclePlotRowCounter,IIind)=statsII(i,(FCUindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            elseif(movement=="ext")
                e=1;
                EDCMplot(musclePlotRowCounter,1)=extDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=extDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=extDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                
                FCUplot(musclePlotRowCounter,1)=extDir;
                FCUplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCUindex-2)*4+1+1+1);
                FCUplot(musclePlotRowCounter,IIind)=statsII(i,(FCUindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            elseif(movement=="uln")
                EDCMplot(musclePlotRowCounter,1)=ulnDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=ulnDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=ulnDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                
                FCUplot(musclePlotRowCounter,1)=ulnDir;
                FCUplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCUindex-2)*4+1+1+1);
                FCUplot(musclePlotRowCounter,IIind)=statsII(i,(FCUindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            elseif(movement=="rad")
                EDCMplot(musclePlotRowCounter,1)=radDir;
                EDCMplot(musclePlotRowCounter,Iaind)=statsIa(i,(EDCMindex-2)*4+1+1+1);
                EDCMplot(musclePlotRowCounter,IIind)=statsII(i,(EDCMindex-2)*4+1+1+1);
                
                ECRBplot(musclePlotRowCounter,1)=radDir;
                ECRBplot(musclePlotRowCounter,Iaind)=statsIa(i,(ECRBindex-2)*4+1+1+1);
                ECRBplot(musclePlotRowCounter,IIind)=statsII(i,(ECRBindex-2)*4+1+1+1);
                
                FCRplot(musclePlotRowCounter,1)=radDir;
                FCRplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCRindex-2)*4+1+1+1);
                FCRplot(musclePlotRowCounter,IIind)=statsII(i,(FCRindex-2)*4+1+1+1);
                
                FCUplot(musclePlotRowCounter,1)=radDir;
                FCUplot(musclePlotRowCounter,Iaind)=statsIa(i,(FCUindex-2)*4+1+1+1);
                FCUplot(musclePlotRowCounter,IIind)=statsII(i,(FCUindex-2)*4+1+1+1);
                musclePlotRowCounter=musclePlotRowCounter+1;
            end
        end
    end
    
    %figure(10)
    %plot(EDCMplot)
    %figure(11)
    %plot(ECRBplot)
    %figure(12)
    %plot(FCRplot)
    %figure(13)
    %plot(FCUplot)
    
    %% plot avg of avg firing rates, for fle/ext (x-axis) and uln/rad
    % (y-axis)
    
    smallStr=strcat("trial",num2str(trialN),"pt",num2str(ptN));
    
    % EDCM
    EDCMavgIaExtFle=0;
    EDCMavgIaRadUln=0;
    EDCMavgIIExtFle=0;
    EDCMavgIIRadUln=0;
    for a=1:size(EDCMplot,1)
        % Ia
        % x-axis , ext/fle
        if(EDCMplot(a,1)==extDir)
            EDCMavgIaExtFle=EDCMavgIaExtFle+EDCMplot(a,Iaind); % add since ext is pos x-axis
        end
        if(EDCMplot(a,1)==fleDir)
            EDCMavgIaExtFle=EDCMavgIaExtFle-EDCMplot(a,Iaind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(EDCMplot(a,1)==radDir)
            EDCMavgIaRadUln=EDCMavgIaRadUln+EDCMplot(a,Iaind); % add since rad is pos y-axis
        end
        if(EDCMplot(a,1)==ulnDir)
            EDCMavgIaRadUln=EDCMavgIaRadUln-EDCMplot(a,Iaind); % subtract since uln is neg y-axis
        end
        % II
        % x-axis , ext/fle
        if(EDCMplot(a,1)==extDir)
            EDCMavgIIExtFle=EDCMavgIIExtFle+EDCMplot(a,IIind); % add since ext is pos x-axis
        end
        if(EDCMplot(a,1)==fleDir)
            EDCMavgIIExtFle=EDCMavgIIExtFle-EDCMplot(a,IIind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(EDCMplot(a,1)==radDir)
            EDCMavgIIRadUln=EDCMavgIIRadUln+EDCMplot(a,IIind); % add since rad is pos y-axis
        end
        if(EDCMplot(a,1)==ulnDir)
            EDCMavgIIRadUln=EDCMavgIIRadUln-EDCMplot(a,IIind); % subtract since uln is neg y-axis
        end
    end
    if(doMakeAvgOfAvg)
        EDCMavgOfAvg=[strcat(smallStr,"_EDCMavgIaExtFle"),EDCMavgIaExtFle;...
            strcat(smallStr,"_EDCMavgIaRadUln"),EDCMavgIaRadUln;...
            strcat(smallStr,"_EDCMavgIIExtFle"),EDCMavgIIExtFle;...
            strcat(smallStr,"_EDCMavgIIRadUln"),EDCMavgIIRadUln];
        save(strcat(longDir,"noMVCtotalTifDir\",smallStr,"_EDCMavgOfAvg.mat"),"EDCMavgOfAvg");
    end
    
    fc=1; % figure counter
    figure(fc);
    hold on
    % Ia is orange , II is blue
    EDCMplotAngles=EDCMplot(:,1);
    EDCMplotIa=EDCMplot(:,Iaind);
    EDCMplotII=EDCMplot(:,IIind);
    
    if(~doPlotCartesian)
        % plot Ia avgs
        polarscatter(EDCMplotAngles,EDCMplotIa,'.');
        
        hold on
        % plot II avgs
        polarscatter(EDCMplotAngles,EDCMplotII,'o');
        
        % plot Ia avg of avgs
        % ext,fle in extDir since extDir already added, fleDir magnitudes were already subtracted
        % rad,uln in radDir since radDir already added, ulnDir magnitudes were already subtracted
        
        polarscatter(extDir,EDCMavgIaExtFle,'+'); % Ia avg is +
        polarscatter(radDir,EDCMavgIaRadUln,'+');
        
        % plot II avg of avgs
        polarscatter(extDir,EDCMavgIIExtFle,'x'); % II avg is x
        polarscatter(radDir,EDCMavgIIRadUln,'x');
        
        thetaticks(0:45:315);
        thetaticklabels({0, 45});
    else
        plot(EDCMplotAngles,EDCMplotIa,'.');
        plot(EDCMplotAngles,EDCMplotII,'o');
        plot(extDir,EDCMavgIaExtFle,'+'); % Ia avg is +
        plot(radDir,EDCMavgIaRadUln,'+');
        plot(extDir,EDCMavgIIExtFle,'x'); % II avg is x
        plot(radDir,EDCMavgIIRadUln,'x');
        xlim([-1,(5*pi/2)]);
        xticklabels(["","Ia pos ext neg fle","Ia pos rad neg uln","","II pos ext neg fle","II pos rad neg uln"]);
    end
    legend('II', 'Ia');
    title("EDCM Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(longDir,"noMVCtotalTifDir\EDCM_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    hold off
    fc=fc+1;
    
    % ECRB
    ECRBavgIaExtFle=0;
    ECRBavgIaRadUln=0;
    ECRBavgIIExtFle=0;
    ECRBavgIIRadUln=0;
    for a=1:size(ECRBplot,1)
        % Ia
        % x-axis , ext/fle
        if(ECRBplot(a,1)==extDir)
            ECRBavgIaExtFle=ECRBavgIaExtFle+ECRBplot(a,Iaind); % add since ext is pos x-axis
        end
        if(ECRBplot(a,1)==fleDir)
            ECRBavgIaExtFle=ECRBavgIaExtFle-ECRBplot(a,Iaind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(ECRBplot(a,1)==radDir)
            ECRBavgIaRadUln=ECRBavgIaRadUln+ECRBplot(a,Iaind); % add since rad is pos y-axis
        end
        if(ECRBplot(a,1)==ulnDir)
            ECRBavgIaRadUln=ECRBavgIaRadUln-ECRBplot(a,Iaind); % subtract since uln is neg y-axis
        end
        % II
        % x-axis , ext/fle
        if(ECRBplot(a,1)==extDir)
            ECRBavgIIExtFle=ECRBavgIIExtFle+ECRBplot(a,IIind); % add since ext is pos x-axis
        end
        if(ECRBplot(a,1)==fleDir)
            ECRBavgIIExtFle=ECRBavgIIExtFle-ECRBplot(a,IIind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(ECRBplot(a,1)==radDir)
            ECRBavgIIRadUln=ECRBavgIIRadUln+ECRBplot(a,IIind); % add since rad is pos y-axis
        end
        if(ECRBplot(a,1)==ulnDir)
            ECRBavgIIRadUln=ECRBavgIIRadUln-ECRBplot(a,IIind); % subtract since uln is neg y-axis
        end
    end
    if(doMakeAvgOfAvg)
        ECRBavgOfAvg=[strcat(smallStr,"_ECRBavgIaExtFle"),ECRBavgIaExtFle;...
            strcat(smallStr,"_ECRBavgIaRadUln"),ECRBavgIaRadUln;...
            strcat(smallStr,"_ECRBavgIIExtFle"),ECRBavgIIExtFle;...
            strcat(smallStr,"_ECRBavgIIRadUln"),ECRBavgIIRadUln];
        save(strcat(longDir,"noMVCtotalTifDir\",smallStr,"_ECRBavgOfAvg.mat"),"ECRBavgOfAvg");
    end
    
    figure(fc);
    hold on
    % Ia is orange , II is blue
    ECRBplotAngles=ECRBplot(:,1);
    ECRBplotIa=ECRBplot(:,Iaind);
    ECRBplotII=ECRBplot(:,IIind);
    
    if(~doPlotCartesian)
        % plot Ia avgs
        polarscatter(ECRBplotAngles,ECRBplotIa,'.');
        
        hold on
        % plot II avgs
        polarscatter(ECRBplotAngles,ECRBplotII,'o');
        
        % plot Ia avg of avgs
        % ext,fle in extDir since extDir already added, fleDir magnitudes were already subtracted
        % rad,uln in radDir since radDir already added, ulnDir magnitudes were already subtracted
        
        polarscatter(extDir,ECRBavgIaExtFle,'+'); % Ia avg is +
        polarscatter(radDir,ECRBavgIaRadUln,'+');
        
        % plot II avg of avgs
        polarscatter(extDir,ECRBavgIIExtFle,'x'); % II avg is x
        polarscatter(radDir,ECRBavgIIRadUln,'x');
        
        thetaticks(0:45:315);
        thetaticklabels({0, 45});
    else
        plot(ECRBplotAngles,ECRBplotIa,'.');
        plot(ECRBplotAngles,ECRBplotII,'o');
        plot(extDir,ECRBavgIaExtFle,'+'); % Ia avg is +
        plot(radDir,ECRBavgIaRadUln,'+');
        plot(extDir,ECRBavgIIExtFle,'x'); % II avg is x
        plot(radDir,ECRBavgIIRadUln,'x');
        xlim([-1,(5*pi/2)]);
        xticklabels(["","Ia pos ext neg fle","Ia pos rad neg uln","","II pos ext neg fle","II pos rad neg uln"]);
    end
    legend('II', 'Ia');
    title("ECRB Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(longDir,"noMVCtotalTifDir\ECRB_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    hold off
    fc=fc+1;
    
    % FCR
    FCRavgIaExtFle=0;
    FCRavgIaRadUln=0;
    FCRavgIIExtFle=0;
    FCRavgIIRadUln=0;
    for a=1:size(FCRplot,1)
        % Ia
        % x-axis , ext/fle
        if(FCRplot(a,1)==extDir)
            FCRavgIaExtFle=FCRavgIaExtFle+FCRplot(a,Iaind); % add since ext is pos x-axis
        end
        if(FCRplot(a,1)==fleDir)
            FCRavgIaExtFle=FCRavgIaExtFle-FCRplot(a,Iaind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(FCRplot(a,1)==radDir)
            FCRavgIaRadUln=FCRavgIaRadUln+FCRplot(a,Iaind); % add since rad is pos y-axis
        end
        if(FCRplot(a,1)==ulnDir)
            FCRavgIaRadUln=FCRavgIaRadUln-FCRplot(a,Iaind); % subtract since uln is neg y-axis
        end
        % II
        % x-axis , ext/fle
        if(FCRplot(a,1)==extDir)
            FCRavgIIExtFle=FCRavgIIExtFle+FCRplot(a,IIind); % add since ext is pos x-axis
        end
        if(FCRplot(a,1)==fleDir)
            FCRavgIIExtFle=FCRavgIIExtFle-FCRplot(a,IIind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(FCRplot(a,1)==radDir)
            FCRavgIIRadUln=FCRavgIIRadUln+FCRplot(a,IIind); % add since rad is pos y-axis
        end
        if(FCRplot(a,1)==ulnDir)
            FCRavgIIRadUln=FCRavgIIRadUln-FCRplot(a,IIind); % subtract since uln is neg y-axis
        end
    end
    if(doMakeAvgOfAvg)
        FCRavgOfAvg=[strcat(smallStr,"_FCRavgIaExtFle"),FCRavgIaExtFle;...
            strcat(smallStr,"_FCRavgIaRadUln"),FCRavgIaRadUln;...
            strcat(smallStr,"_FCRavgIIExtFle"),FCRavgIIExtFle;...
            strcat(smallStr,"_FCRavgIIRadUln"),FCRavgIIRadUln];
        save(strcat(longDir,"noMVCtotalTifDir\",smallStr,"_FCRavgOfAvg.mat"),"FCRavgOfAvg");
    end
    
    figure(fc);
    hold on
    % Ia is orange , II is blue
    FCRplotAngles=FCRplot(:,1);
    FCRplotIa=FCRplot(:,Iaind);
    FCRplotII=FCRplot(:,IIind);
    
    if(~doPlotCartesian)
        % plot Ia avgs
        polarscatter(FCRplotAngles,FCRplotIa,'.');
        
        hold on
        % plot II avgs
        polarscatter(FCRplotAngles,FCRplotII,'o');
        
        % plot Ia avg of avgs
        % ext,fle in extDir since extDir already added, fleDir magnitudes were already subtracted
        % rad,uln in radDir since radDir already added, ulnDir magnitudes were already subtracted
        
        polarscatter(extDir,FCRavgIaExtFle,'+'); % Ia avg is +
        polarscatter(radDir,FCRavgIaRadUln,'+');
        
        % plot II avg of avgs
        polarscatter(extDir,FCRavgIIExtFle,'x'); % II avg is x
        polarscatter(radDir,FCRavgIIRadUln,'x');
        
        thetaticks(0:45:315);
        thetaticklabels({0, 45});
    else
        plot(FCRplotAngles,FCRplotIa,'.');
        plot(FCRplotAngles,FCRplotII,'o');
        plot(extDir,FCRavgIaExtFle,'+'); % Ia avg is +
        plot(radDir,FCRavgIaRadUln,'+');
        plot(extDir,FCRavgIIExtFle,'x'); % II avg is x
        plot(radDir,FCRavgIIRadUln,'x');
        xlim([-1,(5*pi/2)]);
        xticklabels(["","Ia pos ext neg fle","Ia pos rad neg uln","","II pos ext neg fle","II pos rad neg uln"]);
    end
    legend('II', 'Ia');
    title("FCR Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(longDir,"noMVCtotalTifDir\FCR_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    hold off
    fc=fc+1;
    
    % FCU
    FCUavgIaExtFle=0;
    FCUavgIaRadUln=0;
    FCUavgIIExtFle=0;
    FCUavgIIRadUln=0;
    for a=1:size(FCUplot,1)
        % Ia
        % x-axis , ext/fle
        if(FCUplot(a,1)==extDir)
            FCUavgIaExtFle=FCUavgIaExtFle+FCUplot(a,Iaind); % add since ext is pos x-axis
        end
        if(FCUplot(a,1)==fleDir)
            FCUavgIaExtFle=FCUavgIaExtFle-FCUplot(a,Iaind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(FCUplot(a,1)==radDir)
            FCUavgIaRadUln=FCUavgIaRadUln+FCUplot(a,Iaind); % add since rad is pos y-axis
        end
        if(FCUplot(a,1)==ulnDir)
            FCUavgIaRadUln=FCUavgIaRadUln-FCUplot(a,Iaind); % subtract since uln is neg y-axis
        end
        % II
        % x-axis , ext/fle
        if(FCUplot(a,1)==extDir)
            FCUavgIIExtFle=FCUavgIIExtFle+FCUplot(a,IIind); % add since ext is pos x-axis
        end
        if(FCUplot(a,1)==fleDir)
            FCUavgIIExtFle=FCUavgIIExtFle-FCUplot(a,IIind); % subtract since fle is neg x-axis
        end
        % y-axis , rad/uln
        if(FCUplot(a,1)==radDir)
            FCUavgIIRadUln=FCUavgIIRadUln+FCUplot(a,IIind); % add since rad is pos y-axis
        end
        if(FCUplot(a,1)==ulnDir)
            FCUavgIIRadUln=FCUavgIIRadUln-FCUplot(a,IIind); % subtract since uln is neg y-axis
        end
    end
    if(doMakeAvgOfAvg)
        FCUavgOfAvg=[strcat(smallStr,"_FCUavgIaExtFle"),FCUavgIaExtFle;...
            strcat(smallStr,"_FCUavgIaRadUln"),FCUavgIaRadUln;...
            strcat(smallStr,"_FCUavgIIExtFle"),FCUavgIIExtFle;...
            strcat(smallStr,"_FCUavgIIRadUln"),FCUavgIIRadUln];
        save(strcat(longDir,"noMVCtotalTifDir\",smallStr,"_FCUavgOfAvg.mat"),"FCUavgOfAvg");
    end
    
    figure(fc);
    hold on
    % Ia is orange , II is blue
    FCUplotAngles=FCUplot(:,1);
    FCUplotIa=FCUplot(:,Iaind);
    FCUplotII=FCUplot(:,IIind);
    
    if(~doPlotCartesian)
        % plot Ia avgs
        polarscatter(FCUplotAngles,FCUplotIa,'.');
        
        hold on
        % plot II avgs
        polarscatter(FCUplotAngles,FCUplotII,'o');
        
        % plot Ia avg of avgs
        % ext,fle in extDir since extDir already added, fleDir magnitudes were already subtracted
        % rad,uln in radDir since radDir already added, ulnDir magnitudes were already subtracted
        
        polarscatter(extDir,FCUavgIaExtFle,'+'); % Ia avg is +
        polarscatter(radDir,FCUavgIaRadUln,'+');
        
        % plot II avg of avgs
        polarscatter(extDir,FCUavgIIExtFle,'x'); % II avg is x
        polarscatter(radDir,FCUavgIIRadUln,'x');
        
        thetaticks(0:45:315);
        thetaticklabels({0, 45});
    else
        plot(FCUplotAngles,FCUplotIa,'.');
        plot(FCUplotAngles,FCUplotII,'o');
        plot(extDir,FCUavgIaExtFle,'+'); % Ia avg is +
        plot(radDir,FCUavgIaRadUln,'+');
        plot(extDir,FCUavgIIExtFle,'x'); % II avg is x
        plot(radDir,FCUavgIIRadUln,'x');
        xlim([-1,(5*pi/2)]);
        xticklabels(["","Ia pos ext neg fle","Ia pos rad neg uln","","II pos ext neg fle","II pos rad neg uln"]);
    end
    legend('II', 'Ia');
    title("FCU Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(longDir,"noMVCtotalTifDir\FCU_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    hold off
    fc=fc+1;
    
elseif trialOther=="MoBLmod4wrist" || moreMoBL
    if(trialOther=="MoBLmod4wrist")
        nFiles=65;
        fileStr="MoBLmod4wrist";
        load('C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLmod4wrist_nFileToFleExtUlnRad.mat');
        % cut out last 4 (at bottom , after 6.5 )
        nFileToFleExtUlnRad=nFileToFleExtUlnRad(1:65,:);
    elseif(moreMoBL)
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
        getFleExtRadUlnParts_outputFilenameWithValues=strcat(longDir,trialOther,"\",trialOther,"_fleExtUlnRadParts.mot");
        nFileToFleExtUlnRad=load(getFleExtRadUlnParts_outputFilenameWithValues);
    end
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
    ECRLindex=2;
    ECRBindex=3;
    ECUindex=4;
    FCRindex=5;
    FCUindex=6;
    
    % MUSCLEIa = nFile, avg firing rate at fle ext uln rad
    ECRLIa=zeros(1,4);
    ECRBIa=zeros(1,4);
    ECUIa=zeros(1,4);
    FCRIa=zeros(1,4);
    FCUIa=zeros(1,4);
    
    ECRLII=zeros(1,4);
    ECRBII=zeros(1,4);
    ECUII=zeros(1,4);
    FCRII=zeros(1,4);
    FCUII=zeros(1,4);
    
    % for each n file, if fle ext uln rad , put muscle avg firing rate to array
    % in fle ext uln rad index
    
    % note since only checking if nFileToFleExtUlnRad(a,b)==1, -1 doesn't
    % pull down avg unless later take avg or do other such stuff with data
    
    for i=1:nFiles
        if(nFileToFleExtUlnRad(i,fleIndex)==1)
            ECRLIa(i,fleIndex)=statsIa(i,(ECRLindex-2)*4+1+1+1);
            ECRBIa(i,fleIndex)=statsIa(i,(ECRBindex-2)*4+1+1+1);
            ECUIa(i,fleIndex)=statsIa(i,(ECUindex-2)*4+1+1+1);
            FCRIa(i,fleIndex)=statsIa(i,(FCRindex-2)*4+1+1+1);
            FCUIa(i,fleIndex)=statsIa(i,(FCUindex-2)*4+1+1+1);
            
            ECRLII(i,fleIndex)=statsII(i,(ECRLindex-2)*4+1+1+1);
            ECRBII(i,fleIndex)=statsII(i,(ECRBindex-2)*4+1+1+1);
            ECUII(i,fleIndex)=statsII(i,(ECUindex-2)*4+1+1+1);
            FCRII(i,fleIndex)=statsII(i,(FCRindex-2)*4+1+1+1);
            FCUII(i,fleIndex)=statsII(i,(FCUindex-2)*4+1+1+1);
        end
        if(nFileToFleExtUlnRad(i,extIndex)==1)
            ECRLIa(i,extIndex)=statsIa(i,(ECRLindex-2)*4+1+1+1);
            ECRBIa(i,extIndex)=statsIa(i,(ECRBindex-2)*4+1+1+1);
            ECUIa(i,extIndex)=statsIa(i,(ECUindex-2)*4+1+1+1);
            FCRIa(i,extIndex)=statsIa(i,(FCRindex-2)*4+1+1+1);
            FCUIa(i,extIndex)=statsIa(i,(FCUindex-2)*4+1+1+1);
            
            ECRLII(i,extIndex)=statsII(i,(ECRLindex-2)*4+1+1+1);
            ECRBII(i,extIndex)=statsII(i,(ECRBindex-2)*4+1+1+1);
            ECUII(i,extIndex)=statsII(i,(ECUindex-2)*4+1+1+1);
            FCRII(i,extIndex)=statsII(i,(FCRindex-2)*4+1+1+1);
            FCUII(i,extIndex)=statsII(i,(FCUindex-2)*4+1+1+1);
        end
        if(nFileToFleExtUlnRad(i,ulnIndex)==1)
            ECRLIa(i,ulnIndex)=statsIa(i,(ECRLindex-2)*4+1+1+1);
            ECRBIa(i,ulnIndex)=statsIa(i,(ECRBindex-2)*4+1+1+1);
            ECUIa(i,ulnIndex)=statsIa(i,(ECUindex-2)*4+1+1+1);
            FCRIa(i,ulnIndex)=statsIa(i,(FCRindex-2)*4+1+1+1);
            FCUIa(i,ulnIndex)=statsIa(i,(FCUindex-2)*4+1+1+1);
            
            ECRLII(i,ulnIndex)=statsII(i,(ECRLindex-2)*4+1+1+1);
            ECRBII(i,ulnIndex)=statsII(i,(ECRBindex-2)*4+1+1+1);
            ECUII(i,ulnIndex)=statsII(i,(ECUindex-2)*4+1+1+1);
            FCRII(i,ulnIndex)=statsII(i,(FCRindex-2)*4+1+1+1);
            FCUII(i,ulnIndex)=statsII(i,(FCUindex-2)*4+1+1+1);
        end
        if(nFileToFleExtUlnRad(i,radIndex)==1)
            ECRLIa(i,radIndex)=statsIa(i,(ECRLindex-2)*4+1+1+1);
            ECRBIa(i,radIndex)=statsIa(i,(ECRBindex-2)*4+1+1+1);
            ECUIa(i,radIndex)=statsIa(i,(ECUindex-2)*4+1+1+1);
            FCRIa(i,radIndex)=statsIa(i,(FCRindex-2)*4+1+1+1);
            FCUIa(i,radIndex)=statsIa(i,(FCUindex-2)*4+1+1+1);
            
            ECRLII(i,radIndex)=statsII(i,(ECRLindex-2)*4+1+1+1);
            ECRBII(i,radIndex)=statsII(i,(ECRBindex-2)*4+1+1+1);
            ECUII(i,radIndex)=statsII(i,(ECUindex-2)*4+1+1+1);
            FCRII(i,radIndex)=statsII(i,(FCRindex-2)*4+1+1+1);
            FCUII(i,radIndex)=statsII(i,(FCUindex-2)*4+1+1+1);
        end
        if(nFileToFleExtUlnRad(i,fleIndex)~=1 && ...
                nFileToFleExtUlnRad(i,extIndex)~=1 && ...
                nFileToFleExtUlnRad(i,ulnIndex)~=1 && ...
                nFileToFleExtUlnRad(i,radIndex)~=1)
            ECRLIa(i,:)=0;
            ECRLII(i,:)=0;
            ECRBIa(i,:)=0;
            ECRBII(i,:)=0;
            ECUIa(i,:)=0;
            ECUII(i,:)=0;
            FCRIa(i,:)=0;
            FCRII(i,:)=0;
            FCUIa(i,:)=0;
            FCUII(i,:)=0;
        end
    end
    
    % for each 10 ms step , for each muscle, plot each avg each fle , ext , uln, rad
    
    % for polar
    % col1=direction,col2 = Ia, col3 = II
    Iaind=2;
    IIind=3;
    % direction (based on right hand , thus rad (away from thumb) = 0 deg ,
    % extension = 90 deg
    ECRLplot=zeros(1,3);
    ECRBplot=zeros(1,3);
    ECUplot=zeros(1,3);
    FCRplot=zeros(1,3);
    FCUplot=zeros(1,3);
    
    sizeN=size(nFileToFleExtUlnRad);
    musclePlotRowCounter=1;
    
    for i=1:sizeN(1)
        if(nFileToFleExtUlnRad(i,fleIndex))
            ECRLplot(musclePlotRowCounter,1)=fleDir;
            ECRLplot(musclePlotRowCounter,Iaind)=ECRLIa(i,fleIndex);
            ECRLplot(musclePlotRowCounter,IIind)=ECRLII(i,fleIndex);
            
            ECRBplot(musclePlotRowCounter,1)=fleDir;
            ECRBplot(musclePlotRowCounter,Iaind)=ECRBIa(i,fleIndex);
            ECRBplot(musclePlotRowCounter,IIind)=ECRBII(i,fleIndex);
            
            ECUplot(musclePlotRowCounter,1)=fleDir;
            ECUplot(musclePlotRowCounter,Iaind)=ECUIa(i,fleIndex);
            ECUplot(musclePlotRowCounter,IIind)=ECUII(i,fleIndex);
            
            FCRplot(musclePlotRowCounter,1)=fleDir;
            FCRplot(musclePlotRowCounter,Iaind)=FCRIa(i,fleIndex);
            FCRplot(musclePlotRowCounter,IIind)=FCRII(i,fleIndex);
            
            FCUplot(musclePlotRowCounter,1)=fleDir;
            FCUplot(musclePlotRowCounter,Iaind)=FCUIa(i,fleIndex);
            FCUplot(musclePlotRowCounter,IIind)=FCUII(i,fleIndex);
            musclePlotRowCounter=musclePlotRowCounter+1;
        end
        if(nFileToFleExtUlnRad(i,extIndex))
            ECRLplot(musclePlotRowCounter,1)=extDir;
            ECRLplot(musclePlotRowCounter,Iaind)=ECRLIa(i,extIndex);
            ECRLplot(musclePlotRowCounter,IIind)=ECRLII(i,extIndex);
            
            ECRBplot(musclePlotRowCounter,1)=extDir;
            ECRBplot(musclePlotRowCounter,Iaind)=ECRBIa(i,extIndex);
            ECRBplot(musclePlotRowCounter,IIind)=ECRBII(i,extIndex);
            
            ECUplot(musclePlotRowCounter,1)=extDir;
            ECUplot(musclePlotRowCounter,Iaind)=ECUIa(i,extIndex);
            ECUplot(musclePlotRowCounter,IIind)=ECUII(i,extIndex);
            
            FCRplot(musclePlotRowCounter,1)=extDir;
            FCRplot(musclePlotRowCounter,Iaind)=FCRIa(i,extIndex);
            FCRplot(musclePlotRowCounter,IIind)=FCRII(i,extIndex);
            
            FCUplot(musclePlotRowCounter,1)=extDir;
            FCUplot(musclePlotRowCounter,Iaind)=FCUIa(i,extIndex);
            FCUplot(musclePlotRowCounter,IIind)=FCUII(i,extIndex);
            musclePlotRowCounter=musclePlotRowCounter+1;
        end
        if(nFileToFleExtUlnRad(i,ulnIndex))
            ECRLplot(musclePlotRowCounter,1)=ulnDir;
            ECRLplot(musclePlotRowCounter,Iaind)=ECRLIa(i,ulnIndex);
            ECRLplot(musclePlotRowCounter,IIind)=ECRLII(i,ulnIndex);
            
            ECRBplot(musclePlotRowCounter,1)=ulnDir;
            ECRBplot(musclePlotRowCounter,Iaind)=ECRBIa(i,ulnIndex);
            ECRBplot(musclePlotRowCounter,IIind)=ECRBII(i,ulnIndex);
            
            ECUplot(musclePlotRowCounter,1)=ulnDir;
            ECUplot(musclePlotRowCounter,Iaind)=ECUIa(i,ulnIndex);
            ECUplot(musclePlotRowCounter,IIind)=ECUII(i,ulnIndex);
            
            FCRplot(musclePlotRowCounter,1)=ulnDir;
            FCRplot(musclePlotRowCounter,Iaind)=FCRIa(i,ulnIndex);
            FCRplot(musclePlotRowCounter,IIind)=FCRII(i,ulnIndex);
            
            FCUplot(musclePlotRowCounter,1)=ulnDir;
            FCUplot(musclePlotRowCounter,Iaind)=FCUIa(i,ulnIndex);
            FCUplot(musclePlotRowCounter,IIind)=FCUII(i,ulnIndex);
            musclePlotRowCounter=musclePlotRowCounter+1;
        end
        if(nFileToFleExtUlnRad(i,radIndex))
            ECRLplot(musclePlotRowCounter,1)=radDir;
            ECRLplot(musclePlotRowCounter,Iaind)=ECRLIa(i,radIndex);
            ECRLplot(musclePlotRowCounter,IIind)=ECRLII(i,radIndex);
            
            ECRBplot(musclePlotRowCounter,1)=radDir;
            ECRBplot(musclePlotRowCounter,Iaind)=ECRBIa(i,radIndex);
            ECRBplot(musclePlotRowCounter,IIind)=ECRBII(i,radIndex);
            
            ECUplot(musclePlotRowCounter,1)=radDir;
            ECUplot(musclePlotRowCounter,Iaind)=ECUIa(i,radIndex);
            ECUplot(musclePlotRowCounter,IIind)=ECUII(i,radIndex);
            
            FCRplot(musclePlotRowCounter,1)=radDir;
            FCRplot(musclePlotRowCounter,Iaind)=FCRIa(i,radIndex);
            FCRplot(musclePlotRowCounter,IIind)=FCRII(i,radIndex);
            
            FCUplot(musclePlotRowCounter,1)=radDir;
            FCUplot(musclePlotRowCounter,Iaind)=FCUIa(i,radIndex);
            FCUplot(musclePlotRowCounter,IIind)=FCUII(i,radIndex);
            musclePlotRowCounter=musclePlotRowCounter+1;
        end
    end
    
    %figure(10)
    %plot(ECRLplot)
    %figure(11)
    %plot(ECRBplot)
    %figure(12)
    %plot(ECUplot)
    %figure(13)
    %plot(FCRplot)
    %figure(14)
    %plot(FCUplot)
    
    fc=1; % figure counter
    figure(fc);
    % Ia is orange (for ECU, smoother) , II is blue (for ECU, spiky)
    ECRLplotAngles=ECRLplot(:,1);
    ECRLplotIa=ECRLplot(:,Iaind);
    ECRLplotII=ECRLplot(:,IIind);
    polarscatter(ECRLplotAngles,ECRLplotIa,'.');
    hold on
    polarscatter(ECRLplotAngles,ECRLplotII,'o');
    thetaticks(0:45:315);
    thetaticklabels({0, 45});
    legend('II', 'Ia');
    title("ECRL Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(outputDir,"ECRL_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    fc=fc+1;
    
    figure(fc);
    % Ia is orange (for ECU, smoother) , II is blue (for ECU, spiky)
    ECRBplotAngles=ECRBplot(:,1);
    ECRBplotIa=ECRBplot(:,Iaind);
    ECRBplotII=ECRBplot(:,IIind);
    polarscatter(ECRBplotAngles,ECRBplotIa,'.');
    hold on
    polarscatter(ECRBplotAngles,ECRBplotII,'o');
    thetaticks(0:45:315);
    thetaticklabels({0, 45});
    legend('II', 'Ia');
    title("ECRB Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(outputDir,"ECRB_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    fc=fc+1;
    
    figure(fc);
    % Ia is orange (for ECU, smoother) , II is blue (for ECU, spiky)
    ECUplotAngles=ECUplot(:,1);
    ECUplotIa=ECUplot(:,Iaind);
    ECUplotII=ECUplot(:,IIind);
    polarscatter(ECUplotAngles,ECUplotIa,'.');
    hold on;
    polarscatter(ECUplotAngles,ECUplotII,'o');
    thetaticks(0:45:315);
    thetaticklabels({0, 45});
    legend('II', 'Ia');
    title("ECU Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(outputDir,"ECU_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    fc=fc+1;
    
    figure(fc);
    % Ia is orange (for ECU, smoother) , II is blue (for ECU, spiky)
    FCRplotAngles=FCRplot(:,1);
    FCRplotIa=FCRplot(:,Iaind);
    FCRplotII=FCRplot(:,IIind);
    polarscatter(FCRplotAngles,FCRplotIa,'.');
    hold on;
    polarscatter(FCRplotAngles,FCRplotII,'o');
    thetaticks(0:45:315);
    thetaticklabels({0, 45});
    legend('II', 'Ia');
    title("FCR Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(outputDir,"FCR_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    fc=fc+1;
    
    figure(fc);
    % Ia is orange (for ECU, smoother) , II is blue (for ECU, spiky)
    FCUplotAngles=FCUplot(:,1);
    FCUplotIa=FCUplot(:,Iaind);
    FCUplotII=FCUplot(:,IIind);
    polarscatter(FCUplotAngles,FCUplotIa,'.');
    hold on;
    polarscatter(FCUplotAngles,FCUplotII,'o');
    thetaticks(0:45:315);
    thetaticklabels({0, 45});
    legend('II', 'Ia');
    title("FCU Ia and II firing rate (impulses/s) in fle/ext/uln/rad direction");
    saveas(fc,strcat(outputDir,"FCU_magnitudeOfAfferent_angleOffleExtUlnRad_cartesian.tif"));
    fc=fc+1;
    
    %{
    if(z==1) % if ECR
        shiftedAverageFiringRates = [averageFiringRates(5:8), averageFiringRates(1:5)];
    end
    
    %plot(shiftedAverageFiringRates)
    %}
end

clear all; % clear workspace
close all % closes all figures and GUI
end
