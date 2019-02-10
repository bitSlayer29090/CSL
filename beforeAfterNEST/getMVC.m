%function []=getMVC(trialN,ptN,movement)
% for trial 5, get MVC (max of MVC phase) given movement and section (pt);
% apply max of MVC 1,2,3 to parts before MVC 4,5 ; MVC 4,5 to parts after MVC 4,5

close all
clear global

trialN=5;
nMVCs=5; % number of MVCs (maximum voluntary contractions)
nMovements=4;
nChns=4;
chnMVCmovement=zeros(nChns,nMVCs,nMovements); % chnMVC(chnN,MVCx,movementY)=MVC x for chnN for movement y

load("C:\InteruserWorkspace\EMGrelated\ADInstrumentsEMG\trial5\trial5lowPassFiltered_toUseWithMATLAB.mat");
% 's'=start ; 'e'=end
% MVC sections = 4, 16
% section4
% MVC1
% ext	15-28
% fle	40-51
% rad	59-1:09 59-69
% uln	1:17-1:27 77-87
MVC1ext_s=15;
MVC1ext_e=28;
MVC1fle_s=40;
MVC1fle_e=51;
MVC1rad_s=59;
MVC1rad_e=69;
MVC1uln_s=77;
MVC1uln_e=87;
% MVC2
% ext	1:42-1:53 102-113
% fle	2:03-2:13 123-133
% rad	2:21-2:32 141-152
% uln	2:41-2:51 161-171
MVC2ext_s=102;
MVC2ext_e=113;
MVC2fle_s=123;
MVC2fle_e=133;
MVC2rad_s=141;
MVC2rad_e=152;
MVC2uln_s=161;
MVC2uln_e=171;
% MVC3
% ext	5:02-5:12 302-312
% fle	5:22-5:33 322-333
% rad	5:43-5:53 343-353
% uln	6:03-6:13 363-373
MVC3ext_s=302;
MVC3ext_e=312;
MVC3fle_s=322;
MVC3fle_e=333;
MVC3rad_s=343;
MVC3rad_e=353;
MVC3uln_s=363;
MVC3uln_e=373;
% section16
% MVC4
% ext	2-14
% fle	28-38
% rad	47-58
% uln	1:07-1:18 67-78
MVC4ext_s=2;
MVC4ext_e=14;
MVC4fle_s=28;
MVC4fle_e=38;
MVC4rad_s=47;
MVC4rad_e=58;
MVC4uln_s=67;
MVC4uln_e=78;
% MVC5
% ext	1:37-1:48 97-108
% fle	1:57-2:08 117-128
% rad	2:18-2:29 138-149
% uln	2:38-2:49 158-169
MVC5ext_s=97;
MVC5ext_e=108;
MVC5fle_s=117;
MVC5fle_e=128;
MVC5rad_s=138;
MVC5rad_e=149;
MVC5uln_s=158;
MVC5uln_e=169;

extInd=1;
fleInd=2;
radInd=3;
ulnInd=4;
MVCn_s=[MVC1ext_s, MVC2ext_s, MVC3ext_s, MVC4ext_s, MVC5ext_s;...
    MVC1fle_s, MVC2fle_s, MVC3fle_s, MVC4fle_s, MVC5fle_s;...
    MVC1rad_s, MVC2rad_s, MVC3rad_s, MVC4rad_s, MVC5rad_s;...
    MVC1uln_s, MVC2uln_s, MVC3uln_s, MVC4uln_s, MVC5uln_s];
MVCn_e=[MVC1ext_e, MVC2ext_e, MVC3ext_e, MVC4ext_e, MVC5ext_e;...
    MVC1fle_e, MVC2fle_e, MVC3fle_e, MVC4fle_e, MVC5fle_e;...
    MVC1rad_e, MVC2rad_e, MVC3rad_e, MVC4rad_e, MVC5rad_e;...
    MVC1uln_e, MVC2uln_e, MVC3uln_e, MVC4uln_e, MVC5uln_e];
%MVCn_s(ext/fle/rad/ulnInd,MVCn)

fc=1;

if(trialN==5)
    % only section4 (pt1),16 (pt10) have MVCs
    % for each MVC (1-5)
    for MVCn=1:nMVCs
        if(MVCn>0 && MVCn<4)
            sectN=4;
        elseif(MVCn>4 && MVCn<6)
            sectN=16;
        end
        
        % for each movement
        for movementN=1:4
            %movementN == ext/fle/rad/ulnInd 
            % for each channel
            for chnN=1:4
                % convert to ms
                % checked with graph compared to labChart
                figure(fc);
                fc=fc+1;
                plot(data((datastart(chnN,sectN)+(MVCn_s(movementN,MVCn)*1000)):(datastart(chnN,sectN)+(MVCn_e(movementN,MVCn)*1000))));
                hold on
                title("MVCn "+num2str(MVCn)+" movementN "+num2str(movementN)+" chnN "+num2str(chnN));
                hold off
                chnMVCmovement(chnN,MVCn,movementN)=max(data(datastart(chnN,sectN)+(MVCn_s(movementN,MVCn)*1000)):(datastart(chnN,sectN)+(MVCn_e(movementN,MVCn)*1000)));
            end
        end
    end
end
save("E:\moreR\trial5\chnMVCmovement.mat","chnMVCmovement");
