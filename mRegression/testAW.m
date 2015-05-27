function CMmat=testAW(A,W,rData,D,fRep=0)

n=length(W);
CMmat=zeros(n,4);
[seq0,cls0]=serialize(rData);
for i=1:n
  %[X,y]=genDataFromRaw(rData,D,i,fRep);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  CMmat(i,:)=testOneAW(A(:,i),W(:,i),X,y);
end

end
