function setTimeX(nBin,nPoints,tickBeg,tickEnd)
  set(gca,'xtick',floor(linspace(0,nBin,nPoints)));
  set(gca,'xticklabel',linspace(tickBeg,tickEnd,nPoints));
end
