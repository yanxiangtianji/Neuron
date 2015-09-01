function info=genTrialInfo(beh,cueIDs,trialRng=0)
%*trialRng*:  0 for all trials;
%           or a vector (as index used to all used cues);
%           or a matrix (values at i-th column as index of i-th cue).
%return size=(nTri,2,nCue)

if(nargin<2)
  cueIDs=unique(beh(:,1));
end
nCue=length(cueIDs);

nTriList=histc(beh(:,1),cueIDs);
if(length(trialRng)==1 && trialRng==0)
  trialRng=1:min(nTriList);
elseif((t=sum(max(trialRng)>nTriList))!=0)
  error(['Input trial ID is larger than number of trial on ',num2str(t),' cue(s).']);
end

%transform trialRng to matrix format
if(nCue!=1 && iscolumn(trialRng) || isrow(trialRng) && length(trialRng)>nCue);
  if(isrow(trialRng)) trialRng=trialRng(:); end
  _x=trialRng;trialRng=zeros(length(_x),nCue);
  for i=1:nCue;
    trialRng(:,i)=_x;
  end
end
nTri=size(trialRng,1);

info=zeros(nTri,2,nCue);
for i=1:nCue
  info(:,:,i)=beh(find(beh(:,1)==cueIDs(i))(trialRng(:,i)),[2 3]);
end

end
