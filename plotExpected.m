function [] = plotExpected(movement,outputDir,doPlotExpectedTuning,doPlotExpectedCI)
if(doPlotExpectedTuning)
    % plot tuning curve vs expected
    % for each muscle, for each movement, for each trial, plot avg of all avgs
    % of all files on tuning curve (no CI in tuning curves but instead plot CIs below) along with expected
    % tuning
    
    fc=1; % figure counter
    fleDir=pi;
    extDir=0;
    ulnDir=3*pi/2;
    radDir=pi/2;
    
    activeMusclesFromAllTrials={'EDCM','ECRB','FCR','FCU','ECU'};
    
    % ECRB expected tuning (opposite of ECRB movement) = fle,uln (aka,
    % ECRB movement = ext,rad)
    figure(fc);
    polarplot(fleDir,1,'o');
    hold on
    polarplot(ulnDir,1,'o');
    title("ECRB expected tuning curve");
    hold off
    saveas(fc,outputDir+"expectedTuningCurves\ECRBexpectedTuningCurve.tif");
        fc=fc+1;
        
    % ECRL expected tuning (opposite of ECRL movement) = fle,uln (aka,
    % ECRL movement = ext,rad)
    figure(fc);
    polarplot(fleDir,1,'o');
    hold on
    polarplot(ulnDir,1,'o');
    title("ECRL expected tuning curve");
    hold off
    saveas(fc,outputDir+"expectedTuningCurves\ECRLexpectedTuningCurve.tif");
        fc=fc+1;
        
    % ECU expected tuning (opposite of ECU movement) = fle,rad (aka,
    % ECU movement = ext,uln)
    figure(fc);
    polarplot(fleDir,1,'o');
    hold on
    polarplot(radDir,1,'o');
    title("ECU expected tuning curve");
    hold off
    saveas(fc,outputDir+"expectedTuningCurves\ECUexpectedTuningCurve.tif");
        fc=fc+1;
        
    % FCR expected tuning (opposite of FCR movement) = ext,uln (aka,
    % FCR movement = fle,rad)
    figure(fc);
    polarplot(extDir,1,'o');
    hold on
    polarplot(ulnDir,1,'o');
    title("FCR expected tuning curve");
    hold off
    saveas(fc,outputDir+"expectedTuningCurves\FCRexpectedTuningCurve.tif");
        fc=fc+1;
        
    % FCU expected tuning (opposite of FCU movement) = ext,rad (aka,
    % FCU movement = fle,uln)
    figure(fc);
    polarplot(extDir,1,'o');
    hold on
    polarplot(radDir,1,'o');
    title("FCU expected tuning curve");
    hold off
    saveas(fc,outputDir+"expectedTuningCurves\FCUexpectedTuningCurve.tif");
        fc=fc+1;
        
    % EDCM expected tuning (opposite of EDCM movement) = fle (aka,
    % EDCM movement = ext)
    figure(fc);
    polarplot(fleDir,1,'o');
    hold on
    polarplot(0,0,'o'); % indicate no uln/rad tuning
    title("EDCM expected tuning curve");
    hold off
    saveas(fc,outputDir+"expectedTuningCurves\EDCMexpectedTuningCurve.tif");
        fc=fc+1;
end

