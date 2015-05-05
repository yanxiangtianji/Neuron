function [adj, weight,J]=trainOneAW(idx,X,y,adj,weight,lambdaA,lambdaW)

n=length(adj);

[J,gd]=costFunctionAW(X,y, adj,weight,lambdaA,lambdaW);
if(isnan(J))
  adj-=0.1*gd(1:n);
  weight-=0.1*gd(n+1:2*n);
  clear gd;
end

options = optimset('GradObj', 'on', 'MaxIter', 400);
[t,J,exit_flag]=fminunc(@(t)(costFunctionAW(X,y,t(1:n),t(n+1:end),lambdaA,lambdaW)), [adj;weight], options);

adj=(t(1:n)>=0);
adj(idx)=0;
weight=t(n+1:end);
weight(idx)=0;

end
