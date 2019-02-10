function [RMSlinEnv,fc] = websiteRMSlinEnv(mydata, winsize, wininc,fc)
% get RMS lin env from website code <http://www.sce.carleton.ca/faculty/chan/matlab/matlab_library.htm>

% testing
%load("trial4dilN0pt1chn1_rectify.mat");
%myData=EMGDataRawZeroMeanRect;

% winsize, wininc should have these values
%winsize=1000; % ms ?
%wininc=1; % ms ?

figure(fc);
fc=fc+1;
plot(mydata);
hold on

addpath('C:\InteruserWorkspace\EMGrelated\MOtoNMS v2.2\src\DataProcessing\mine\')
RMSlinEnv=getrmsfeat(mydata,winsize,wininc);
plot(RMSlinEnv)%,'-o')
title("RMS Linear Envelope");
xlabel("Time (ms)");
ylabel("Voltage (V)");
hold off
end
