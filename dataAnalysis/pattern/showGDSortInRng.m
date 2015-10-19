function idx=showGDSortInRng(rtm,rng, nPoints,tickBeg,tickEnd,crng='auto',method=@sum)
  idx=sortNID(rtm(rng,:),method);
  showGD_core(rtm(:,idx),nPoints,tickBeg,tickEnd,crng);
  %title([tltPre,'cue: ',num2str(cid)]);
end
