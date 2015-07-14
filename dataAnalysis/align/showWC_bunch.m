function showWC_bunch(ws,cr,timeUnit2ms,nid,cid,rng)
  hold all;
  ws2=zeros(length(rng),1);
  for i=1:size(ws,1)
    showWC(ws,cr,timeUnit2ms,[i,nid,cid]);
    ws2+=compactWC2quantile(ws(i,nid,cid),cr(i,nid,cid),rng,'linear');
  end
  plot(ws2/size(ws,1)/timeUnit2ms,rng,'g','linewidth',4);
%  xlabel('window size (ms)');ylabel('coverage');grid;
  hold off;
end
