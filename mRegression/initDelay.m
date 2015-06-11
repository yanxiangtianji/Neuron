function D=initDelay(n,method,unit,meanValue,minimal=0)

if(meanValue<minimal)
  error('Invalid parameters: meanValue<minimal');
end

switch(method)
  case {'const','constant'}
  %constant at meanValue:
    D=zeros(n,n)+meanValue;
  case {'uni','uniform'}
  %uniform in [minimal, 2*meanValue-minimal]:
    x=meanValue-minimal;
    D=rand(n,n)*2*x;
    D=round(D/unit)*unit+minimal;
  case {'normal','gaussian'}
  %normal distribution i.e., N(meanValue,sigma^2), 3*sigma=meanValue-minimal
  %bound those<minimal to minimal
    D=randn(n,n)*(meanValue-minimal)/3+meanValue;
    D=max(minimal,round(D/unit)*unit);
  case {'pl','powerlaw','power-law'}
  %power-law distribution i.e., PL(alpha=2.5, Xmin=1)+minimal
    alpha=2.5;
    %mean=(alpha-1)/(alpha-2)*Xmin
    scale=meanValue/(alpha-1)*(alpha-2);
    D=randpl(n,n,1,alpha)*scale;
    D=round(D/unit)*unit+minimal;
  case {'exp','exponential'}
  %exponential distribution i.e., Exp(meanValue-minimal)+minimal
    D=exprnd(meanValue-minimal,n,n);
    D=round(D/unit)*unit+minimal;
  otherwise
    error(['Unknown method: ',method]);
end
for i=1:n   D(i,i)=0;   end

end