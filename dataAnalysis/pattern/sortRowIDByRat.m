function idx=sortRowIDByRat(rtm_mat,nNeuSum,method=@sum)
  if(sepper(1)!=0)  sepper=[0;sepper(:)]; end;
  if(sepper(end)!=size(rtm,2))  sepper=[sepper(:);size(rtm,2)]; end;

  idx=zeros(size(rtm,2),1);
  for i=1:length(nNeuSum)-1;
    t=nNeuSum(i)+1:nNeuSum(i+1);
    idx(t)=sortRowID(rtmz(rng,t,pid),method)+nNeuSum(i);
  end
end
