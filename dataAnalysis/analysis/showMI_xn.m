function showMI_xn(type,mi,xPoints)
  [nNeu,~,l]=size(mi);
  if(length(xPoints)!=l)  error('Unmatched xPoints and mi');  end;
  idx=find(triu(ones(nNeu),1));
  mi2=zeros(l,length(idx));
  for i=1:length(idx);
    ii=mod(idx(i)-1,nNeu)+1;
    jj=ceil(idx(i)/nNeu);
    mi2(:,i)=mi(ii,jj,:)(:);
  end;
  plot(xPoints,mi2);ylabel(type);
  title([type,' of all neuron pairs on whole period(4k seconds)'])
end
