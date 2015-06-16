#W for whole trial

[~,W]=goTogether2(fnlist,19,D,fRep,1,1,Ainit,Winit);
%load '../data/dataTGH.mat'

#Aarr for each small period given W

nPeriod=9;
periodLength=10*timeUnit2ms;
Aarr=cell(m,4,nPeriod);
for i=1:m; for j=1:4;
  rData=readRaw(fnlist(i,j));
  for k=1:nPeriod;
    data=pickDataByTime(rData,k*periodLength,(k+1)*periodLength);
    t=trainAFixW(data,D,lambdaA,fRep,Ainit,W);
    for l=1:n;
      if(length(data(l))==0)
        t(:,l)=0;
      end;
    end;
    Aarr(i,j,k)=t;
  end;
end;end;

save('../data/dataPer.mat','D','lambdaA','lambdaW','fRep','Ainit','Winit','nPeriod','W','Aarr','Aa','As')

#backbone of each period
Aa=cell(4,nPeriod); As=cell(4,nPeriod);
for i=1:4;for j=1:nPeriod;  [Aa(i,j),As(i,j)]=statMat(Aarr(:,i,j));   end;end;

bone=findBoneAvg(Aa,0.5);

#plot backbone,distribtion of +/- of each period
cue_id=1;
figure;
for i=1:nPeriod;
  subplot(3,3,i);imagesc(cell2mat(bone(cue_id,i)));colorbar;colormap(gray(2));
end;

