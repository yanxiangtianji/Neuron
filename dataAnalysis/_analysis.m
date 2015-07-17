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
infoFun=@(data1,data2)corr(data1(:),data2(:));
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

addpath('../mBasic/')
nTri=50;
basicDataParameters
clear fn_c1 fn_c2 fn_r1 fn_r2
rDataList=cell(nTri,nNeu,nCue);
for i=1:nCue;  rDataList(:,:,i)=readList(fnlist(:,i));  end;

maxTime=findMaxTime(rDataList);%=100000, log10(maxTime/timeUnit2ms)=5

window_size=[((1:2:10)'*(10.^(1:3)))(:);10^4]*timeUnit2ms; %log-scale
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

%initialization part is the same as cross TRIAL part

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

%maxTime=findMaxTime(rDataList);
maxTime=10*1000*timeUnit2ms;
winSize=100*timeUnit2ms;
resLength=ceil(maxTime/winSize);

%1, spike rate checking:

%single:
tid=1;nid=10;
for i=1:nCue;cid=i;
  subplot(2,2,i);
  plot(discretize(rDataList(tid,nid,cid),winSize,0,resLength,'count')/winSize*timeUnit2ms*1000);
end;
%group:
sc1=zeros(resLength,nNeu,nCue); sc2=zeros(resLength,nNeu,nCue);
for cid=1:nCue;
  for nid=1:nNeu;
    for tid=1:nTri;
      t=discretize(rDataList(tid,nid,cid),winSize,0,resLength,'count');
      sc1(:,nid,cid)+=t; sc2(:,nid,cid)+=t.^2;
    end;
  end;
end
sc_m=sc1/nTri/ winSize*timeUnit2ms*1000;% num per second
sc_s=sqrt(sc2/nTri-(sc1/nTri).^2)/winSize*timeUnit2ms*1000;

%mean spike rate of each neuron on each cue:
avg_sr=reshape(mean(sc_m,1)(:),nNeu,nCue)

nid=10;
for i=1:nCue;
  subplot(nCue,1,i);errorbar(1:resLength,sc_m(:,nid,i),sc_s(:,nid,i)/3);
  line([0,resLength],mean(sc_m(:,nid,i)),'color','r');xlim([0 resLength]);
end;


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
showSI_xc_one(interval,tid,nid);
%group:




