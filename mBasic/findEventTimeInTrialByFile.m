function entTime=findEventTimeInTrialByFile(fn_b,fn_e,cid,entPhase,offMismatch=0,consecutive=false,onlyValid=false)
%give: fn_b, fn_e = files for behavior and event.
%     cids = a scalar for the cue's ID we care
%     entPhase = length(nPha).
%     offMismatch = a scalar for the time mismatch between fn_b & fn_e
%     consecutive = false: events are independent; true: later event are qualified by previous event
%     onlyValid = false: retun all trials; true: just return trials with all events
%return: entTime = zeros(nTri,nPha). when a event doesn't happen, its value=NaN. otherwise value=timepoint

nPha=length(entPhase);

%entTime=zeros(nTri,nPha);

cue=readCue(fn_b);
nTriAll=sum(cue(:,1)==cid);
trialInfo=genTrialInfo(cue,cid,1:nTriAll,false);
trialInfo(:,1)-=abs(offMismatch); %for error tolerance (mismatch between fn_b & fn_e)

entList=readEvent(fn_e);

entTime=findEventTimeInTrial(entList,trialInfo,entPhase,consecutive);
if(onlyValid)
  idx=find(all(isnan(entTime)==0,2));
  entTime=entTime(idx,:);
end

end
