function [W,CM]=learnW(rData,D,lambda,W=0)
n=length(rData);

if(sum(size(W)==[n n])!=2)
  W=initWeight(n);
end
CM=zeros(n,4);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  [seq,cls]=mergeWithDelay(rData,i,D);
  [X,y]=genDataByRef(n,seq,cls,rData(i));
  [W(:,i),J]=trainW(i,X,y,W(:,i),lambda);
  CM(i,:)=testW(W(:,i),X,y);
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
end
%showCM(sum(CM));

end
