function res=countTrials(fnListBeh)
nFiles=length(fnListBeh);
res={};
for i=1:length(fnListBeh)
  cue=readCue(fnListBeh(i));
  cueIDs=unique(cue(:,1));
  res=[res;sum(cueIDs'==cue(:,1))];
end

end
