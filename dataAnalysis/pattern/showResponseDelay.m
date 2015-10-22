function showResponseDelay(cp,threshold,nPoints,nTick,tickBeg,tickEnd)
  [nNeu,nPha]=size(cp);
  plot(cp);title(['response delay (threshold=',num2str(threshold),')']);
  grid on;
  ylim([0,nPoints]);xlim([0 nNeu]);xlabel('neuron');
  set(gca,'ytick',linspace(0,nPoints,nTick));
  set(gca,'yticklabel',linspace(tickBeg,tickEnd,nTick))
  ylabel('delay time (s)');
  legend({'tone','lever','well'});
end
