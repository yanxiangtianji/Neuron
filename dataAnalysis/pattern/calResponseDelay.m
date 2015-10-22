function cp=calResponseDelay(rtm,threshold,startIdx)
  [~,nNeu,nPha]=size(rtm);
  cp=zeros(nNeu,nPha);
  for nid=1:nNeu; for pid=1:nPha
    cp(nid,pid)=findChangePoint(rtm(:,nid,pid),startIdx,threshold)-startIdx+1;
  end;end;
end
