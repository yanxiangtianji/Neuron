function showWC_Xcue(ws,cr,timeUnit2ms,rng,nid)
  nCue=size(ws,3);
  ws2=zeros(length(rng),nCue);
  for cid=1:nCue;
    for i=1:size(ws,1)
      ws2(:,cid)+=compactWC2quantile(ws(i,nid,cid),cr(i,nid,cid),rng,'linear');
    end
  end
  plot(ws2/size(ws,1)/timeUnit2ms,rng);
end
