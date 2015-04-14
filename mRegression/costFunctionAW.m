function [J, grad] = costFunctionAW(X, y, adj, weight, lambda)
% Initialize some useful values
m = length(y);
n=length(adj);  %length(adj)==length(weight)

J = 0;
grad = zeros(2*n,1);

sa=sigmoid(adj);
h=sigmoid(X*(sa.*weight));
%cost
J=sum(-y.*log(h)-(1-y).*log(1-h))/m + lambda/2/m*sum(weight.^2);
%grad
temp=X'*(h-y).*sa/m;
%grad-adj
grad(1:n)=temp.*(1-sa);
%grad-weight
grad(n+1:end)=temp+lambda/m*weight;

end
