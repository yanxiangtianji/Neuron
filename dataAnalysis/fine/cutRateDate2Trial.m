function rt=cutRateDate2Trial(rate,cueBinBeg,cueBinEnd,tids,nids,cids)
  nTri=length(tids);nNeu=length(nids);nCue=length(cids);
  vecLength=cueBinEnd(1,1)-cueBinBeg(1,1)+1;
  rt=zeros(vecLength,nTri,nNeu,nCue);
  for i=1:nCue;cid=cids(i); for j=1:nNeu;nid=nids(j); for k=1:nTri;tid=tids(k);
    rt(:,k,j,i)=rate(cueBinBeg(tid,cid):cueBinEnd(tid,cid),nid);
  end;end;end;
end
