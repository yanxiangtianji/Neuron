function res=makeTrialPhase(trialInfo,event,entPhase,offsetS2E=0)

[nTri,~,nCue]=size(trialInfo);
if(nCue!=size(entPhase,1))
  error('Unmatched number of cues');
end
nPha=size(entPhase,2);
res=zeros(nTri,nCue); %values are in range [0,nPha]

for cid=1:nCue;
  etime=cell(nPha,1);
  for pid=1:nPha; etime(pid)=event(find(event(:,2)==entPhase(cid,pid)),1);  end
  for tid=1:nTri;
    tbeg=trialInfo(tid,1,cid)+offsetS2E;
    tend=trialInfo(tid,2,cid)+offsetS2E;
    for pid=1:nPha;
      et=cell2mat(etime(pid));
      if(!isempty(find(tbeg<=et & et<tend)))
        res(tid,cid)=pid;
      end
    end
  end
end

end
