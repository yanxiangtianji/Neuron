function CMmat=testW(W,rData,D)

n=length(W);
CMmat=zeros(n,4);
for i=1:n
  [seq,cls]=mergeWithDelay(rData,i,D);
  [X,y]=genDataByRef(n,seq,cls,rData(i));
  CMmat(i)=testOneW(W(:,i),X,y);
end

end
