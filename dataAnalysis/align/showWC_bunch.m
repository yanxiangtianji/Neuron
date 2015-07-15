function showWC_bunch(ws,cr,timeUnit2ms,nid,cid,rng,mode='bunch',mode_arg=0)
  %mode can be 'bunch' or 'error-bar
  nPair=size(ws,1);
  if(strcmp(mode,'bunch'))
    if(mode_arg<=0 || mode_arg>nPair)
      N=nPair;
    else;
      N=mode_arg;
    end
    ws2=zeros(length(rng),1);
    hold all;
    for i=1:N
      showWC(ws,cr,timeUnit2ms,[i,nid,cid]);
      ws2+=compactWC2quantile(ws(i,nid,cid),cr(i,nid,cid),rng,'linear');
    end
    for i=N+1:nPair
      ws2+=compactWC2quantile(ws(i,nid,cid),cr(i,nid,cid),rng,'linear');
    end
    plot(ws2/nPair/timeUnit2ms,rng,'g','linewidth',4);
    hold off;
  else  %error-bar
    ws1s=zeros(length(rng),1);
    ws2s=zeros(length(rng),1);
    for i=1:nPair
      t=compactWC2quantile(ws(i,nid,cid),cr(i,nid,cid),rng,'linear');
      ws1s+=t;
      ws2s+=t.^2;
    end
    m=ws1s/nPair;s=sqrt(ws2s/nPair-m.^2);
    errorbar(m,rng,s,'>');ylim([0 1]);xlim([0 inf]);
  end
%  xlabel('window size (ms)');ylabel('coverage');grid;
end
