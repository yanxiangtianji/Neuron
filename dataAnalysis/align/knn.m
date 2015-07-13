function [clt]=knn(rData,ref,iter=400,epsilonDelta=1e-4)
  nTri=numel(rData);
  data=[];
  for i=1:nTri; data=[data, cell2mat(rData(i))]; end;
  %data is row vector
  if(iscell(ref)) clt=cell2mat(ref)(:); else; clt=ref(:);  end;
  %clt is column vector
  while(iter-->0)
    dis=abs(data-clt);%auto expend to matrix
    [~,idx]=min(dis);
    clt2=clt;
    rmvIdx=[];
    for i=1:length(clt2);
      t=mean(data(find(idx==i)));
      if(isempty(t)) rmvIdx=[rmvIdx,i]; else; clt2(i)=t;  end;
    end;
    %centers changes little:
    if(sum(abs(clt-clt2))<=epsilonDelta)  break;  end;
    if(isempty(rmvIdx)==0)  clt2(rmvIdx)=[];  end;
    clt=sort(clt2);
  end
end
