function [J, grad] = costFunctionAWCore(X,y,adj,weight,     lambdaA=0,lambdaW=0, gdFctA=1,gdFctW=1, panA=0,panW=0,refA=0,refW=0)
%lambda:    regularization parameters for cost value. It should be non-negative.
%           The larger the lambda is, the closer to zero the A/W is.
%gdFct:     gradient factor for gradient value. It should be positive.
%           When gdFct<1, the corresponding A/W value changes slower. vice versa.
%           The two gdFcts(gdFctA, gdFctW) should not be the same value (except 1).
%           They only makes sense to make one parameter changes slower/faster than the other.
%pan & ref: penalty parameter for A/W changes, and the referenced point of A/W value.
%           pan is a real scalar and ref is a vector (when pan is 0 ref is meaningless)
%           The larger the pan is, the closer the corresponding A/W is.

m = length(y);
n=length(adj);  %length(adj)==length(weight)

J = 0;
grad = zeros(2*n,1);
if(m==0)  return;end

sa=sigmoid(adj);
ea=exp(-adj.^2/2);
h=sigmoid(X*(sa.*weight));
%cost
J=sum(-y.*log(h)-(1-y).*log(1-h));
J+=lambdaW/2*sumsq(weight);
J+=lambdaA*sum(ea);
J+=panW/2*sumsq(weight-refW) + panA/2*sumsq(sa-refA);
%sumsq(t) is factor than sum(t.^2); norm(t,'fro') is faster than norm(t,2);
J/=m;
%grad
temp=X'*(h-y).*sa;
%grad-adj
grad(1:n)=gdFctA/m*(temp.*(1-sa) + lambdaA*adj.*ea + panA*(sa.*(1-sa)-refA));
%grad-weight
grad(n+1:2*n)=gdFctW/m*(temp + lambdaW*weight + panW*(weight-refW));

end
