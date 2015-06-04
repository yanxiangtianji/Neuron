function [W,CM]=trainW(rData,D,lambda,W=0)
n=length(rData);

if(sum(size(W)==[n n])!=2)
  W=initWeight(n);
end
if(nargout==2)
  CM=zeros(n,4);
end

[seq0,cls0]=serialize(rData);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  %[X,y]=genDataFromRaw(rData,D,i);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  [W(:,i),J]=trainOneW(i,X,y,W(:,i),lambda);
  if(nargout==2)
    CM(i,:)=testOneW(W(:,i),X,y);
  end
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
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
