function dataList=pickTrial(raw,trialInfo)
%*trialInfo*: size=(nTri,2,nCue), (i,1/2,j)->start/finish time of t-th trial of j-th cue
%dataList=cell(nTri,nNeu,nCue);

[nTri,~,nCue]=size(trialInfo);
nNeu=length(raw);

dataList=cell(nTri,nNeu,nCue);
for i=1:nCue;for j=1:nTri;
  dataList(j,:,i)=pickRawFromRng(raw,trialInfo(j,1,i),trialInfo(j,2,i));
end;end;

end
