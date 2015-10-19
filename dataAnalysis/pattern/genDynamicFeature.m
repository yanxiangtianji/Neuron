function ft=genDynamicFeature(rtm,sepper,method=@mean)
  [nBin,nNeu,nPha]=size(rtm);
  sepper=[0;sepper(sepper>0 & sepper<nBin)(:);nBin];
  nFea=length(sepper)-1;
  ft=zeros(nFea,nNeu,nPha);
  for pid=1:nPha;for nid=1:nNeu;for fid=1:nFea
    ft(fid,nid,pid)=method(rtm(sepper(fid)+1:sepper(fid+1),nid,pid));
  end;end;end
end
