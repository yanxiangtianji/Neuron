function showSI_xc_one(interval,tid,nid)
  nCue=size(interval,3);
  xmax=0;
  for i=1:nCue;cid=i;
    t=cell2mat(interval(tid,nid,cid));if(isempty(t));t=0;end;
    subplot(2,2,i);hist(t,20);xmax=max(xmax,get(gca,'xlim')(2));
  end;
  %unify the x axis
  for i=1:nCue;
    subplot(2,2,i);xlim([0,xmax]);set(gca,'xtick',fix(linspace(0,xmax,4)));
  end
end
