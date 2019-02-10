% polymorphic data processing after NEST

clear all
close all

doAllMovements=false;
doOneMovement=true;
if(doOneMovement)
    movement="ext"; %"fle",uln,rad
end

doGetStats_tTest_CItif=false;
doPlotExpectedTuning=false;
doPlotExpectedCI=false;
doActualTuningCurves=true;
if(doActualTuningCurves)
    doPlotCartesian=true;
end
if(doActualTuningCurves)
    doMakeAvgOfAvg=false;
end
longDir="C:\InteruserWorkspace\DrJonesAfferentDataPlotsCurrent\revisedPlots\noMVCextractInterval1_tTestDir\";
%"E:\moreR\noMVCextractInterval1\";

addpath('C:\InteruserWorkspace\EMGrelated\MATLABscripts\polymorphicAndTrial3point1\')

movements=["ext" "fle" "rad" "uln"];

%getStats_tTest_CItif(3.1,-1,"ext");

% do all stats
if(doAllMovements)
    if(doGetStats_tTest_CItif)
        % get lots of stats
        for currMovementN=1:size(movements,2)
            currMovement=movements(currMovementN);
            getStats_tTest_CItif(3.1,-1,currMovement);
            getStats_tTest_CItif(4,1,currMovement);
            getStats_tTest_CItif(4,2,currMovement);
        end
    end
elseif(doOneMovement)
    if(doGetStats_tTest_CItif)
        [tTest2Ia_3p1, tTest2II_3p1]=getStats_tTest_CItif(3.1,-1,movement);
        [tTest2Ia_4pt1, tTest2II_4pt1]=getStats_tTest_CItif(4,1,movement);
        [tTest2Ia_4pt2, tTest2II_4pt2]=getStats_tTest_CItif(4,2,movement);
        
        save(strcat(longDir,"tTestDir\",movement,"_tTest2Ia_3p1.mat"),"tTest2Ia_3p1");
        save(strcat(longDir,"tTestDir\",movement,"_tTest2II_3p1.mat"),"tTest2II_3p1");
        save(strcat(longDir,"tTestDir\",movement,"_tTest2Ia_4pt1.mat"),"tTest2Ia_4pt1");
        save(strcat(longDir,"tTestDir\",movement,"_tTest2II_4pt1.mat"),"tTest2II_4pt1");
        save(strcat(longDir,"tTestDir\",movement,"_tTest2Ia_4pt2.mat"),"tTest2Ia_4pt2");
        save(strcat(longDir,"tTestDir\",movement,"_tTest2II_4pt2.mat"),"tTest2II_4pt2");
    end
    % to plot expected tuning curves, expected CI, need for each movement, for
    % each muscle
    if(doPlotExpectedTuning || doPlotExpectedCI)
        plotExpected(movement,longDir+"expectedGraphs\",doPlotExpectedTuning,doPlotExpectedCI);
    end
end

if(doActualTuningCurves)
    DrJonesMoBLmod4wristComparisonTuningCurves_phaseShift_noMVC_c(3.1,-1,doMakeAvgOfAvg,doPlotCartesian);
    DrJonesMoBLmod4wristComparisonTuningCurves_phaseShift_noMVC_c(4,1,doMakeAvgOfAvg,doPlotCartesian);
    DrJonesMoBLmod4wristComparisonTuningCurves_phaseShift_noMVC_c(4,2,doMakeAvgOfAvg,doPlotCartesian);
end
