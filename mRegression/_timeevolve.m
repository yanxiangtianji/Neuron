%W for whole trial

[~,W]=goTogether2(fnlist,19,D,fRep,1,1,Ainit,Winit);
%load '../data/dataTGH.mat'

%Aarr for each small period given W

nPeriod=9;
periodLength=10*timeUnit2ms;
Aarr=cell(m,4,nPeriod);
for i=1:m; for j=1:4;
  rData=readRaw(fnlist(i,j));
  for k=1:nPeriod;
    data=pickDataByTime(rData,k*periodLength,(k+1)*periodLength);
    Aarr(i,j,k)=trainAFixW(data,D,lambdaA,fRep,Ainit,W);
  end;
end;end;

%backbone of each period
Aa=cell(4,nPeriod); As=cell(4,nPeriod);
for i=1:4;for j=1:nPeriod;  [Aa(i,j),As(i,j)]=statMat(Aarr(:,i,j));   end;end;

%plot backbone,distribtion of +/- of each period



