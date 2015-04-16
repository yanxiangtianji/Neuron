function [A,W,CM]=learnAW(rData,D,lambda,A=0,W=0)
n=length(rData);

if(sum(size(A)==[n n])!=2)
  A=initAdjacency(n);
end
if(sum(size(W)==[n n])!=2)
  W=initWeight(n);
end
CM=zeros(n,4);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  [seq,cls]=mergeWithDelay(rData,i,D);
  [X,y]=genDataByRef(n,seq,cls,rData(i));
  [A(:,i),W(:,i),J]=trainAW(i,X,y,A(:,i),W(:,i),lambda);
  CM(i,:)=testAW(A(:,i),W(:,i),X,y);
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
end
%showCM(sum(CM));

end
