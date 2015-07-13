return %directly return, when whole scri[t is run by accident

###################
#cross NEUORN mutual information on identical period

%load data
addpath([pwd,'/../mBasic/'])
basicDataParameters
rData=readRaw([fn_prefix,'all.txt']);
clear fn_c1 fn_c2 fn_r1 fn_r2

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

function showMI_xn(xPoints,mi)
  [nNeu,~,l]=size(mi);
  if(length(xPoints)!=l)  error('Unmatched xPoints and mi');  end;
  idx=find(triu(ones(nNeu),1));
  mi2=zeros(l,length(idx));
  for i=1:length(idx);
    ii=mod(idx(i)-1,nNeu)+1;
    jj=ceil(idx(i)/nNeu);
    mi2(:,i)=mi(ii,jj,:)(:);
  end;
  global type;
  plot(xPoints,mi2);ylabel(type);
  title([type,' of all neuron pairs on whole period(4k seconds)'])
end
showMI_xn(log10(window_size/timeUnit2ms),mi);xlabel('log10(window size) (ms)');
showMI_xn(window_size/timeUnit2ms,mi);xlabel('window size (ms)');


###################
#cross TRIAL mutual information on identical neuron and identical cue

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
function showMI_xt(mi,xPoints,cue_name,xlbl)
  [nNeu,l,nCue]=size(mi);
  if(length(mi)!=0) nTri=length(cell2mat(mi(1))); else return; end;%nTri
  if(length(xPoints)!=l)  error('Unmatched xPoints and mi');  end;
  if(length(cue_name)!=nCue)  error('Unmatched cue_name length and mi');  end;
  mi2=zeros(size(mi));
  for i=1:prod(size(mi)); mi2(i)=sum(sum(cell2mat(mi(i)))); end;
  mi2/=(nTri-1)*nTri/2;
  global type;
  for cue_id=1:nCue;
    subplot(2,2,cue_id);plot(xPoints,mi2(:,:,cue_id));
    xlabel(xlbl);ylabel(['mean ',type,' on trial-pairs']);
    title([cell2mat(cue_name(cue_id)),': X-trial ',type,' on all neurons']);
    %legend(num2str((1:nNeu)'));
  end;
end
showMI_xt(mi,log10(window_size/timeUnit2ms),cue_name,'log10(window size)');
showMI_xt(mi,window_size/timeUnit2ms,cue_name,'window size');

%figure for MI of one trial pairs on one cue
function showMI_xt_sample(mi,xPoints,xlbl,cue_name,cue_trials,neuidx=0)
  %cue_trials(1)->cueID, cue_trials(2)->trialFrom, cue_trials(3)->trialTo
  [nNeu,l,nCue]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoints and mi');  end;
  if(length(cue_trials)<3)  error('Wrong coordinate size'); end;
  %make sure trial_id_source is small that trial_id_target (mi is symmetric)
  cue_trials([2,3])=sort(cue_trials([2,3]));
  if(neuidx==0) neuidx=1:nNeu; end;  %initialize neuidx if it is not input
  cue_id=cue_trials(1);tid_s=cue_trials(2);tid_t=cue_trials(3);
  mi3=zeros(nNeu,length(xPoints));
  for i=1:nNeu;for j=1:l;
    mi3(i,j)=(cell2mat(mi(i,j,cue_id)))(tid_s,tid_t);
  end;end;
  mi3=max(mi3,0);
  global type;
  plot(xPoints,mi3(neuidx,:));xlabel(xlbl);ylabel(type);
  title([cell2mat(cue_name(cue_id)),': trial ',num2str(tid_s),'-',num2str(tid_t),' ',type,' on all neurons']);
  %legend(num2str((1:nNeu)(neuidx)'));%legend(num2str((1:nNeu)'));
end
%1st->cueID, 2nd->trialFrom, 3rd->trialTo
showMI_xt_sample(mi,log10(window_size/timeUnit2ms),'log10(window size)',cue_name,[1,3,5])
showMI_xt_sample(mi,log10(window_size/timeUnit2ms),'log10(window size)',cue_name,[1,3,5],1:9)
ylim([0,1]);

%figure for MI of one neuron on all trial-pairs on given cue
function showMI_xt_neuron(mi,xPoints,xlbl,cue_name,nid,cue_id,form='bunch',form_arg=299)
  [nNeu,l,nCue]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoints and mi');  end;
  nTri=length(cell2mat(mi(1)));
  idx=find(triu(ones(nTri),1)); %length(idx)=nTri*(nTri-1)/2;
  mi4=zeros(length(idx),length(xPoints));
  for wid=1:l;
    mi4(:,wid)=cell2mat(mi(nid,wid,cue_id))(idx);
  end;
  mi4=max(mi4,0);
  if(strcmp(form,'bunch'))
    if(form_arg<=0 || form_arg>=length(idx))
      plot(xPoints,mi4,xPoints,mean(mi4,1),'linewidth',4);
    else
      form_arg=fix(form_arg/7)*7+5;%7 colors. 6th is good for bold
      idx=randi(length(idx),form_arg,1);
      plot(xPoints,mi4(idx,:),xPoints,mean(mi4,1),'linewidth',4);
    end
  else %error-bar
    m=mean(mi4);s=mean(mi4);
    errorbar(xPoints,m,min(s,m),min(s,1-m));
  end
  global type;
  xlabel(xlbl);ylabel(type);
  %title([cell2mat(cue_name(cue_id)),': Neuron ',num2str(nid),' ',type,' on all trial pairs']);
  title([cell2mat(cue_name(cue_id)),': Neuron ',num2str(nid),' ',type]);
end
showMI_xt_neuron(mi,log10(window_size/timeUnit2ms),'log10(window size)',cue_name,3,1)

for i=1:9
  subplot(3,3,i);showMI_xt_neuron(mi,log10(window_size/timeUnit2ms),'log10(window size)',cue_name,i,1)
end;

for i=1:9;  %all cue, error bar
  subplot(3,3,mod(i-1,9)+1);hold all;
  for j=1:nCue;
    showMI_xt_neuron(mi,log10(window_size/timeUnit2ms),'log10(window size)',cue_name,i,j,'errorbar')
  end
  title(['Neuron ',num2str(i),' ',type]);%legend(num2str((1:nCue)'))
  xlim(log10(window_size([1,end])/timeUnit2ms)+[-0.1,0.1]);
  hold off;
end;

###################
#cross CUE mutual information on identical neuron

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
function showMI_xc(mi,xPoints,nid,nCue)
  [nNeu,l]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoints and mi');  end;
  idx=[]; ticks=num2str([]);
  for i=1:nCue;for j=i+1:nCue;
    idx=[idx; i+nCue*(j-1)];
    ticks=[ticks; sprintf('%d-%d',i,j)];
  end;end;
  sort(idx);
  data=zeros(length(idx),l);
  for j=1:l;  data(:,j)=cell2mat(mi(nid,j))(idx); end;
  global type
  plot(xPoints,data);title(['N',num2str(nid),' X-cue ',type]);%ylabel(type);%legend(ticks)
end

for nid=1:nNeu;%log-scale
  subplot(4,5,nid);showMI_xc(mi,log10(window_size/timeUnit2ms),nid,nCue);grid;
  set(gca,'xtick',1:4);xlabel('log10(WS)');ylim([0,1]);
end;

for nid=1:nNeu;%linear-scale
  subplot(4,5,nid);showMI_xc(mi,(window_size/timeUnit2ms),nid,nCue);grid;
  set(gca,'xtick',[5:5:20]*100);set(gca,'xticklabel',{'';'1s';'';'2s'});ylim([0,1]);
end;

nid=1;
showMI_xc(mi,log10(window_size/timeUnit2ms),nid,nCue);




