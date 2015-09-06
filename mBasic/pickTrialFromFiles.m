function dataList=pickTrialFromFiles(fnListSpike,fnListBeh,cueIDs,trialRng,timeOffBeg=0,timeOffEnd=0)
%*cueIDs*: can be an integer or a vector.
%*trialRng*:or a vector (as index used to all used cues);
%           or a matrix (values at i-th column as index of i-th cue).
%dataList=cell(nTri,nNeu,nCue);

if(numel(fnListSpike)!=numel(fnListBeh))
  error('Unmatched number of spike(',num2str(numel(fnListSpike)),') and behavior(',num2str(numel(fnListBeh)),') files.');
elseif(nargin<3)
  error('cueIDs and trialRng are not input.');
elseif(nargin<4)
  error('trialRng is not input.');
end

nCue=length(cueIDs);

nTri=size(trialRng,1);

nFile=numel(fnListSpike);
dataList={};
for i=1:nFile;
  trialInfo=genTrialInfo(readCue(fnListBeh(i)),cueIDs,trialRng);
  trialInfo(:,1,:)+=timeOffBeg; trialInfo(:,2,:)+=timeOffEnd;
  t=pickTrial(readRaw(fnListSpike(i)),trialInfo);
  dataList=[dataList,t];
end


end
