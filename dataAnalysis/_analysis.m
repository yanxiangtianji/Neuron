return %directly return, when whole scri[t is run by accident

###################
#cross NEUORN mutual information on identical period
###################

%load data
addpath([pwd,'/../mBasic/'])
basicDataParameters
rData=readRaw([fn_prefix,'all.txt']);
clear fn_c1 fn_c2 fn_r1 fn_r2
addpath([pwd,'/analysis/'])

%mutual information:
global disFun infoFun type
disFun=@(data,ws,off,len)discretize(data,ws,off,len,'count');
infoFun=@(data1,data2)mutual_info(data1,data2);
type='MI';
%dot product:
global disFun infoFun type
disFun=@(data,ws,off,len)discretize(data,ws,off,len,'binary');
infoFun=@(data1,data2)dot_product(data1,data2);
type='DP';
%Pearson correlation:
global disFun infoFun type
disFun=@(data,ws,off,len)discretize(data,ws,off,len,'count');
infoFun=@(data1,data2)pearson_corr(data1(:),data2(:));
type='PC';

maxTime=findMaxTime(rData);%=40000000, log10(maxTime/timeUnit2ms)=7+log10(4)

window_size=((1:2:10)'*(10.^(1:6)))(:)*timeUnit2ms; %log-scale
window_size=round([0.1:0.2:2, 2:10]*10000)*timeUnit2ms;  %around peak 

function mi=calMI_xn(rData,window_size)
  nNeu=length(rData);
  maxTime=findMaxTime(rData);
  mi=zeros(nNeu,nNeu,length(window_size));
  global disFun infoFun
  for wid=1:length(window_size);
    tic;
    ws=window_size(wid);
    vecLength=ceil(maxTime/ws);
    data=zeros(vecLength,nNeu);
    for j=1:nNeu;
      data(:,j)=disFun(cell2mat(rData(j)),ws,0,vecLength);
    end;
    for i=1:nNeu;for j=i+1:nNeu;
      mi(i,j,wid)=infoFun(data(:,i),data(:,j));
    end;end;
    toc;
  end;
end
mi=calMI_xn(rData,window_size);

save('Xneu-log.mat','window_size','mi');
save('Xneu-focus.mat','window_size','mi');

i=6;j=14;
plot(window_size/timeUnit2ms,mi(i,j,:)(:));xlabel('windows size(ms)');ylabel(type);
title([type,' between ',num2str(i),' and ',num2str(j)]);

%function showMI_xn(type,mi,xPoints)
showMI_xn(type,mi,log10(window_size/timeUnit2ms));xlabel('log10(window size) (ms)');
showMI_xn(type,mi,window_size/timeUnit2ms);xlabel('window size (ms)');


###################
#cross TRIAL mutual information on identical neuron and identical cue
###################

addpath([pwd,'/../mBasic/'])
nTri=50;
basicDataParameters
clear fn_c1 fn_c2 fn_r1 fn_r2
rDataList=cell(nTri,nNeu,nCue);
for i=1:nCue;  rDataList(:,:,i)=readList(fnlist(:,i));  end;
addpath([pwd,'/analysis/'])

maxTime=findMaxTime(rDataList);%=100000, log10(maxTime/timeUnit2ms)=5

window_size=[((1:2:10)'*(10.^(1:3)))(:);10^4]*timeUnit2ms; %log-scale
window_size=fix(10.^[1:0.2:4]*timeUnit2ms); %log-scale
window_size=[0.5, 1:2:20, 20]*100*timeUnit2ms;  %around peak 

function mi=calMI_xt_one(rDataList,maxTime,ws)
  nTri=length(rDataList);
  vecLength=ceil(maxTime/ws);
  data=zeros(vecLength,nTri);
  global disFun infoFun
  for i=1:nTri;
    data(:,i)=disFun(cell2mat(rDataList(i)),ws,0,vecLength);
  end;
  mi=zeros(nTri);
  for i=1:nTri;for j=i+1:nTri; mi(i,j)=infoFun(data(:,i),data(:,j)); end;end;
end
function mi=calMI_xt_cue(rDataList,maxTime,window_size)
  nNeu=size(rDataList,2);
  mi=cell(nNeu,length(window_size));
  for i=1:length(window_size);
    for nid=1:nNeu
      mi(nid,i)=calMI_xt_one(rDataList(:,nid),maxTime,window_size(i));
    end;
  end;
end
function mi=calMI_xt(rDataList,window_size)
  [~,nNeu,nCue]=size(rDataList);
  mi=cell(nNeu,length(window_size),nCue);
  maxTime=findMaxTime(rDataList);
  for cid=1:nCue
    tic;mi(:,:,cid)=calMI_xt_cue(rDataList(:,:,cid),maxTime,window_size);toc;
  end
end
%type: mi=cell(nNeu,length(window_size),nCue); mi(1)=zeros(nTri);
mi=calMI_xt(rDataList,window_size);

save('Xtrial-log.mat','window_size','mi');
save('Xtrial-focus.mat','window_size','mi');

%figure for mean MI over all trial-pairs of same cue
%function showMI_xt(type,mi,xPoints,cue_name)
showMI_xt(type,mi,log10(window_size/timeUnit2ms),cue_name,'log10(window size)');
showMI_xt(type,mi,window_size/timeUnit2ms,cue_name,'window size');

%figure for MI of one trial pairs on one cue
%function showMI_xt_sample(type,mi,xPoints,cue_name,cue_trials,neuidx)
%cue_trials: 1st->cueID, 2nd->trialFrom, 3rd->trialTo
showMI_xt_sample(type,mi,log10(window_size/timeUnit2ms),cue_name,[1,3,5],1:nNeu);xlabel('log10(window size)');
showMI_xt_sample(type,mi,log10(window_size/timeUnit2ms),cue_name,[1,3,5],1:9);xlabel('log10(window size)');
ylim([0,1]);%for DP

%figure for MI of one neuron on all trial-pairs on given cue
%function showMI_xt_neuron(type,mi,xPoints,xlbl,cue_name,nid,cue_id,mode='bunch',mode_arg=299)
%mode can be 'bunch' or 'error-bar'
showMI_xt_neuron(type,mi,log10(window_size/timeUnit2ms),cue_name,3,1);xlabel('log10(window size)');

for i=1:9;nid=i;%nid=i+9;
  subplot(3,3,i);showMI_xt_neuron(type,mi,log10(window_size/timeUnit2ms),cue_name,nid,1,'bunch',299);xlabel('log10(window size)');
end;

%all cue, error bar
for i=1:9;nid=i;%nid=i+9;
  subplot(3,3,i);hold all;
  for j=1:nCue;
    showMI_xt_neuron(type,mi,log10(window_size/timeUnit2ms),cue_name,nid,j,'error-bar')
    xlabel('log10(window size)');
  end
  title(['Neuron ',num2str(nid),' ',type]);%legend(num2str((1:nCue)'))
  xlim(log10(window_size([1,end])/timeUnit2ms)+[-0.1,0.1]);
  hold off;
end;

###################
#cross CUE mutual information on identical neuron
###################

%initialization part is the same to cross TRIAL part

window_size=[((1:2:10)'*(10.^(1:3)))(:);10^4]*timeUnit2ms; %log-scale
window_size=[0.5, 1:2:20, 20]*100*timeUnit2ms;  %around peak

function mi=calMI_xc_one(rDataList1,rDataList2,maxTime,ws)
%mean MI for all trial pairs
  vecLength=ceil(maxTime/ws);
  l1=length(rDataList1); l2=length(rDataList2);
  data1=zeros(vecLength,l1);
  global disFun infoFun
  for i=1:l1;
    data1(:,i)=disFun(cell2mat(rDataList1(i)),ws,0,vecLength);
  end;
  mi=0; %mi=zeros(l1,l2);
  for i=1:l2;
    data2=discretize(cell2mat(rDataList2(i)),ws,0,vecLength);
    for j=1:l1;
      mi+=infoFun(data2,data1(:,j));
      %mi(j,i)=infoFun(data2,data1(:,j));
    end
  end;
  mi/=l1*l2;
end
function mi=calMI_xc(rDataList,window_size)
  [nTri,nNeu,nCue]=size(rDataList);
  maxTime=findMaxTime(rDataList);
  mi=cell(nNeu,length(window_size));
  for i=1:length(window_size);
    tic;
    ws=window_size(i);
    for nid=1:nNeu;
      t=zeros(nCue);
      for cue_i=1:nCue;for cue_j=cue_i+1:nCue;
        t(cue_i,cue_j)=calMI_xc_one(rDataList(:,nid,cue_i),rDataList(:,nid,cue_j),maxTime,ws);
      end;end;
     mi(nid,i)=t;
    end;
    toc;
  end;
end

%type: mi=cell(nNeu,length(window_size)); mi(1)=zeros(nCue);
mi=calMI_xc(rDataList,window_size);

save('Xcue-log.mat','window_size','mi');
save('Xcue-focus.mat','window_size','mi');

%figure
%function showMI_xc(type,mi,xPoints,nid,nCue)

for nid=1:nNeu;%log-scale
  subplot(4,5,nid);showMI_xc(type,mi,log10(window_size/timeUnit2ms),nid,nCue);grid;
  set(gca,'xtick',1:4);xlabel('log10(WS)');ylim([0,1]);
end;

for nid=1:nNeu;%linear-scale
  subplot(4,5,nid);showMI_xc(type,mi,(window_size/timeUnit2ms),nid,nCue);grid;
  set(gca,'xtick',[5:5:20]*100);set(gca,'xticklabel',{'';'1s';'';'2s'});ylim([0,1]);
end;

nid=1;
showMI_xc(type,mi,log10(window_size/timeUnit2ms),nid,nCue);


###################
# X-cue difference check
###################
%initialization part is the same to cross TRIAL part

%maxTime=findMaxTime(rDataList);
maxTime=10*1000*timeUnit2ms;
winSize=100*timeUnit2ms; resLength=ceil(maxTime/winSize);

%1, spike rate checking:

%single:
nid=10;
tid_rng=1:7;%tid_rng=1+[0:4];
for i=1:nCue;cid=i;
  subplot(2,2,i);
  d=zeros(resLength,7);%7 auto colors in all. color will loop back when plotting mean line
  for j=1:length(tid_rg); d(:,j)=discretize(rDataList(tid_rng(j),nid,cid),winSize,0,resLength,'count'); end
  d*=timeUnit2ms*1000/winSize;
  plot(1:resLength,d);title(cell2mat(cue_name(i)));ylabel('spike/second');xlabel('time bin')
  hold on;plot(0:resLength,bsxfun(@plus,zeros(resLength+1,7),mean(d)));hold off
end;
%group:
scaleUnit2ms=timeUnit2ms*1000/winSize;% num per second
%function [sc_mean,sc_std,sc_skew,sc_kurtosis]=calSC_stat(rDataList,winSize,resLength=0)
[sc_m,sc_s]=calSC_stat(rDataList,winSize,resLength);
sc_m*=scaleUnit2ms;sc_s*=scaleUnit2ms;

nid=10;
%function showSC_xc_errorbar(nid,sc_m,sc_s,cue_name,stdScale,binSizeInMS)
showSC_xc_errorbar(nid,sc_m,sc_s,cue_name,1/3,winSize/timeUnit2ms);

%mean spike rate of each neuron on each cue:
avg_sr=reshape(mean(sc_m,1)(:),nNeu,nCue)


%2, spike interval checking:
function interval=getSpikeInterval(rData)
  if(iscell(rData)) rData=cell2mat(rData);  end;
  if(length(rData)==0)  interval=[]; return;  end;
  interval=rData(2:end)-rData(1:end-1);
end

interval=cell(nTri,nNeu,nCue);
for cid=1:nCue;for nid=1:nNeu;for tid=1:nTri;
  interval(tid,nid,cid)=getSpikeInterval(rDataList(tid,nid,cid));
end;end;end;

%single:
tid=1;nid=10;
showSI_xc_4(interval(tid,nid,:)(:),cue_name);
%group:
interval_cue=cell(nNeu,nCue);
for i=1:nCue;for j=1:nNeu;
  interval_cue(j,i)=cell2mat(interval(:,j,i)');
end;end;
nid=10;
showSI_xc_4(interval_cue(nid,:),cue_name);



