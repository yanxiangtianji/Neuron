function [J, grad] = costFunctionW(X, y, weight, lambda)
% Initialize some useful values
m = length(y);

% You need to return the following variables correctly 
if(m==0)
  J = 0;
  grad = zeros(size(weight));
  return;
end

h=sigmoid(X*weight);
J=sum(-y.*log(h)-(1-y).*log(1-h))/m + lambda/2/m*sum(weight.^2);
%'J',size(J)
grad=X'*(h-y)/m+lambda/m*weight;

end
