function res=condenseIntoPeriods(rtm,sepperORinterval)
%condense values in the first dimension into several periods (whose length is given).
%sepper gives full range (both points, length>=2)
  sz=size(rtm);% nBin=sz(1);% nNeu=sz(2);
  nPer=length(sepperORinterval)-1;
  if(nPer==0);%sepper is one scalar, which means fixed interval
    sepper=[0;sepperORinterval:sepperORinterval:sz(2)];
  else
    sepper=sepperORinterval;
    sepper(1)=max(0,sepper(1)-1);
  end
  sz(1)=nPer;
  res=zeros(sz);
  for i=1:nPer;
    res(i,:,:)=mean(rtm(sepper(i)+1:sepper(i+1),:,:));
  end
end
