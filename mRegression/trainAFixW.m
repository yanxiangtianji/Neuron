function [A,CM]=trainAFixW(rData,D,lambdaA,fRep,Ainit,Wgiven)
n=length(rData);

if(sum(size(Ainit)==[n n])!=2)
  Ainit=initAdjacency(n);
end
A=Ainit;

[seq0,cls0]=serialize(rData);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  %[X,y]=genDataFromRaw(rData,D,i,fRep);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  [A(:,i),J]=trainOneAFixW(i,X,y,Ainit(:,i),Wgiven(:,i),lambdaA);
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
end
clear seq0 cls0;
if(nargout==2)
  CM=testAW(A,Wgiven,rData,fRep);
end
%showCM(sum(CM));

end


function [adj,J]=trainOneAFixW(idx,X,y,adjInit,weightGiven,lambdaA)
adj=adjInit;
%n=length(adj);
cf=@(t)(costFunctionAGivenW(X,y, t, weightGiven,lambdaA));
[J,gd]=cf(adj);
if(isnan(J))
  adj-=0.1*gd;
  clear gd;
end
options = optimset('GradObj', 'on', 'MaxIter', 400);
[adj,J,exit_flag]=fminunc(cf, adj, options);
adj=(adj>=0);
adj(idx)=0;

end
