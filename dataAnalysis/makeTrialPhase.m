function res=makeTrialPhase(trialInfo,entList,entPhase,mthd4initEvent='offset')
%Return the phase of each trial(defined in trialInfo) according to entList.
%mthd4initEvent: atitude for the initial event. can be 'no', 'offset', 'phase'
%'no': no initial event in entPhase, 1st column in entPhase is event for 1st phase.
%     (Assume all trial times are correct.)
%     Values in result are range [1,nPha].
%'offset': have initial event in entPhase, 1st column in entPhase is initial event.
%         All trials must have the initial event, but the timing in trialInfo
%         & entList are not consistent.
%         Values in result are range [1,nPha].
%'phase': have initial event in entPhase.
%         Some trials may not be correct (according to the eventList, the trials
%         do not started).
%         Values in result are range [0,nPha].


[nTri,~,nCue]=size(trialInfo);
if(nCue!=size(entPhase,1))
  error('Unmatched number of cues');
end
nPha=size(entPhase,2);
res=zeros(nTri,nCue);
offsetS2E=0;

for cid=1:nCue;
  etime=cell(nPha,1);
  for pid=1:nPha; etime(pid)=entList(find(entList(:,2)==entPhase(cid,pid)),1); end
  if(strcmp('offset',mthd4initEvent))
    offsetS2E=cell2mat(etime(1))(1:nTri)-trialInfo(:,1,cid);
  end
  tbeg=trialInfo(:,1,cid)+offsetS2E;
  tend=trialInfo(:,2,cid)+offsetS2E;
  for pid=1:nPha
    et=cell2mat(etime(pid))';
    tids=find(any(tbeg<=et & et<tend,2));
    res(tids,cid)=pid;
  end
end

if(strcmp('no',mthd4initEvent))
  res+=1;
end

end
