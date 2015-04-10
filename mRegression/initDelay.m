function D=initDelay(n,minimal,unit,method='constant')

switch(method)
  case {'const','constant'}
  %constant at minimal:
    D=zeros(n,n)+minimal;
  case {'uni','uniform'}
  %uniform in [minimal,minimal+9*unit]:
    D=floor(rand(n,n)*10)*unit+minimal;
  case {'normal','gaussian'}
  %normal distribution i.e., N(minimal+10*unit,(3*unit)^2), bound those<minimal to minimal
    D=max(0,ceil(randn(n,n)*3+10))*unit+minimal;
  case {'pl','powerlaw','power-law'}
  %power-law distribution i.e., PL(2)+minimal
    D=ceil(randpl(n,n,1,2))*unit+minimal;
  case {'exp','exponential'}
  %exponential distribution i.e., E(1)+minimal
    D=ceil(rande(n,n))*unit+minimal;
  otherwise
    error(['Unknown method: ',method]);
end
for i=1:n   D(i,i)=0;   end

end