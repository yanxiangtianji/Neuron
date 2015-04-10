function [weight,J]=train(X,y,weight,lambda)

options = optimset('GradObj', 'on', 'MaxIter', 400);

[weight, J, exit_flag] = fminunc(@(t)(costFunctionReg(X, y, t, lambda)), weight, options);

end
