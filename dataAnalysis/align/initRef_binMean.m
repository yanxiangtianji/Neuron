function ref=initRef_binMean(rData,maxTime,ws,threshold)
  %require: data=cell(nTri); WindowSize>0
  nTri=length(rData(:));
  len=ceil(maxTime/ws);
  disData=zeros(len,nTri);
  for i=1:nTri;
    disData(:,i)=discretize(rData(i),ws,0,len,'binary');
  end;
  workBin=find(sum(disData,2)>=threshold*nTri);
  ref=zeros(length(workBin),1);
  for i=1:nTri;
    d=cell2mat(rData(i));
    for j=1:length(workBin);
      rng=[workBin(j)-1,workBin(j)]*ws;
      t=mean(d(find(d>=rng(1) & d<rng(2))));
      if(isempty(t)) t=0; end;
      ref(j)+=t;
    end;
  end;
  ref/=nTri;
end
