function res=condenseIntoPeriods(rtm,lenPeriod)
%condense values in the first dimension into several periods (whose length is given).
  sz=size(rtm); nBin=sz(1);% nNeu=sz(2);
  nPer=ceil(nBin/lenPeriod);
  sz(1)=nPer;
  res=zeros(sz);
  for i=1:nPer;
    res(i,:,:)=mean(rtm(1+(i-1)*lenPeriod:i*lenPeriod,:,:));
  end
end
