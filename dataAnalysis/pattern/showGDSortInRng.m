function idx=showGDSortInRng(rtm,rng, nPoints,tickBeg,tickEnd,crng='auto',method=@sum)
  idx=sortedRowsId(rtm(rng,:),method);
  imagesc(rtm(:,idx)');colorbar;caxis(crng);
  setTimeX(nPoints,tickBeg,tickEnd);
  xlabel('time');ylabel('neuron');
  %title([tltPre,'cue: ',num2str(cid)]);
end
