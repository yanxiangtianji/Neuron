function ptn=selectPattern(rtm,lenPeriod,smr,alpha=0.05)

y=condenseIntoPeriods(rtm,lenPeriod);
sz=size(y);
n=prod(sz(2:end));
ptn=zeros(sz(2:end));

%TODO: add pattern (nPtn)

for i=1:n
  p=size(nPtn,1);
  for pid=1:nPtn; %TODO: add pattern code
    p(j)==Ptest(y(:,i),pattern(j));
  end
  [a,b]=max(p);
  if(a>alpha)
    ptn(i)=b;
  end
end

end
