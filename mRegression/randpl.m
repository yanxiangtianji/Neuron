function res=randpl(N,M=1,Xmin=1,alpha=2.5)
% power_law_distribution
% define domain: [Xmin, +inf).
% f(X=x)=C*x^(-alpha);	C=(alpha-1)/Xmin^(1-alpha).
% F(x)=cdf(x)=P(X<x)=1-(x/Xmin)^(1-alpha).
% x=invF(y)=Xmin*(1-y)^(1/(1-alpha)).

%check:
if(Xmin<1 || alpha<=1)
  error ("randpl: Xmin should >=1 and alpha should >1.\nIf you need to start from 0, call randpl(...)-1");
end

%work:
exp=1.0/(1-alpha);
y=rand(N,M);
res=Xmin*(1-y).^exp;

end
