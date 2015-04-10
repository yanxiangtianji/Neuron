function [J, grad] = costFunctionReg(X, y, weight, lambda)
% Initialize some useful values
m = length(y);

% You need to return the following variables correctly 
J = 0;
grad = zeros(size(weight));

h=sigmoid(X*weight);
t=weight;
%t(1)=0;
J=sum(-y.*log(h)-(1-y).*log(1-h))/m + lambda/2/m*sum(t.^2);
grad=X'*(h-y)/m+lambda/m*t;

end
