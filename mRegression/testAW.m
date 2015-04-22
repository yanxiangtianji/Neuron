function CMmat=testAW(A,W,rData,D)

n=length(W);
CMmat=zeros(n,4);
for i=1:n
  [seq,cls]=mergeWithDelay(rData,i,D);
  [X,y]=genDataByRef(n,seq,cls,rData(i));
  CMmat(i,:)=testOneAW(A(:,i),W(:,i),X,y);
end

end
