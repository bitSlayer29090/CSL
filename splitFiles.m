function [nSplitFiles] = splitFiles(toSplitFilename,splitOutputDir, ...
splitIncrement, moreMoBL)

% if need to split large file into multiple files of 100 ms each ,
% for making directional tuning curve

incrementCount=10;
nSplitFiles=0;
last=1;
splitIndicies=[];
splitTimes=[];
toSplitFile=importdata(toSplitFilename);
sizeF=size(toSplitFile.data);
for p=1:sizeF(1)
    if(toSplitFile.data(p)*1000>incrementCount) % convert to ms
        splitIndiciesSize=size(splitIndicies);
        splitIndicies=[splitIndicies " " num2str(p)];
        splitTimesSize=size(splitTimes);
        splitTimes=[splitTimes " " num2str(toSplitFile.data(p))];
        incrementCount=incrementCount+splitIncrement;
        nSplitFiles=nSplitFiles+1;
        nextFileData=toSplitFile.data(last:p,:);
        %  write nextFileData to new file
        sizeF=size(nextFileData);
        if(~moreMoBL)
            splitFile=fopen(strcat(splitOutputDir,fileStr,"_",num2str(nSplitFiles),"_states_degrees.mot"),'w');
        else
            splitFile=fopen(strcat(splitOutputDir,num2str(nSplitFiles),"_states_degrees.mot"),'w');
        end
            %fprintf(splitFile, 'hi');
        for q=1:sizeF(1)
            for r=1:sizeF(2)
                if(r==sizeF(2))
                    fprintf(splitFile, '%.9f', nextFileData(q,r));
                else
                    fprintf(splitFile, '%.9f\t', nextFileData(q,r));
                end
            end
            %fprintf(splitFile,"a new line?");
            if(not(q==sizeF(1)))
                fprintf(splitFile,"\n");
            end
        end
        last=p;
        fclose(splitFile);
    end
end
%splitIndicies
%splitTimes
end