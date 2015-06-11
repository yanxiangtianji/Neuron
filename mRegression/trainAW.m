function [A,W,CM]=trainAW(rData,D,lambdaA,lambdaW,fRep=0,Ainit=0,Winit=0)
%%input parameters:
%rData:     raw data
%D:         delay matrix
%lambdaA:   regularization parameter for A
%lambdaW:   regularization parameter for A
%fRep:      factor for repolarization
%Ainit:     initial A to start with
%Winit:     initial W to start with

n=length(rData);

if(sum(size(Ainit)==[n n])!=2)
  Ainit=initAdjacency(n);
end
A=Ainit;
if(sum(size(Winit)==[n n])!=2)
  Winit=initWeight(n);
end
W=Winit;

[seq0,cls0]=serialize(rData);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  %[X,y]=genDataFromRaw(rData,D,i,fRep);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  [A(:,i),W(:,i),J]=trainOneAW(i,X,y,Ainit(:,i),Winit(:,i),lambdaA,lambdaW);
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
end
clear seq0 cls0;
if(nargout==3)
  CM=testAW(A,W,rData,fRep);
end
%showCM(sum(CM));

end

%helper:
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
