function showShape(rtm,nRow,nCol,nids,nNeuList, nTick,tickBeg,tickEnd, dashThre=0)
  n=nRow*nCol;
  if(n<length(nids))
    error('More neurons (%d) than than can be display (%d)',length(nids),n)
  end
  nBin=size(rtm,1);
  rl=mapGNId2Local(nids,nNeuList);
  c='krgbmc';
  for i=1:min(n,length(nids));nid=nids(i);
    subplot(nRow,nCol,i);
    dash='';
    if(mean(rtm(:,nid))<dashThre)
      dash='--';
    end
    plot(rtm(:,nid),[c(rl(i,1)),dash]);
    setTimeX(nBin,nTick,tickBeg,tickEnd)
    title(sprintf('N%d (R%d-N%d)',nid,rl(i,1),rl(i,2)))
  end
end
