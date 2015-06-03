%function [J, grad] = costFunctionAW(X, y, adj, weight, lambdaA, lambdaW)
function [J, grad] = costFunctionWGivenA(X, y, adjBin, weight, lambdaW)
% Initialize some useful values
m = length(y);
n=length(adj);  %length(adj)==length(weight)

if(m==0)
  J = 0;
  grad = zeros(n,1);
  return;
end

%sa=sigmoid(adj);
h=sigmoid(X*(adjBin.*weight));
%cost
J=sum(-y.*log(h)-(1-y).*log(1-h))/m;
J+=lambdaW/m/2*sum(weight.^2);
%J+=lambdaA/m*sum(ea);

%grad
temp=X'*(h-y).*sa/m;
%grad-adj
%grad(1:n)=temp.*weight.*(1-sa) - lambdaA/m*adj.*ea
%grad-weight
grad=temp + lambdaW/m*weight;

end
