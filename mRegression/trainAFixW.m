function [A,CM]=trainAFixW(rData,D,lambdaA,Ainit,Wgiven)
n=length(rData);

if(sum(size(Ainit)==[n n])!=2)
  Ainit=initAdjacency(n);
end
if(nargout==2)
  CM=zeros(n,4);
end
A=Ainit;
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  [X,y]=genDataFromRaw(rData,D,i);
  [A(:,i),J]=trainOneAFixW(i,X,y,Ainit(:,i),Wgiven(:,i),lambdaA);
  if(nargout==2)
    CM(i,:)=testOneAW(A(:,i),Wgiven(:,i),X,y);
  end
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
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
