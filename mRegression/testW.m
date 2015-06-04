function CMmat=testW(W,rData,D,fRep)

n=length(W);
CMmat=zeros(n,4);
[seq0,cls0]=serialize(rData);
for i=1:n
  %[X,y]=genDataFromRaw(rData,D,i,fRep);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  CMmat(i,:)=testOneW(W(:,i),X,y);
end

end

%helper:
function cm=testOneW(Wvec,X,y)

p=predictW(Wvec,X);
cm=test(p,y);
%showCM(cm);

end
