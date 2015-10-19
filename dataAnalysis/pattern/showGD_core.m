function idx=showGD_core(rtm, nPoints,tickBeg,tickEnd,crng='auto')
  imagesc(rtm');colorbar;caxis(crng);
  if(nargin>=4)
    setTimeX(nPoints,tickBeg,tickEnd);
  end
  xlabel('time');ylabel('neuron');
end
