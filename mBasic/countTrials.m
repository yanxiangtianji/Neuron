function res=countTrials(fnListBeh)
nFiles=length(fnListBeh);
res=[];
for i=1:length(fnListBeh)
  cue=readCue(fnListBeh(i));
  res=[res;length(find(cue(:,1)==1)),length(find(cue(:,1)==2))];
end

end
