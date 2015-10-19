function idx=sortNIDByRat(rtm,sepper,method=@sum)
  if(sepper(1)!=0)  sepper=[0;sepper(:)]; end;
  if(sepper(end)!=size(rtm,2))  sepper=[sepper(:);size(rtm,2)]; end;

  idx=zeros(size(rtm,2),1);
  for i=1:length(sepper)-1;
    t=sepper(i)+1:sepper(i+1);
    idx(t)=sortNID(rtm(:,t),method)+sepper(i);
  end
end
