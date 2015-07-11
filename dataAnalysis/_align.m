addpath('../mBasic/')
nTri=50;
basicDataParameters
clear fn_c1 fn_c2 fn_r1 fn_r2

rData=readList(fnlist(:,1));%for test

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

function [w,c]=_pairMMWref(d1,d2,w0)
  w=0;c=0;
  if(iscell(d1));  d1=cell2mat(d1);  end;
  if(isempty(d1)) return; end;
  if(iscell(d2));  d2=cell2mat(d2);  end;
  if(isempty(d2)) return; end;
  if(isrow(d1)==0) d1=reshape(d1,1,numel(d1));  end;
  if(isrow(d2)==0) d2=reshape(d2,1,numel(d2));  end;
  ref=d2+[-w0,w0]';
  cmp=d1>ref(1,:)' & d1<ref(2,:)';
  for i=1:length(d2)
    minDis=min(abs( d1(find(cmp(i,:)))-d2(i) ));
    if(isempty(dis)==0);  ++c; w=max(w, minDis); end;
  end
  c/=length(d1);
end

function [ws,cr]=pairMMW(d1,d2,compact=0)
%give minimum Window Size for each Coverage Ratio
  %init to row vector & basic check
  ws=cr=[0];
  if(iscell(d1));  d1=cell2mat(d1);  end;
  if(isempty(d1)) return; end;
  if(iscell(d2));  d2=cell2mat(d2);  end;
  if(isempty(d2)) return; end;
  if(isrow(d1)==0) d1=reshape(d1,1,numel(d1));  end;
  if(isrow(d2)==0) d2=reshape(d2,1,numel(d2));  end;
  ld1=length(d1); ld2=length(d2);
  %main:
  cr=(1:ld1)'./ld1;
  %dis=abs(d1-d2');%size=length(d2),length(d1)
  ws=sort(min(abs(d1-d2')));
  if(compact)
    [ws,idx]=unique(ws);%idx is the last occurence in ws
    cr=cr(idx);
  end
end

w=_pairMMWref(rData(1,11),rData(2,11),100)
[ws,cr]=pairMMW(rData(1,11),rData(2,11));
plot(ws,cr);


