% determine fle and dev parts

% note
% [C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\more
%MoBL\collect_states_deg_bs_ModelFiles\mod4_bs_4_articleResults\incrementalFDoutputDir\splitTo10msIncrements]
% looks corrupted with Asian characters , but MATLAB reads into numbers
% which look correct

moreMoBL=true;
trialOther="mod4_bs_SimulationResults_bs_Wrist"; %"mod4_bs_4_articleResults"; %mod4_bs_SimulationResults_bs_Wrist  %"MoBLmod4wrist"

%//mod2_bs_allpassivemuscles_bs_2_shoulder	shoulder movement, no feur
%mod4_bs_4_articleResults		feur
%//mod4_bs_SimulationResults_bs_Elbow	elbow movement, no feur
%//mod4_bs_SimulationResults_bs_Shoulder	shoulder movement, no feur
%mod4_bs_SimulationResults_bs_Wrist	feur
%//mod6_bs_SimulationResults		barely any feur
%//mod7_bs_7_results			no feur

if(trialOther=="MoBLmod4wrist" && ~moreMoBL)
    fleDevFilename="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLcompareResultsMod4wrist\incrementalFDoutputDir\MoBL_ARMS_module2_4_allmuscles_wrist_fledev.mot";
    outputFilenameWithValues="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLmod4wrist_fleExtUlnRadPartsWithValues.mot";
    outputFilename="C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\MoBLmod4compareResultsToNESTtoSig\MoBLmod4wrist_fleExtUlnRadParts.mot";
    splitIndicies=[37,75,115,149,165,184,211,259,321,393,466,510,519,528,...
        537,548,557,568,581,601,621,632,643,656,674,686,698,717,792,880,...
        976,1073,1167,1228,1239,1249,1257,1269,1296,1314,1325,1335,1345,...
        1368,1384,1400,1425,1454,1509,1560,1612,1660,1705,1750,1791,1837,...
        1884,1930,1975,2022,2061,2104,2151,2191,2232];
    splitTimes=[0.10002,0.20016,0.30058,0.40351,0.5014,0.60132,0.70037,...
        0.80073,0.90106,1.0012,1.1,1.2102,1.3142,1.4069,1.5046,1.6044,...
        1.7083,1.8055,1.9009,2.0021,2.104,2.2117,2.3039,2.4123,2.5026,...
        2.6073,2.7009,2.8055,2.9009,3.0007,3.1007,3.2007,3.3001,3.4052,...
        3.5066,3.6082,3.7076,3.8004,3.903,4.0014,4.1023,4.2084,4.3011,...
        4.404,4.506,4.6008,4.7024,4.8004,4.9023,5.0012,5.1009,5.2006,5.3013,...
        5.4014,5.5007,5.6001,5.7016,5.8005,5.9001,6.0029,6.1009,6.2009,...
        6.3011,6.4024,6.5002];
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
    nFiles=65;
    
    fleInd=3; %index
    devInd=2;
