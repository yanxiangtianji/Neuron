function res=findEventTimeInTrial(entList,trialInfo,entPhase)
%give: eventList = size(nEvt,2). 1st column is timepoint, 2nd column is event ID
%     trialInfo = size(nTri,2,nCue).
%     entPhase = size(nCue,nPha).
%return: res = size(nTri,nPha,nCue). when a event doesn't happen, its value=NaN. otherwise value=timepoint

%nEvt=size(eventList,1);
nTri=size(trialInfo,1);
[nCue,nPha]=size(entPhase);
if(nCue!=size(trialInfo,3))
  error('number of cue do not match in trailInfo(%d) and entPhase(%d).',size(trialInfo,3),nCue)
end

res=zeros(nTri,nPha,nCue)+NaN;

for cid=1:nCue;
  tbeg=trialInfo(:,1,cid);
  tend=trialInfo(:,2,cid);
  for pid=1:nPha
    et=entList(find(entList(:,2)==entPhase(cid,pid)),1)';%row vector
    mat=tbeg<=et & et<tend;
    tids=find(any(mat,2));
    [i,j,~]=find(mat);
    [tids,idx]=unique(i,"first");
    v=et(j(idx));
    res(tids,pid,cid)=v;
  end
end


end
