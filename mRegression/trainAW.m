function [A,W,CM]=trainAW(rData,D,lambdaA,lambdaW,fRep=0,Ainit=0,Winit=0)
%%input parameters:
%rData:     raw data
%D:         delay matrix
%lambdaA:   regularization parameter for A
%lambdaW:   regularization parameter for A
%fRep:      factor for repolarization
%Ainit:     initial A to start with
%Winit:     initial W to start with

n=length(rData);

if(sum(size(Ainit)==[n n])!=2)
  Ainit=initAdjacency(n);
end
A=Ainit;
if(sum(size(Winit)==[n n])!=2)
  Winit=initWeight(n);
end
W=Winit;
if(nargout==3)
  CM=zeros(n,4);
end

[seq0,cls0]=serialize(rData);
for i=1:n
%  disp(sprintf('Working idx=%d',i));
  %[X,y]=genDataFromRaw(rData,D,i,fRep);
  [X,y]=genDataFromSnC(n,seq0,cls0,D,i,fRep);
  [A(:,i),W(:,i),J]=trainOneAW(i,X,y,Ainit(:,i),Winit(:,i),lambdaA,lambdaW);
  if(nargout==3)
    CM(i,:)=testOneAW(A(:,i),W(:,i),X,y);
  end
%  disp(sprintf('  error=%f\taccurancy=%f',J,(CM(i,1)+CM(i,4))/sum(CM(i,:))));
%  showCM(CM(i,:));
end
%showCM(sum(CM));

end
