function [Aarr,W]=goTogether(fn_lists,nNeuron,D,fRep,alpha,lambdaA,lambdaW,Ainit,Winit)
%fn_lists:      cell matrix of data file name
%nNeuron:       number of neuron
%D:             delay matrix
%fRep:          rate of repolarization
%alpha:         learning rate in gradient descent
%lambda(A/W):   regularization parameter for A/W
%(A/W)init:        initial A/W to start with

  [n,m]=size(fn_lists);
%  nNeuron
  Aarr=zeros(n,m,nNeuron,nNeuron);
  for i=1:n;for j=1:m;    Aarr(i,j,:,:)=Ainit;  end;end;
  W=Winit;
  [seq0s,cls0s]=loadDatas(fn_lists);
  
  stopEplison=1e-8;
  
  for idx=1:nNeuron;
    Xcell=cell(n,m);
    ycell=cell(n,m);
    for i=1:n; for j=1:m;
      [Xcell(i,j),ycell(i,j)]=genDataFromSnC(nNeuron,cell2mat(seq0s(i,j)),cell2mat(cls0s(i,j)),D,idx,fRep);
    end;end;
    for iter=1:400;
      [gA,gW]=gradientOneColumn(n,m,nNeuron,idx,Xcell,ycell,Aarr(:,:,idx,:),W(idx,:),lambdaA,lambdaW);
      Aarr(:,:,idx,:)-=alpha*gA;
      W-=alpha*gW;
    end;
  end

end

###############
#helper functions:

%load data matrix
function [seq0s,cls0s]=loadDatas(fn_lists)
  [n,m]=size(fn_lists);
  seq0s=cell(n,m);
  cls0s=cell(n,m);
  for i=1:n; for j=1:m;
    data=readRaw(cell2mat(fn_lists(i,j)));
    [seq0s(i,j),cls0s(i,j)]=serialize(data);
  end;end;
end

function [gA,gW]=gradientOneColumn(n,m,nNeuron,idx,Xcell,ycell,adj,weight,lambdaA,lambdaW)
  gA=zeros(n,m,nNeuron);
  gW=zeros(nNeuron,1);
  for i=1:n; for j=1:m;
    [~,grad]=costFunctionAW(cell2mat(Xcell(i,j)),cell2mat(ycell(i,j)),adj(i,j,:),weight,lambdaA,lambdaW);
    gA(i,j,:)=grad(1:nNeuron);
    gW+=grad(nNeuron+1:2*nNeuron);
  end;end;
  gW/=n*m;
end

