function [Xres,yres]=sampleData(X,y,maxNegRatio)
  idxP=find(y==1);
  idxN=find(y==0);
  np=length(idxP);
  nn=length(idxN);
  k=np*maxNegRatio;
  if(k>=nn)
    Xres=X;
    yres=y;
  else
    rd1=randperm(k);
    Xres=[X(idxP,:);    X(idxN(rd1),:)];
    yres=[y(idxP);  y(idxN(rd1))];
    rd2=randperm(k+np);
    Xres=Xres(rd2,:);
    yres=yres(rd2);
  end
end
