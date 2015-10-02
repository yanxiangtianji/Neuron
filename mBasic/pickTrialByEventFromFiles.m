function [dataList,nNeuList]=pickTrialByEventFromFiles(fnl_s,fnl_b,fnl_e,
    cid,nTri,entPhase,offBef,offAft,offMis=0,consecutive=false)
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
  times=findEventTimeInTrialByFile(fnl_b(i),fnl_e(i),cid,entPhase,offMis,consecutive,true);
  times=times(1:nTri,:);
  
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
