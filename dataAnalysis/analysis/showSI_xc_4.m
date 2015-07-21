function showSI_xc_4(interval,nBin=20)
  nCue=length(interval);
  xmax=0;ymax=0;
  for i=1:nCue;cid=i;
    t=cell2mat(interval(cid));if(isempty(t));t=0;end;
    subplot(2,2,i);hist(t,nBin);
    xmax=max(xmax,get(gca,'xlim')(2));
    ymax=max(ymax,get(gca,'ylim')(2));
  end;
  %unify the x axis
  for i=1:nCue;
    subplot(2,2,i);xlim([0,xmax]);ylim([0,ymax]);
    set(gca,'xtick',fix(linspace(0,xmax,4)));
  end
end
