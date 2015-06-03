function [Aarr,W,CMarr]=goTogether2(fn_lists,nNeuron,D,fRep,lambdaA,lambdaW,Ainit,Winit)
%fn_lists:      cell matrix of data file name
%nNeuron:       number of neuron
%D:             delay matrix
%fRep:          rate of repolarization
%lambda(A/W):   regularization parameter for A/W
%(A/W)init:        initial A/W to start with

  [n,m]=size(fn_lists);
%  nNeuron
  As=zeros(nNeuron,nNeuron,n*m);
  for i=1:n*m;  As(:,:,i)=Ainit;  end;
  W=Winit;
  [seq0s,cls0s]=loadDatas(fn_lists);
  
  options = optimset('GradObj', 'on', 'MaxIter', 400);
  %main work
  for idx=1:nNeuron;
    tic;
    [X,y,len]=prepareData(n,m,nNeuron,seq0s,cls0s,idx,D,fRep);
    [t,J]=fminunc(@(t)(costFunctionMASW(X,y,len,t(1:n*m*nNeuron),t(n*m*nNeuron+1:end),lambdaA,lambdaW)),
      [As(:,idx,:)(:);W(:,idx)], options);
    for i=1:n*m;
      As(:,idx,i)=t((i-1)*nNeuron+1:i*nNeuron);
      As(idx,idx,i)=0;
    end;
    W(:,idx)=t(n*m*nNeuron+1:end);
    toc;
  end;%neuron

  %reshape result of A
  Aarr=cell(n,m);
  for j=1:m; for i=1:n;
    Aarr(i,j)=As(:,:,(j-1)*n+i)>0;
  end;end;
  
  %CMarr
  if(nargout==3)
    CMarr=cell(n,m);
    for i=1:n; for j=1:m;
      CMarr(i,j)=testAW(cell2mat(Aarr(i,j)),W,readRaw(cell2mat(fn_lists(i,j))),D,fRep);
    end;end;
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

function [X,y,l]=prepareData(n,m,nNeuron,seq0s,cls0s,idx,D,fRep)
  X=[];y=[];
  l=zeros(n*m);
  for j=1:m; for i=1:n; #sets outer iteration to be higher order dismension
    [xt,yt]=genDataFromSnC(nNeuron,cell2mat(seq0s(i,j)),cell2mat(cls0s(i,j)),D,idx,fRep);
    X=[X;xt];  y=[y;yt];
    l((j-1)*n+i)=length(yt);
  end;end;
end
