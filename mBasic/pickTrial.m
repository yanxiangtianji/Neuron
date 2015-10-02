function dataList=pickTrial(raw,trialInfo)
%*trialInfo*: size=(nTri,2,nCue), (i,1/2,j)->start/finish time of i-th trial of j-th cue
%dataList=cell(nTri,nNeu,nCue);

[nTri,~,nCue]=size(trialInfo);
nNeu=length(raw);

dataList=cell(nTri,nNeu,nCue);
for j=1:nCue;for i=1:nTri;
  dataList(i,:,j)=pickRawFromRng(raw,trialInfo(i,1,j),trialInfo(i,2,j),true);
end;end;

end
