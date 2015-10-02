function [dataList,nNeuList]=pickTrialByEventFromFiles(fnl_s,fnl_b,fnl_e,cid,nTri,entPhase,offBef,offAft)
%dataList=cell(nTri,nNeu,nPha);

nFile=numel(fnl_s);
if(nFile!=numel(fnl_b) || nFile!=numel(fnl_e))
  error('number of file mismatch for SpikeList(%d), BehaviorList(%d), EventList(%d).',
      nFile,numel(fnl_b),numel(fnl_e))
end
nPha=length(entPhase);

dataList=cell(nTri,0,nPha);
nNeuList=zeros(nFile,1);
for i=1:nFile
  cue=readCue(fnl_b(i));
  nTriAll=sum(cue(:,1)==cid);
  trialInfo=genTrialInfo(cue,cid,1:nTriAll,false);
  trialInfo(:,1)-=max(abs(offBef),abs(offAft)); %for error tolerance (time mismatch between fnl_b & fnl_e)
  entList=readEvent(fnl_e(i));
  %times=size(nTri,nPha)
  times=findEventTimeInTrial(entList,trialInfo,entPhase);
  tids=find(all(isnan(times)==0,2));
%    length(tids)  %show number of valid trials.
  
  times=times(tids(1:nTri),:);
  trialInfo=zeros(nTri,2,nPha);
  for pid=1:nPha
    trialInfo(:,1,pid)=times(:,pid)+offBef;
    trialInfo(:,2,pid)=times(:,pid)+offAft;
  end
  t=pickTrial(readRaw(fnl_s(i)),trialInfo);
  dataList=[dataList,t];
  nNeuList(i)=size(t,2);
end


end
