function [A,W,CM]=trainARefW(rData,D,lambdaA,fRep,panW,Ainit,Wref)
n=length(rData);

if(sum(size(Ainit)==[n n])!=2)
  Ainit=initAdjacency(n);
end
A=Ainit; W=Wref;

[seq0,cls0]=serialize(rData);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  %[X,y]=genDataFromRaw(rData,D,i,fRep);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  [A(:,i),W(:,i),J]=trainOneARefW(i,X,y,Ainit(:,i),Wref(:,i),lambdaA,panW);
end
clear seq0 cls0;
if(nargout==3)
  CM=testAW(A,W,rData,fRep);
end
%showCM(sum(CM));

end


function [adj, weight,J]=trainOneARefW(idx,X,y,adjInit,weightRef,lambdaA,panW)
adj=adjInit; weight=weightRef;
n=length(adj);
cf=@(t)(costFunctionAWCore(X,y,t(1:n),t(n+1:2*n),lambdaA,0, 1,1, 0,panW,0,weightRef));
[J,gd]=cf([adj;weight]);
if(isnan(J))
  adj-=0.1*gd(1:n);
  weight-=0.05*gd(n+1:2*n);
  clear gd;
end
options = optimset('GradObj', 'on', 'MaxIter', 400);
[t,J,exit_flag]=fminunc(cf, [adj;weight], options);
adj=(t(1:n)>=0);
adj(idx)=0;
weight=t(n+1:end);
weight(idx)=0;

end
