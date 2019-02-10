function [nFiles,leftover] = writeIncrementalControlsFiles(myModel,trialN,...
    dilatedD, secToBeWritten, incrementalControlsFilesDir, increment, removeMuscleChnN)
%% print OS formatted to file in 7 s increments

% lab chart mV, ms ; matlab V, ms
nRows = increment*1000 + 8; % + 8 for header and t, muscle names

if(myModel=="MoBLmod4model") %MoBL model MoBL_ARMS_module2_4_allmuscles.osim
    nCols = 51; % also equal to len(muscleNames) below
    muscleNames = {'time','DELT1','DELT2','DELT3','SUPSP','INFSP','SUBSC',...
        'TMIN','TMAJ','PECM1','PECM2','PECM3','LAT1','LAT2','LAT3','CORB',...
        'TRIlong','TRIlat','TRImed','ANC','SUP','BIClong','BICshort','BRA',...
        'BRD','ECRL','ECRB','ECU','FCR','FCU','PL','PT','PQ','FDSL','FDSR',...
        'FDSM','FDSI','FDPL','FDPR','FDPM','FDPI','EDCL','EDCR','EDCM','EDCI',...
        'EDM','EIP','EPL','EPB','FPL','APL'};
elseif(myModel=="wristModel")
    nCols = 26; % also equal to len(muscleNames) below
    muscleNames = {'time', 'FCR','FCU','ECU_pre-surgery','ECU_post-surgery',...
        'EDM','ECRB','ECRL','FDSI','FDSM','FDSR','FDSL','FDPI','FDPM','FDPR',...
        'FDPL','EDCL','EDCR','EDCM','EDCI','FPL','APL','EPB','EPL','EIP','PL'};
else
    "invalid .osim model"
end

% activeMuscles muscles must be in order of dilatedD columns
% obv, doesnt change no matter which model
if trialN == 1
    activeMuscles = {'ECRL'};
elseif trialN == 2
    activeMuscles = {'ECRL', 'FCR', 'ECU'};
elseif trialN == 3
    activeMuscles = {'ECU', 'FCR', 'ECRL', 'EDCM'};
elseif trialN == 3.1
    if(removeMuscleChnN==1)
        activeMuscles = {'ECRB', 'EDCM'};
    elseif(removeMuscleChnN==2)
        activeMuscles = {'FCR', 'EDCM'};
    elseif(removeMuscleChnN==3)
        activeMuscles = {'FCR', 'ECRB'};
    elseif(removeMuscleChnN==4)
        error("trial3.1 has no chn4 to remove but removeMuscleChnN==4");
    elseif(removeMuscleChnN==0)
        activeMuscles = {'FCR', 'ECRB', 'EDCM'};
    end
elseif trialN == 4
    if(removeMuscleChnN==1)
        activeMuscles = {'ECRB', 'FCU', 'FCR'};
    elseif(removeMuscleChnN==2)
        activeMuscles = {'EDCM', 'FCU', 'FCR'};
    elseif(removeMuscleChnN==3)
        activeMuscles = {'EDCM', 'ECRB', 'FCR'};
    elseif(removeMuscleChnN==4)
        activeMuscles = {'EDCM', 'ECRB', 'FCU'};
    elseif(removeMuscleChnN==0)
        activeMuscles = {'EDCM', 'ECRB', 'FCU', 'FCR'};
    end
end

sizeTotal = size(dilatedD);
for i=1:sizeTotal(1,2)
    muscleValues(1, i) = {dilatedD(:, i)};
end
muscleMap = containers.Map(activeMuscles, muscleValues);

% reproduce certain columns in order
% ECR'L' data into ECRL, ECRB cols
% EDC'M' into EDCL, EDCR, EDCM, EDCI
if trialN == 1
    muscleMap('ECRB') = muscleMap('ECRL');
elseif trialN == 2
    muscleMap('ECRB') = muscleMap('ECRL');
elseif trialN == 3 % substitute multiplied ECU for EDC, take out
    muscleMap('ECRB') = muscleMap('ECRL');
    %muscleMap('EDCM') = {dilatedD(:,4)};
    muscleMap('EDCL') = {dilatedD(:,4)};
    muscleMap('EDCR') = {dilatedD(:,4)};
    muscleMap('EDCI') = {dilatedD(:,4)};
    %elseif trialN == 3.1 % substitute multiplied ECU for EDC, take out
    % muscleMap('ECRB') = muscleMap('ECRL'); % ECRB ECRL not really
    % physically connected thus no reason to put EMG of one into other
    % channel7 = 'FCR' > FCR; channelN = 2 z
    % channel8 = 'ECR' > ECRB,EDC ; channelN = 3
end

leftover = mod(secToBeWritten, increment);
nFiles = (secToBeWritten-leftover)/increment;

