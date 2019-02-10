function [] = incrementalProcessLengths(processLengthsInputDir, ...
    processLengthsOutputDir, trialN, ptN, trialOther, nFiles, moreMoBL)
% import data, put into lengths files, t
% lengths file t in s, lengths in m

if trialN == 1
    activeMuscles = {'time', 'ECRL'};
elseif trialN == 2
    activeMuscles = {'time', 'ECRL', 'FCR', 'ECU'};
elseif trialN == 3
    activeMuscles = {'time', 'ECU', 'FCR', 'ECRL', 'EDCM'};
elseif trialN == 3.1
    activeMuscles = {'time', 'FCR', 'ECRB', 'EDCM'};
elseif trialN == 4
    activeMuscles = {'time', 'EDCM', 'ECRB', 'FCU', 'FCR'};
end
if trialOther=="MoBLmod4wrist"
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
    fileStr="MoBLmod4wrist";
elseif moreMoBL
    activeMuscles = {'time','ECRL','ECRB','ECU','FCR','FCU'};
end
fileStr=strcat("trial", num2str(trialN), "pt",num2str(ptN));

muscleNames = {'time','DELT1','DELT2','DELT3','SUPSP','INFSP','SUBSC','TMIN','TMAJ','PECM1','PECM2','PECM3','LAT1','LAT2','LAT3','CORB','TRIlong','TRIlat','TRImed','ANC','SUP','BIClong','BICshort','BRA','BRD','ECRL','ECRB','ECU','FCR','FCU','PL','PT','PQ','FDSL','FDSR','FDSM','FDSI','FDPL','FDPR','FDPM','FDPI','EDCL','EDCR','EDCM','EDCI','EDM','EIP','EPL','EPB','FPL','APL'};

muscleCols = {1, 43, 45, 47, 49, 51,53,55,57,59,61,63,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99,101,103,105,107,109,111,113,115,117,119,121,123,125,127,129,131,133,135,137,139,141};
% startNum = 42;
muscleMap = containers.Map(muscleNames, muscleCols);

inputDir = processLengthsInputDir;
outputDir = processLengthsOutputDir;

for p=1:nFiles
    myS=strcat("trial",num2str(trialN),"_",num2str(p));
    
    %myFilename=strcat(inputDir, fileStr, "_",num2str(p),"_states_degrees.mot");
    
    % for [E:\moreR\Nov22_2018_MATLABscripts\MATLABscripts\
    % polymorphicAndTrial3point1\MoBLmod4model\certainlyMax1dilN0\linEnv\
    % winsize1000\trial4pt2\MoBLmod6_7model\dilN0\noChn0\trial4_dilN0_pt2\
    % incrementalFDoutputDir] in which name is just 'trial4_p'
    myFilename=strcat(inputDir, "trial",num2str(trialN),"_",num2str(p),"_states_degrees.mot");    
    % for moreMoBL doSplit files with filename of 'n_states_degrees.mot'
    if(moreMoBL)
        myFilename=inputDir + num2str(p)+"_states_degrees.mot";
    end
    if(not(exist(strcat(inputDir, "unusable_", myS, "_states_degrees.mot"), "file")))
        c = importdata(myFilename);
        if(trialOther=="")
            c=c.data;
        end
        %sizeC=size(c.data);
        
        %for each activeMuscles
        % take array with column number determined from map, put into file
        
        for k=activeMuscles
            if(strcmp(k{1}, 'time'))
                s = [k{1}, '.mot'];
            else
                s = [k{1}, 'lengths.mot'];
            end
            if(moreMoBL)
                myOutputFilename=strcat(outputDir,num2str(p),"_",s);
            else
                myOutputFilename=strcat(outputDir,fileStr,"_",num2str(p),"_",s);
            end
            myFile = fopen(myOutputFilename,'w');
            a2 = c(:,muscleMap(k{1})); % k
            for j=1:length(a2)
                if(j==1)
                    fprintf(myFile, '%.9f', a2(j));
                else
                    fprintf(myFile, '\r\n%.9f', a2(j));
                end
            end
            fclose(myFile);
        end
    end
end
end