function [adj, weight,J]=trainOneAW(idx,X,y,adj,weight,lambdaA,lambdaW)

n=length(adj);
options = optimset('GradObj', 'on', 'MaxIter', 400);

[t,J,exit_flag]=fminunc(@(t)(costFunctionAW(X,y,t(1:n),t(n+1:end),lambdaA,lambdaW)), [adj;weight], options);

adj=(t(1:n)>=0.5);
adj(idx)=0;
weight=t(n+1:end);
weight(idx)=0;

end
