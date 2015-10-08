function setTimeX(nPoints,tickBeg,tickEnd)
  xrng=get(gca,'xlim');
  nBin=ceil(xrng(2)-xrng(1));
  set(gca,'xtick',floor(linspace(0,nBin,nPoints)));
  set(gca,'xticklabel',linspace(tickBeg,tickEnd,nPoints));
end