%{
pseudo
t=0
startS=0
endS=startS+increment
for each file in nFiles
    open file
    write header
    // t = last t
    pick up in the matrix where you left off
    //controls file has 1000 rows/1 s
    for m=leftOff:(leftOff+7*1000)
        stuff
toc
%}

t=0.000;
startS = 0;
endS = startS + increment;
for h=1:nFiles
    % put comment start here to produce only leftover .sto
    myFilename = strcat(incrementalControlsFilesDir, "processedEMG_trial", ...
        num2str(trialN), "_", num2str(secToBeWritten), "s_", ...
        num2str(increment), "inc_num", num2str(h), ".sto");
    file = fopen(myFilename,'w');
    
    % print header
    fprintf(file, 'controls\r\n'); %only microsoft notepad requires \r\n compared to \n
    fprintf(file, 'version=1\r\n');
    fprintf(file, 'nRows=%d\r\n', nRows);
    fprintf(file, 'nColumns=%d\r\n', nCols);
    fprintf(file, 'inDegrees=no\r\n');
    fprintf(file, 'endheader\r\n');
    
    % print t, muscle names
    for k=1:length(muscleNames)
        if(k==1)
            fprintf(file,'%s',muscleNames{k});
        else
            fprintf(file,'\t%s',muscleNames{k});
        end
    end
    
    % muscleNames array; for each step, for each in muscleNames
    % if name in activeMuscles, use activeMuscle's mapped array
    % else print 0
    
    % print data
    %tic;
    % put comment end here to produce only leftover .sto
    for m=(startS*1000):(endS*1000)
        % put comment start here to produce only leftover .sto
        %m
        for j=muscleNames
            if(strcmp(j,'time'))
                fprintf(file,'\r\n');
                fprintf(file,'%.3f',t);
            elseif(muscleMap.isKey(j{1}))
                a = {muscleMap(j{1})};
                %a{1,1}(m)
                %myA2 = {a}{1}(m); % if change to a{1}(k), a changes to 1x1 cell
                %myA2 = -1;
                %a = -1;
                %myA{1}(k)
                if(iscell(a{1,1}))
                    fprintf(file, '\t%.9f', a{1,1}{1,1}(m+1));
                elseif(~iscell(a{1,1}))
                    fprintf(file, '\t%.9f', a{1,1}(m+1));
                end
            else
                fprintf(file, '\t%d', 0.000);
            end
        end
        m;
        % put comment end here to produce only leftover .sto
        t = t + 0.001;
    end
    % put comment start here to produce only leftover .sto
    fclose(file);
    %toc
    % put comment end here to produce only leftover .sto
    m;
    t;
    endS;
    startS = startS + increment;
    endS = endS + increment;
    "writeIncrementalControlsFiles loop"
end

% writing leftover
if(not(leftover==0))
    nFiles=nFiles+1;
    endS = startS + leftover;
    h = h+1;
    %{
leftover
t
startS
endS
f
    %}
    
    nRows = leftover*1000 + 8;
    myFilename = strcat(incrementalControlsFilesDir, "processedEMG_trial", ...
        num2str(trialN), "_", num2str(secToBeWritten), "s_", num2str(increment), ...
        "inc_num", num2str(h), "leftover.sto");
    file = fopen(myFilename,'w');
    
    % print header
    fprintf(file, 'controls\r\n'); %only microsoft notepad requires \r\n compared to \n
    fprintf(file, 'version=1\r\n');
    fprintf(file, 'nRows=%d\r\n', nRows);
    fprintf(file, 'nColumns=%d\r\n', nCols);
    fprintf(file, 'inDegrees=no\r\n');
    fprintf(file, 'endheader\r\n');
    
    % print t, muscle names
    for k=1:length(muscleNames)
        if(k==1)
            fprintf(file,'%s',muscleNames{k});
        else
            fprintf(file,'\t%s',muscleNames{k});
        end
    end
    
    % muscleNames array; for each step, for each in muscleNames
    % if name in activeMuscles, use activeMuscle's mapped array
    % else print 0
    
    % print data
    %tic;
    
    for m=(startS*1000):(endS*1000)
        %m
        for j=muscleNames
            if(strcmp(j,'time'))
                fprintf(file,'\r\n');
                fprintf(file,'%.3f',t);
            elseif(muscleMap.isKey(j{1}))
                a = {muscleMap(j{1})};
                %a{1,1}(m)
                %myA2 = {a}{1}(m); % if change to a{1}(k), a changes to 1x1 cell
                %myA2 = -1;
                %a = -1;
                %myA{1}(k)
                if(iscell(a{1,1}))
                    fprintf(file, '\t%.9f', a{1,1}{1,1}(m+1));
                elseif(~iscell(a{1,1}))
                    fprintf(file, '\t%.9f', a{1,1}(m+1));
                end
            else
                fprintf(file, '\t%d', 0.000);
            end
        end
        t = t + 0.001;
    end
    fclose(file);
end
"writeIncrementalControlsFiles done"
%toc