if(doPlotExpectedCI_1movement)
    % plot CI vs expected
    % for each movement, for each muscle, for each trial, plot CI on cartesian
    % graph along with expected range
    
    if(~doPlotExpectedTuning)
        fc=0; %figure counter
    end
    
    activeMuscles_trial3p1 = {'EDCM','ECRB','FCR'};
    activeMuscles_trial4 = {'EDCM', 'ECRB', 'FCU', 'FCR'};
    
    % ECRB expected tuning (opposite of ECRB movement) = fle,uln (aka,
    % ECRB movement = ext,rad)
    % ECRL expected tuning (opposite of ECRL movement) = fle,uln (aka,
    % ECRL movement = ext,rad)
    % ECU expected tuning (opposite of ECU movement) = fle,rad (aka,
    % ECU movement = ext,uln)
    % FCR expected tuning (opposite of FCR movement) = ext,uln (aka,
    % FCR movement = fle,rad)
    % FCU expected tuning (opposite of FCU movement) = ext,rad (aka,
    % FCU movement = fle,uln)
    % EDCM expected tuning (opposite of EDCM movement) = fle (aka,
    % EDCM movement = ext)
    ECRBind=1;
    ECRLind=2;
    ECUind=3;
    FCRind=4;
    FCUind=5;
    EDCMind=6;
    
    figure(fc);
    if(movement=="ext")
        plot(ECRBind,0,'-o'); % ECRB is tuned to fle
        hold on
        plot(ECRLind,0,'-o'); % ECRL is tuned to fle
        plot(ECUind,0,'-o'); % ECU is tuned to fle
        plot(FCRind,1,'-o');  % FCR is tuned to ext
        plot(FCUind,1,'-o');  % FCU is tuned to ext
        plot(EDCMind,0,'-o');  % EDCM is tuned to fle
    elseif(movement=="fle")
        plot(ECRBind,1,'-o'); % ECRB is tuned to fle
        hold on
        plot(ECRLind,1,'-o'); % ECRL is tuned to fle
        plot(ECUind,1,'-o'); % ECU is tuned to fle
        plot(FCRind,0,'-o');  % FCR is tuned to ext
        plot(FCUind,0,'-o');  % FCU is tuned to ext
        plot(EDCMind,1,'-o');  % EDCM is tuned to fle
    elseif(movement=="rad")
        plot(ECRBind,0,'-o'); % ECRB is tuned to uln
        hold on
        plot(ECRLind,0,'-o'); % ECRL is tuned to uln
        plot(ECUind,1,'-o'); % ECU is tuned to rad
        plot(FCRind,0,'-o');  % FCR is tuned to uln
        plot(FCUind,1,'-o');  % FCU is tuned to rad
        plot(EDCMind,0.5,'-o');  % EDCM has no rad/uln tuning
    elseif(movement=="uln")
        plot(ECRBind,1,'-o'); % ECRB is tuned to uln
        hold on
        plot(ECRLind,1,'-o'); % ECRL is tuned to uln
        plot(ECUind,0,'-o'); % ECU is tuned to rad
        plot(FCRind,1,'-o');  % FCR is tuned to uln
        plot(FCUind,0,'-o');  % FCU is tuned to rad
        plot(EDCMind,0.5,'-o');  % EDCM has no rad/uln tuning
    end
    
    title(movement+" expected tuning confidence interval");
    xlabel("muscle ; 1=ECRB;2=ECRL;3=ECU;4=FCR;5=FCU;6=EDCM");
    ylabel("avg firing rate (imp/s)");
    xlim([0 7]);
    ylim([0 2]);
    saveas(fc,strcat(outputDir,"tTestDir\",movement,"ExpectedTuningCurve.tif"));
    fc=fc+1;
    
    % plot actual, not expected, tuning curves
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
    
    tTest2Ia_3p1=load(strcat(longDir,"tTestDir\",movement,"_tTest2Ia_3p1.mat"));
    tTest2II_3p1=load(strcat(longDir,"tTestDir\",movement,"_tTest2II_3p1.mat"));
    tTest2Ia_4pt1=load(strcat(longDir,"tTestDir\",movement,"_tTest2Ia_4pt1.mat"));
    tTest2II_4pt1=load(strcat(longDir,"tTestDir\",movement,"_tTest2II_4pt1.mat"));
    tTest2Ia_4pt2=load(strcat(longDir,"tTestDir\",movement,"_tTest2Ia_4pt2.mat"));
    tTest2II_4pt2=load(strcat(longDir,"tTestDir\",movement,"_tTest2II_4pt2.mat"));
    
    figure(fc);
    hold on
    %activeMuscles_trial3p1 = {'time', 'EDCM','ECRB','FCR'};
    %activeMuscles_trial4 = {'time', 'EDCM', 'ECRB', 'FCU', 'FCR'};
    for j=1:(size(activeMuscles_trial3p1,2)+2*size(activeMuscles_trial4,2))
        if(j >=1 && j<4) % trial3.1
            avgIa=tTest2Ia_3p1.tTest2Ia_3p1(1,(j-1)*6+tTest2avgIndex);%_3p1;
            stddevIa=tTest2Ia_3p1.tTest2Ia_3p1(1,(j-1)*6+tTest2stddevIndex);%_3p1;
            nIa=tTest2Ia_3p1.tTest2Ia_3p1(1,(j-1)*6+tTest2nIndex);%_3p1;
            SEIa=tTest2Ia_3p1.tTest2Ia_3p1(1,(j-1)*6+tTest2seIndex);%_3p1;
            CIlowIa=tTest2Ia_3p1.tTest2Ia_3p1(1,(j-1)*6+tTest2lowCIIndex);%_3p1;
            CIhighIa=tTest2Ia_3p1.tTest2Ia_3p1(1,(j-1)*6+tTest2highCIIndex);%_3p1;
            
            avgII=tTest2II_3p1.tTest2II_3p1(1,(j-1)*6+tTest2avgIndex);%_3p1;
            stddevII=tTest2II_3p1.tTest2II_3p1(1,(j-1)*6+tTest2stddevIndex);%_3p1;
            nII=tTest2II_3p1.tTest2II_3p1(1,(j-1)*6+tTest2nIndex);%_3p1;
            SEII=tTest2II_3p1.tTest2II_3p1(1,(j-1)*6+tTest2seIndex);%_3p1;
            CIlowII=tTest2II_3p1.tTest2II_3p1(1,(j-1)*6+tTest2lowCIIndex);%_3p1;
            CIhighII=tTest2II_3p1.tTest2II_3p1(1,(j-1)*6+tTest2highCIIndex);%_3p1;
            
            if(j==1) %EDCM
                currMuscleInd=EDCMind;
                text(j,avgIa,"EDCMIa");
                text(j,avgII,"EDCMII");
            elseif(j==2) %ECRB
                currMuscleInd=ECRBind;
                text(j,avgIa,"ECRBIa");
                text(j,avgII,"ECRBII");
            elseif(j==3) %FCR
                currMuscleInd=FCRind;
                text(j,avgIa,"FCRIa");
                text(j,avgII,"FCRII");
            end
        elseif(j>=4) % trial4
            if(j>=4 && j<8) %trial4pt1
                trial4counter=j-3;
                avgIa=tTest2Ia_4pt1.tTest2Ia_4pt1(1,(trial4counter-1)*6+tTest2avgIndex);%_4pt1;
                stddevIa=tTest2Ia_4pt1.tTest2Ia_4pt1(1,(trial4counter-1)*6+tTest2stddevIndex);%_4pt1;
                nIa=tTest2Ia_4pt1.tTest2Ia_4pt1(1,(trial4counter-1)*6+tTest2nIndex);%_4pt1;
                SEIa=tTest2Ia_4pt1.tTest2Ia_4pt1(1,(trial4counter-1)*6+tTest2seIndex);%_4pt1;
                CIlowIa=tTest2Ia_4pt1.tTest2Ia_4pt1(1,(trial4counter-1)*6+tTest2lowCIIndex);%_4pt1;
                CIhighIa=tTest2Ia_4pt1.tTest2Ia_4pt1(1,(trial4counter-1)*6+tTest2highCIIndex);%_4pt1;
                
                avgII=tTest2II_4pt1.tTest2II_4pt1(1,(trial4counter-1)*6+tTest2avgIndex);%_4pt1;
                stddevII=tTest2II_4pt1.tTest2II_4pt1(1,(trial4counter-1)*6+tTest2stddevIndex);%_4pt1;
                nII=tTest2II_4pt1.tTest2II_4pt1(1,(trial4counter-1)*6+tTest2nIndex);%_4pt1;
                SEII=tTest2II_4pt1.tTest2II_4pt1(1,(trial4counter-1)*6+tTest2seIndex);%_4pt1;
                CIlowII=tTest2II_4pt1.tTest2II_4pt1(1,(trial4counter-1)*6+tTest2lowCIIndex);%_4pt1;
                CIhighII=tTest2II_4pt1.tTest2II_4pt1(1,(trial4counter-1)*6+tTest2highCIIndex);%_4pt1;
            elseif(j>=8 && j<12) %trial4pt2
                trial4counter=j-7;
                avgIa=tTest2Ia_4pt2.tTest2Ia_4pt2(1,(trial4counter-1)*6+tTest2avgIndex);%_4pt2;
                stddevIa=tTest2Ia_4pt2.tTest2Ia_4pt2(1,(trial4counter-1)*6+tTest2stddevIndex);%_4pt2;
                nIa=tTest2Ia_4pt2.tTest2Ia_4pt2(1,(trial4counter-1)*6+tTest2nIndex);%_4pt2;
                SEIa=tTest2Ia_4pt2.tTest2Ia_4pt2(1,(trial4counter-1)*6+tTest2seIndex);%_4pt2;
                CIlowIa=tTest2Ia_4pt2.tTest2Ia_4pt2(1,(trial4counter-1)*6+tTest2lowCIIndex);%_4pt2;
                CIhighIa=tTest2Ia_4pt2.tTest2Ia_4pt2(1,(trial4counter-1)*6+tTest2highCIIndex);%_4pt2;
                
                avgII=tTest2II_4pt2.tTest2II_4pt2(1,(trial4counter-1)*6+tTest2avgIndex);%_4pt2;
                stddevII=tTest2II_4pt2.tTest2II_4pt2(1,(trial4counter-1)*6+tTest2stddevIndex);%_4pt2;
                nII=tTest2II_4pt2.tTest2II_4pt2(1,(trial4counter-1)*6+tTest2nIndex);%_4pt2;
                SEII=tTest2II_4pt2.tTest2II_4pt2(1,(trial4counter-1)*6+tTest2seIndex);%_4pt2;
                CIlowII=tTest2II_4pt2.tTest2II_4pt2(1,(trial4counter-1)*6+tTest2lowCIIndex);%_4pt2;
                CIhighII=tTest2II_4pt2.tTest2II_4pt2(1,(trial4counter-1)*6+tTest2highCIIndex);%_4pt2;
            end
            if(trial4counter==1) %EDCM
                currMuscleInd=EDCMind;
                text(trial4counter,avgIa,"EDCMIa");
                text(trial4counter,avgII,"EDCMII");
            elseif(trial4counter==2) %ECRB
                currMuscleInd=ECRBind;
                text(trial4counter,avgIa,"ECRBIa");
                text(trial4counter,avgII,"ECRBII");
            elseif(trial4counter==3) %FCU
                currMuscleInd=FCUind;
                text(trial4counter,avgIa,"FCUIa");
                text(trial4counter,avgII,"FCUII");
            elseif(trial4counter==4) %FCR
                currMuscleInd=FCRind;
                text(trial4counter,avgIa,"FCRIa");
                text(trial4counter,avgII,"FCRII");
            end
        end
        
        % upward pointing triangle is confidence interval high bound
        % downward pointing triangle is confidence interval low bound
        % star is average
        % Ia red II blue
        plot(currMuscleInd,avgIa,'Marker','*','Color','r');
        plot(currMuscleInd,CIlowIa,'Marker','v','Color','r');
        line([0,6],[CIlowIa,CIlowIa],'Color','r');
        plot(currMuscleInd,CIhighIa,'Marker','^','Color','r');
        line([0,6],[CIhighIa,CIhighIa],'Color','r');
        
        plot(currMuscleInd,avgII,'Marker','*','Color','b');
        plot(currMuscleInd,CIlowII,'Marker','v','Color','b');
        line([0,6],[CIlowII,CIlowII],'Color','b');
        plot(currMuscleInd,CIhighII,'Marker','^','Color','b');
        line([0,6],[CIhighII,CIhighII],'Color','b');
        %hang on
    end
    title(movement+" actual tuning confidence interval");
    % ECRBind=1;
    % ECRLind=2;
    % ECUind=3;
    % FCRind=4;
    % FCUind=5;
    % EDCMind=6;
    xlabel("muscle ; 1=ECRB;2=ECRL;3=ECU;4=FCR;5=FCU;6=EDCM");
    ylabel("avg firing rate (imp/s)");
    %xlim([0 7]);
    saveas(fc,strcat(longDir,"tTestDir\",movement,"ActualTuningCurve.tif"));
    fc=fc+1;
elseif(doPlotExpectedCI_1muscle)
end