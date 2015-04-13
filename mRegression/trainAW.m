function [adj, weight,J]=trainAW(idx,X,y,adj,weight,lambda)

n=length(adj);
options = optimset('GradObj', 'on', 'MaxIter', 400);

[t,J,exit_flag]=fminunc(@(t)(costFunctionAW(X,y,t(1:n),t(n+1:end),lambda)), [adj;weight], options);

adj=t(1:n);
adj(idx)=0;
weight=t(n+1:end);
weight(idx)=0;

end
