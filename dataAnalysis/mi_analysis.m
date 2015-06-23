###################
#cross NEUORN mutual information on identical period

%load data
addpath('../mRegression/')
basicParameters
rData=readRaw([fn_prefix,'all.txt']);
rmpath('../mRegression/')

function maxTime=findMaxTime(rDataList)
  maxTime=0;
  [l1,l2]=size(rDataList);
  for i=1:l1;for j=1:l2;
    if(isempty(t=cell2mat(rDataList(i,j)))==0)
      maxTime=max(maxTime,t(end));
    end;
  end;end;
end

maxTime=findMaxTime(rData);

window_size=10.^[1:9]*timeUnit2ms;
window_size=[10:10:50, 100:50:300, 400:100:1000, 2000:1000:10000]*timeUnit2ms;
mi=zeros(nNeu,nNeu,length(window_size));
for i=1:length(window_size);
  tic;
  ws=window_size(i);
  vecLength=ceil(maxTime/ws);
  data=zeros(vecLength,nNeu);
  for j=1:nNeu;
    data(:,j)=discretize(cell2mat(rData(j)),ws,0,vecLength);
  end;
  mi(:,:,i)=mutual_info_all(data);
  toc;
end;

save('Xneu.mat','window_size','mi');

i=6;j=14;
plot(window_size/timeUnit2ms,mi(i,j,:)(:));xlabel('windows size(ms)');ylabel('mutual information');
title(['MI between ',num2str(i),' and ',num2str(j)]);

hold on
for i=1:nNeu;for j=i+1:nNeu;plot(window_size/timeUnit2ms,mi(i,j,:)(:));end;end;
hold off

idx=find(mi(:,:,1));
mi2=zeros(length(window_size),length(idx));
for i=1:length(idx);
  ii=mod(idx(i)-1,nNeu)+1;
  jj=ceil(idx(i)/nNeu);
  mi2(:,i)=mi(ii,jj,:)(:);
end;
plot(log10(window_size/timeUnit2ms),mi2)


###################
#cross TRIAL mutual information on identical neuron and identical cue

addpath('../mRegression/')
function rData=_readList(flist,n)
  rData=cell(length(flist),n);
  for i=1:length(flist)
    rData(i,:)=readRaw(flist(i));
  end
end
basicParameters
nTri=50;
fnlist=cell(nTri,nCue);
fnlist(:,1)=fn_c1(1:nTri);fnlist(:,2)=fn_c2(1:nTri);fnlist(:,3)=fn_r1(1:nTri);fnlist(:,4)=fn_r2(1:nTri);

rDataList=cell(nTri,nNeu,nCue);
for i=1:nCue;  rDataList(:,:,i)=_readList(fnlist(:,i),nNeu);  end;
rmpath('../mRegression/')

window_size=10.^[1:9]*timeUnit2ms;
window_size=[10:10:50, 100:50:300, 400:100:1000, 2000:1000:10000]*timeUnit2ms;

function mi=calMI_xt_one(rDataList,idx,maxTime,ws)
  nTri=size(rDataList,1);
  vecLength=ceil(maxTime/ws);
  data=zeros(vecLength,nTri);
  for i=1:nTri;
    data(:,i)=discretize(cell2mat(rDataList(i,idx)),ws,0,vecLength);
  end;
  mi=mutual_info_all(data);
end
function mi=calMI_xt(rDataList,window_size)
  nNeu=size(rDataList,2);
  maxTime=findMaxTime(rDataList);
  mi=cell(nNeu,length(window_size));
  for i=1:length(window_size)
    for idx=1:nNeu
      mi(idx,i)=calMI_xt_one(rDataList,idx,maxTime,window_size(i));
    end
  end
end

%type: mi=cell(nNeu,length(window_size),nCue); mi(1)=zeros(nTri);
mi=cell(nNeu,length(window_size),nCue);
for i=1:nCue;
  tic;mi(:,:,i)=calMI_xt(rDataList(:,:,i),window_size);toc;
end;
mi2=zeros(nNeu,length(window_size),nCue);
for i=1:prod(size(mi)); mi2(i)=sum(sum(cell2mat(mi(i)))); end;

save('Xtrial.mat','window_size','mi');

for cue_id=1:nCue;
  subplot(2,2,cue_id);plot(log10(window_size/timeUnit2ms),mi2(:,:,cue_id));
  title([cell2mat(cue_name(cue_id)),' X-trial MI on all neurons']);
  %legend(num2str((1:nNeu)'));
end;


###################
#cross CUE mutual information on identical neuron

%load data part is the same as cross TRIAL part

function mi=calMI_xc_one(rDataList1,rDataList2,idx,maxTime,ws)
%mean MI for all trial pairs
  vecLength=ceil(maxTime/ws);
  l1=length(rDataList1); l2=length(rDataList2);
  data1=zeros(vecLength,length(rDataList1));
  for i=1:l1;
    data1(:,i)=discretize(cell2mat(rDataList1(i,idx)),ws,0,vecLength);    
  end;
  mi=0; %mi=zeros(l1,l2);
  for i=1:l2;
    data2=discretize(cell2mat(rDataList2(i,idx)),ws,0,vecLength);    
    for j=1:l1;
      mi+=mutual_info(data2,data1(:,j));
      %mi(j,i)=mutual_info(data1(:,j),data2);
    end
  end;
  mi/=l1*l2;
end

function mi=calMI_xc(rDataList,window_size)
  [nTri,nNeu,nCue]=size(rDataList);
  maxTime=zeros(nCue,1);
  for i=1:nCue; maxTime(i)=findMaxTime(rDataList(:,:,i)); end;
  mi=cell(nNeu,length(window_size));
  for i=1:length(window_size);
    tic;
    ws=window_size(i);
    for idx=1:nNeu;
      t=zeros(nCue);
      for cue_i=1:nCue;for cue_j=cue_i+1:nCue;
        t(cue_i,cue_j)=calMI_xc_one(rDataList(:,:,cue_i),rDataList(:,:,cue_j),idx,max(maxTime([cue_i,cue_j])),ws);
      end;end;
     mi(idx,i)=t;
    end;
    toc;
  end;
end

%type: mi=cell(nNeu,length(window_size)); mi(1)=zeros(nCue);
mi=calMI_xc(rDataList,window_size);

save('Xcue.mat','window_size','mi');

function showMI_xc(mi,window_size,nid,nCue,timeUnit2ms)
  l=length(window_size);
  idx=[]; ticks=num2str([]);
  for i=1:nCue;for j=i+1:nCue;
    idx=[idx; i+nCue*(j-1)];
    ticks=[ticks; sprintf('%d-%d',i,j)];
  end;end;
  sort(idx);
  data=zeros(length(idx),l);
  for j=1:l;  data(:,j)=cell2mat(mi(nid,j))(idx); end;
  plot(log10(window_size/timeUnit2ms),data);title(['Neuron ',num2str(nid),' X-cue MI']);
  %legend(ticks)
end

nid=1;
showMI_xc(mi,window_size,nid,nCue,timeUnit2ms);

for i=1:nNeu;
  subplot(4,5,i);showMI_xc(mi,window_size,i,nCue,timeUnit2ms);
end;




