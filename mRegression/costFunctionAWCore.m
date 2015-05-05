function [J, grad] = costFunctionAWCore(X, y, adj, weight, lambdaA=0, lambdaW=0, gdFctA=1, gdFctW=1)
%lambda:    regularization parameters for cost value. It should be non-negative.
%           The larger the lambda is, the closer to zero the A/W is.
%gdFct:     gradient factor for gradient value. It should be positive.
%           When gdFct<1, the corresponding A/W value changes slower. vice versa.
%           The two gdFcts(gdFctA, gdFctW) should not be the same value (except 1).
%           They only makes sense to make one parameter changes slower/faster than the other.

m = length(y);
n=length(adj);  %length(adj)==length(weight)

J = 0;
grad = zeros(2*n,1);
if(m==0)  return;end

sa=sigmoid(adj);
ea=exp(-adj.^2/2);
h=sigmoid(X*(sa.*weight));
%cost
J=sum(-y.*log(h)-(1-y).*log(1-h))/m;
J+=lambdaW/m/2*sum(weight.^2);
J+=lambdaA/m*sum(ea);

%grad
temp=X'*(h-y).*sa/m;
%grad-adj
grad(1:n)=gdFctA*(temp.*(1-sa) + lambdaA/m*adj.*ea);
%grad-weight
grad(n+1:2*n)=gdFctW*(temp + lambdaW/m*weight);

end