elseif(moreMoBL)
    if trialOther=="mod2_bs_allpassivemuscles_bs_2_shoulder"
        nFiles=138;
    elseif trialOther=="mod4_bs_4_articleResults"
        % if copy paste header and first line in google sheets, fle = col S (19th letter),
        % dev=R (18th)
        nFiles=651;
        fleInd=19;
        devInd=18;
        %moreMoBLfleDevFilename="MoBL_ARMS_module2_4_allmuscles_wrist_states_degrees.mot";
    elseif trialOther=="mod4_bs_SimulationResults_bs_Elbow"
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Shoulder"
        nFiles=651;
    elseif trialOther=="mod4_bs_SimulationResults_bs_Wrist"
        % if copy paste header and first line in google sheets, fle = col S (19th letter),
        % dev=R (18th)
        nFiles=651;
        fleInd=19;
        devInd=18;
        %moreMoBLfleDevFilename="MoBL_ARMS_module2_4_allmuscles_wrist_states_degrees";
    elseif trialOther=="mod6_bs_SimulationResults"
        nFiles=433;
    elseif trialOther=="mod7_bs_7_results"
        % if copy paste header and first line in google sheets, fle = col T (20th letter),
        % dev=S (19th)
        nFiles=398;
        %fleInd=20;
        %devInd=19;
        %moreMoBLfleDevFilename="FDS_states_degrees";
    end
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
    fileStr=trialOther;
    longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\moreMoBL\collect_states_deg_bs_ModelFiles\";
    fleDevDir=strcat(longDir,trialOther,"\incrementalFDoutputDir\splitTo10msIncrements\");
    outputFilename=strcat(longDir,trialOther,"\",trialOther,"_fleExtUlnRadParts.mot");
    outputFilenameWithValues=strcat(longDir,trialOther,"\",trialOther,"_fleExtUlnRadPartsWithValues.mot");
end

sizeA=size(activeMuscles);
nFileToFleExtUlnRad=zeros(nFiles,4);
% fle ext uln rad
fleIndex=1;
extIndex=2;
ulnIndex=3;
radIndex=4;

% in deg
fleLowerBound=30;
extUpperBound=-30;
radUpperBound=0;
ulnLowerBound=10;

outputFileWithValues=fopen(outputFilenameWithValues,'w');
fprintf(outputFileWithValues,'time\tflexion\textension\traddev\tulndev\n');
outputFile=fopen(outputFilename,'w');

if(trialOther=="MoBLmod4wrist" && ~moreMoBL)
    % DO NOT EDIT ME
    fleDevFile=importdata(fleDevFilename);
    sizeF=size(fleDevFile.data,1);
    nextClosestTcounter=1;
    nextClosestT=splitTimes(nextClosestTcounter);
    incrementCount=0;
    radC=0; % rad counter
    ulnC=0;
    extC=0;
    fleC=0;
    % DO NOT EDIT ME
    for i=1:sizeF
        incrementCount=incrementCount+1;
        if(fleDevFile.data(i,1)>nextClosestT)
            % DO NOT EDIT ME
            % determine if file is rad, uln,ext,fle
            if(radC>(incrementCount/2)) % if rad count > (n increments)/2 , aka
                % if dev > radLowerBound (definition of 'radial dev' , here)
                % for more than half of 10 s increment
                nFileToFleExtUlnRad(nextClosestTcounter,radIndex)=1;
                fprintf(outputFileWithValues,"rad\t");
                fprintf(outputFile,"rad\t");
            end% DO NOT EDIT ME
            if(ulnC>(incrementCount/2))
                nFileToFleExtUlnRad(nextClosestTcounter,ulnIndex)=1;
                fprintf(outputFileWithValues,"uln\t");
                fprintf(outputFile,"uln\t");
            end% DO NOT EDIT ME
            if(fleC>(incrementCount/2))
                nFileToFleExtUlnRad(nextClosestTcounter,fleIndex)=1;
                fprintf(outputFileWithValues,"fle\t");
                fprintf(outputFile,"fle\t");
            end% DO NOT EDIT ME
            if(extC>(incrementCount/2))
                nFileToFleExtUlnRad(nextClosestTcounter,extIndex)=1;
                fprintf(outputFileWithValues,"ext\t");
                fprintf(outputFile,"ext\t");
            end% DO NOT EDIT ME
            fprintf(outputFileWithValues,"\n");
            %fprintf(outputFile,"\n");
            incrementCount=0;
            radC=0;
            ulnC=0;
            extC=0;
            fleC=0;
            % DO NOT EDIT ME
            nextClosestTcounter=nextClosestTcounter+1;
            %fprintf(outputFile,'%.9f\n',nextClosestT);
            fprintf(outputFileWithValues,'time (ms) %.9f\n',fleDevFile.data(i,1));
            fprintf(outputFile,'time (ms) %.9f\n',fleDevFile.data(i,1));
            % DO NOT EDIT ME
            % to avoid calling nonexistent index at end of file
            if(i<2046)
                nextClosestT=splitTimes(nextClosestTcounter);
            end% DO NOT EDIT ME
        end% DO NOT EDIT ME
        if(fleDevFile.data(i,fleInd)>fleLowerBound)
            % fle
            fprintf(outputFileWithValues,'%.9f\t',fleDevFile.data(i,fleInd));
            fleC=fleC+1;
        else% DO NOT EDIT ME
            fprintf(outputFileWithValues,'-\t');
        end% DO NOT EDIT ME
        if(fleDevFile.data(i,fleInd)<extUpperBound)
            % ext
            fprintf(outputFileWithValues,'%.9f\t',fleDevFile.data(i,fleInd));
            extC=extC+1;
        else% DO NOT EDIT ME
            fprintf(outputFileWithValues,'-\t');
        end% DO NOT EDIT ME
        if(fleDevFile.data(i,devInd)<radUpperBound)
            % rad
            fprintf(outputFileWithValues,'%.9f\t',fleDevFile.data(i,devInd));
            radC=radC+1;
        else% DO NOT EDIT ME
            fprintf(outputFileWithValues,'-\t');
        end% DO NOT EDIT ME
        if(fleDevFile.data(i,devInd)>ulnLowerBound)
            % uln
            fprintf(outputFileWithValues,'%.9f\n',fleDevFile.data(i,devInd));
            ulnC=ulnC+1;
        else% DO NOT EDIT ME
            fprintf(outputFileWithValues,'-\n');
        end% DO NOT EDIT ME
    end
    %save("MoBLmod4wrist_nFileToFleExtUlnRad","nFileToFleExtUlnRad")
elseif(moreMoBL)
    % for each file in incrementalFDoutputDir , see which ones have fle ext
    % rad uln
    
    radC=0; % rad counter
    ulnC=0;
    extC=0;
    fleC=0;
    
    for nFile=1:nFiles
        fleDevFile=importdata(strcat(fleDevDir,num2str(nFile),"_states_degrees.mot"));
        fprintf(outputFileWithValues,'%i\t-1\t-1\t-1\t-1\n',nFile);
        fprintf(outputFile,'%i\t',nFile);
        sizeF=size(fleDevFile,1);
        for i=1:sizeF
            
            % print meaningless number to fill space so matlab can later read
            % file with importdata()
            fprintf(outputFileWithValues,'-1\t');
            
            % count fle uln rad dev in file
            if(fleDevFile(i,fleInd)>fleLowerBound)
                % fle
                fprintf(outputFileWithValues,'%.9f\t',fleDevFile(i,fleInd));
                fleC=fleC+1;
            else
                fprintf(outputFileWithValues,'fle-1\t');
            end
            if(fleDevFile(i,fleInd)<extUpperBound)
                % ext
                fprintf(outputFileWithValues,'%.9f\t',fleDevFile(i,fleInd));
                extC=extC+1;
            else
                fprintf(outputFileWithValues,'ext-1\t');
            end
            if(fleDevFile(i,devInd)<radUpperBound)
                % rad
                fprintf(outputFileWithValues,'%.9f\t',fleDevFile(i,devInd));
                radC=radC+1;
            else
                fprintf(outputFileWithValues,'rad-1\t');
            end
            if(fleDevFile(i,devInd)>ulnLowerBound)
                % uln
                fprintf(outputFileWithValues,'%.9f\n',fleDevFile(i,devInd));
                ulnC=ulnC+1;
            else
                fprintf(outputFileWithValues,'uln-1\n');
            end
        end
        % file is now done being counted
        
        % determine if file is rad, uln,ext,fle
        if(radC>(sizeF/2)) % if rad count > (n steps of file)/2 , aka
            % if dev > radLowerBound (definition of 'radial dev' , here)
            % for more than half of 10 s increment (which is already
            % measured out into file, likely by splitFiles)
            nFileToFleExtUlnRad(nFile,radIndex)=1;
            fprintf(outputFileWithValues,"rad\t");
            fprintf(outputFile,"1\t");
        else
            fprintf(outputFile,'-1\t');
        end
        if(ulnC>(sizeF/2)) % if uln count > (n steps of file)/2 , aka
            % if dev > ulnLowerBound (definition of 'uln dev' , here)
            % for more than half of 10 s increment (which is already
            % measured out into file, likely by splitFiles)
            nFileToFleExtUlnRad(nFile,ulnIndex)=1;
            fprintf(outputFileWithValues,"uln\t");
            fprintf(outputFile,"1\t");
        else
            fprintf(outputFile,'-1\t');
        end
        if(extC>(sizeF/2)) % if ext count > (n steps of file)/2 , aka
            % if ext > extLowerBound (definition of 'ext' , here)
            % for more than half of 10 s increment (which is already
            % measured out into file, likely by splitFiles)
            nFileToFleExtUlnRad(nFile,extIndex)=1;
            fprintf(outputFileWithValues,"ext\t");
            fprintf(outputFile,"1\t");
        else
            fprintf(outputFile,'-1\t');
        end
        if(fleC>(sizeF/2)) % if fle count > (n steps of file)/2 , aka
            % if fle > fleLowerBound (definition of 'fle' , here)
            % for more than half of 10 s increment (which is already
            % measured out into file, likely by splitFiles)
            nFileToFleExtUlnRad(nFile,fleIndex)=1;
            fprintf(outputFileWithValues,"fle\t");
            fprintf(outputFile,"1\t");
        else
            fprintf(outputFile,'-1\t');
        end
        fprintf(outputFileWithValues,"\n");
        fprintf(outputFile,"\n");
        radC=0;
        ulnC=0;
        extC=0;
        fleC=0;
        
        %fprintf(outputFileWithValues,'time (ms) %.9f\n',fleDevFile(i,1));
        %fprintf(outputFile,'time (ms) %.9f\n',fleDevFile(i,1));
        %save("MoBLmod4wrist_nFileToFleExtUlnRad","nFileToFleExtUlnRad")
    end
end