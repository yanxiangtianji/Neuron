function res=makeTrialEventTable(trialInfo,event,eIdTbl,offsetS2E=0)

[nTri,~,nCue]=size(trialInfo);
if(nCue!=size(eIdTbl,1))
  error('Unmatched number of cues');
end
nPha=size(eIdTbl,2);
res=zeros(nTri,nPha-1,nCue);

for cid=1:nCue;
  tbeg=event(find(event(:,2)==eIdTbl(cid,1)),1);
  tend=event(find(event(:,2)==eIdTbl(cid,2)),1);
  for tid=1:nTri;
    t1=trialInfo(tid,1,cid)+offsetS2E;
    t2=trialInfo(tid,2,cid)+offsetS2E;
    b1=!isempty(find(t1<=tbeg & tbeg<t2));
    b2=!isempty(find(t1<=tend & tend<t2));
    res(tid,1,cid)=b1 && b2;
  end
end

end
