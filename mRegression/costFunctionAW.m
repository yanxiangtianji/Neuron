function [J, grad] = costFunctionAW(X, y, adj, weight, lambda)
% Initialize some useful values
m = length(y);
n=length(adj);  %length(adj)==length(weight)

J = 0;
grad = zeros(2*n,1);

h=sigmoid(X*(sigmoid(adj).*weight));
J=sum(-y.*log(h)-(1-y).*log(1-h))/m + lambda/2/m*sum(weight.^2);
grad=X'*(h-y)/m+lambda/m*weight;

end
