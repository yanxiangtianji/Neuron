function idx=showGD_core(rtm, nPoints,tickBeg,tickEnd,crng='auto')
  imagesc(rtm');colorbar;caxis(crng);
  setTimeX(nPoints,tickBeg,tickEnd);
  xlabel('time');ylabel('neuron');
end
