function cor=calCorr(rtm,nids)
  nNeu=length(nids);
  cor=zeros(nNeu);
  for i=1:nNeu; for j=1:nNeu;
    cor(i,j)=corr(rtm(:,nids(i)),rtm(:,nids(j)));
  end;end
end
