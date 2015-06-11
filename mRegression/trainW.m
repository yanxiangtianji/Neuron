function [W,CM]=trainW(rData,D,lambda,fRep=0,W=0)
n=length(rData);

if(sum(size(W)==[n n])!=2)
  W=initWeight(n);
end

[seq0,cls0]=serialize(rData);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  %[X,y]=genDataFromRaw(rData,D,i);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  [W(:,i),J]=trainOneW(i,X,y,W(:,i),lambda);
end
clear seq0 cls0;
if(nargout==2)
  CM=trainW(W,rData,fRep);
end
%showCM(sum(CM));

end

%helper:
function [weight,J]=trainOneW(idx,X,y,weight,lambda)

[J,gd]=costFunctionW(X,y, weight,lambda);
if(isnan(J))
  weight-=0.1*gd;
  clear gd;
end

options = optimset('GradObj', 'on', 'MaxIter', 400);
[weight, J, exit_flag] = fminunc(@(t)(costFunctionW(X, y, t, lambda)), weight, options);
weight(idx)=0;

end
