function [weight,J]=trainW(idx,X,y,weight,lambda)

options = optimset('GradObj', 'on', 'MaxIter', 400);

[weight, J, exit_flag] = fminunc(@(t)(costFunctionW(X, y, t, lambda)), weight, options);
weight(idx)=0;

end
