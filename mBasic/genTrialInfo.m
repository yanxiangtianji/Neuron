function info=genTrialInfo(beh,cueIDs,trialRng=0,withRest=false)
%*trialRng*:  0 for all trials;
%           or a vector (as index used for all valid cues);
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
  error(['Maximal input trial ID is larger than the number of trial on %d cue(s).',t]);
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

if(withRest==false)
  info=zeros(nTri,2,nCue);
else
  info=zeros(nTri,2,2*nCue);
end

for i=1:nCue
  t=beh(find(beh(:,1)==cueIDs(i))(trialRng(:,i)),[2 3 4]);
  info(:,:,i)=t(:,[1,2]);
  if(withRest==true)
    t2=genRestTrials(info(:,2,i),t(:,3),info(:,2,i)-info(:,1,i));
    if(size(t2,1)!=nTri)
      t3=beh(find(beh(:,1)==cueIDs(i)),[2 3 4]);
      t2=genRestTrials(t3(:,2),t3(:,3),t3(:,2)-t3(:,1))(1:nTri,:);
      if(size(t2,1)!=nTri)
        error('No enough continous resting period with enough length.');
      end
    end
    info(:,:,i+nCue)=t2;
  end
end

end
