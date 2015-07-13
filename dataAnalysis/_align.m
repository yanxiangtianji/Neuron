addpath([pwd,'/../mBasic/'])
nTri=50;
basicDataParameters
clear fn_c1 fn_c2 fn_r1 fn_r2
addpath([pwd,'/align/'])

%rData=readList(fnlist(:,1));%for test

rData=cell(nTri,nNeu,nCue);
for i=1:nCue; rData(:,:,i)=readList(fnlist(:,i)); end;

####################
# algorithm 1
# knn
####################

maxTime=findMaxTime(rData);
ws=200*timeUnit2ms;

%function ref=initRef_binMean(rData,maxTime,ws,threshold)

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

%function [ws,cr]=compactWC2quantile(ws,cr,quan)  %ws and cr are column vectors
%function [ws,cr]=pairMMW(d1,d2,compact=false)  %ws and cr are column vectors

w=_pairMMWref(rData(1,11),rData(2,11),100)
[ws,cr]=pairMMW(rData(1,11),rData(2,11));
plot(ws,cr);


ws=cell(nTri,nTri,nNeu,nCue);
cr=cell(nTri,nTri,nNeu,nCue);
for cid=1:nCue;
  for nid=1:nNeu;
    tic;
    for tid1=1:nTri;  for tid2=tid1+1:nTri
      [ws(tid1,tid2,nid,cid),cr(tid1,tid2,nid,cid)]=pairMMW(rData(tid1,nid,cid),rData(tid2,nid,cid));
    end;end
    toc;
  end
end
save('./align/base.mat','ws','cr')

