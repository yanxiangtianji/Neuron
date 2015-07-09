addpath('../mBasic/')
nTri=50;
basicDataParameters
clear fn_c1 fn_c2 fn_r1 fn_r2

rData=readList(fnlist(:,1));

rData=cell(nTri,nNeu,nCue);
for i=1:nCue; rData(:,:,i)=readList(fnlist(:,i)); end;

####################
# algorithm 1
# knn
####################

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

maxTime=findMaxTime(rData);
ws=200*timeUnit2ms;

%ref
ref=cell(nNeu,1);
cid=1;
for nid=1:nNeu;
  ref(nid)=initRef_binMean(rData(:,nid,cid),maxTime,ws,0.3);
end;

%align-knn
center=cell(nNeu,1);error=zeros(nNeu,1);
for nid=1:nNeu;
  [center(i),error(i)]=knn(rData(:,nid,cid),ref(i),400,1e-4);
end

####################
# algorithm 2
# pairwise iteration of max-min
####################

function w=pairMMwindow(d1,d2,iter=100,w0=0)
  %init d1&d2 to row vectors , basic check
  if(iscell(d1));  d1=cell2mat(d1)(:)';  end;
  if(isempty(d1)) w=0;  return; end;
  if(iscell(d2));  d2=cell2mat(d2)(:)';  end;
  if(isempty(d2)) w=0;  return; end;
  if(w0==0) w0=2*min(d1(end)/length(d1),d2(end)/length(d2));  end
  %max-min
  ref=d2+[-w0,w0]';
  cmp=d1>ref(1,:)' & d1<ref(2,:)';
  w=0;
  for i=1:length(d2)
    dis=min(abs( d1(find(cmp(i,:)))-d2(i) ));
    if(isempty(dis)==0);  w=max(w, dis); end;
  end
end

w=pairMMwindow(rData(1,11),rData(2,11),100)



