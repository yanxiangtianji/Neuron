function [A,W,CM]=trainARefW(rData,D,lambdaA,panW,Ainit,Wref)
n=length(rData);

if(sum(size(Ainit)==[n n])!=2)
  Ainit=initAdjacency(n);
end
if(nargout==3)
  CM=zeros(n,4);
end
A=Ainit; W=Wref;
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  [X,y]=genDataFromRaw(rData,D,i);
  [A(:,i),W(:,i),J]=trainOneARefW(i,X,y,Ainit(:,i),Wref(:,i),lambdaA,panW);
  if(nargout==3)
    CM(i,:)=testOneAW(A(:,i),W(:,i),X,y);
  end
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
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
