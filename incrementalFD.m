function [] = incrementalFD(trialN, secToBeWritten, nFiles, osimDir, ...
    FDoutputDir, setupFilename, setupPath, modelFilename, leftover, ...
    incrementalControlFilesDir, increment)
%% forward dynamics
%{
script =
for f=1:nFiles
set initT, finalT, resultsDir, CFN
set Model, FD
time
end
%}

import org.opensim.modeling.*

% methods('Model')
% methodsview Model

resultsDir = FDoutputDir;
ct = 0; % current t
for f=1:nFiles
    initialTime = ct;
    if(not(leftover==0) && f==nFiles)
        finalTime = ct+leftover;
        controlsFilename = strcat(incrementalControlFilesDir, ...
            "processedEMG_trial", num2str(trialN), "_", ...
            num2str(secToBeWritten), "s_", num2str(increment), "inc_num", ...
            num2str(f), "leftover.sto");
    else
        finalTime = ct + increment;
        controlsFilename = strcat(incrementalControlFilesDir, ...
            "processedEMG_trial", num2str(trialN), "_", num2str(secToBeWritten), ...
            "s_", num2str(increment), "inc_num", num2str(f), ".sto");
    end
    
    % if you want out.log and err.log to be placed in myDir, must change cd
    % separately to myDir (variables don't work with cd) ; here I just put them
    % in C:\InteruserWorkspace\EMGrelated\MATLABscripts\puttingTogether\myDir
    % cd C:\InteruserWorkspace\EMGrelated\MATLABscripts\puttingTogether\myDir\;
    % so out.log, err.log are placed in myDir
    model = Model(strcat(osimDir, modelFilename));
    ft = ForwardTool(setupPath);
    %strcat(osimDir, setupFilename));
    ft.setControlsFileName(controlsFilename); % setControlsFileName() must be set before setModel(), otherwise doesn't override .xml
    ft.setInitialTime(initialTime);
    ft.setFinalTime(finalTime); % does override (even if placed after setModel ; placing before just because) in produced file, but idk what it writes if secToBeWritten < finalTime set
    ft.setModel(model); % all should override .xml
    ft.setResultsDir(resultsDir);
    ft.setOutputPrecision(20);
    ft.setSolveForEquilibrium(true);
    ft.setName(strcat("trial", num2str(trialN),"_",num2str(f)));
    %if(timing)
    %    toc % toc7 = start FD simulation
    %end
    ft.run();
    
    % display elapsed time
    %if(timing)
    %    toc % toc8 = end FD simulation
    %end
    
    radName = strcat(resultsDir, "trial",num2str(trialN),"_", num2str(f), ...
        "_states.sto");
    % delete radians states file
    if(exist(radName) == 2) % exist with no 2nd var is slower, but couldn't get exist with 2 var to work
        delete(char(radName));
    end
    "incrementalFD loop"
end
% indicate done
%figure(300);
"incrementalFD done"
% % for sci fair fig
% model = Model(modelPath);
% ft = ForwardTool(forwardToolPath);
% ft.setControlsFileName(controlsPath);
% ft.setInitialTime(initialTime);
% ft.setFinalTime(finalTime); 
% ft.setModel(model); 
% ft.setResultsDir(resultsPath);
% ft.setOutputPrecision(20);
% ft.setSolveForEquilibrium(true);
% ft.setName(outputFileName);
% ft.run();
%
end