###################
#cross NEUORN mutual information on identical period

%load data
addpath('../mRegression/')
basicParameters
rData=readRaw([fn_prefix,'all.txt']);
rmpath('../mRegression/')

%mutual information:
global disFun=@(data,ws,off,len)discretize(data,ws,off,len,'count');
global infoFun=@(data1,data2)mutual_info(data1,data2);
%dot product:
global disFun=@(data,ws,off,len)discretize(data,ws,off,len,'binary');
global infoFun=@(data1,data2)dot_product(data1,data2);
%Pearson correlation:
global disFun=@(data,ws,off,len)discretize(data,ws,off,len,'count');
global infoFun=@(data1,data2)corr(data1(:),data2(:));

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
plot(window_size/timeUnit2ms,mi(i,j,:)(:));xlabel('windows size(ms)');ylabel('MI');
title(['MI between ',num2str(i),' and ',num2str(j)]);

function showMI_xn(xPoints,mi)
  [nNeu,~,l]=size(mi);
  if(length(xPoints)!=l)  error('Unmatched xPoint and mi');  end;
  idx=find(triu(ones(nNeu),1));
  mi2=zeros(l,length(idx));
  for i=1:length(idx);
    ii=mod(idx(i)-1,nNeu)+1;
    jj=ceil(idx(i)/nNeu);
    mi2(:,i)=mi(ii,jj,:)(:);
  end;
  plot(xPoints,mi2);ylabel('MI');title('MI of all neuron pairs on whole period(4k seconds)')
end
showMI_xn(log10(window_size/timeUnit2ms),mi);xlabel('log10(window size) (ms)');
showMI_xn(window_size/timeUnit2ms,mi);xlabel('window size (ms)');


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

maxTime=findMaxTime(rDataList);%=100000, log10(maxTime/timeUnit2ms)=5

window_size=[((1:2:10)'*(10.^(1:3)))(:);10^4]*timeUnit2ms; %log-scale
window_size=[0.5, 1:2:20, 20]*100*timeUnit2ms;  %around peak 

function mi=calMI_xt_one(rDataList,idx,maxTime,ws)
  nTri=size(rDataList,1);
  vecLength=ceil(maxTime/ws);
  data=zeros(vecLength,nTri);
  global disFun infoFun
  for i=1:nTri;
    data(:,i)=disFun(cell2mat(rDataList(i,idx)),ws,0,vecLength);
  end;
  mi=zeros(nTri);
  for i=1:nTri;for j=i+1:nTri; mi(i,j)=infoFun(data(:,i),data(:,j)); end;end;
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

save('Xtrial-log.mat','window_size','mi');
save('Xtrial-focus.mat','window_size','mi');

%figure for mean MI over all trial-pairs of same cue
function showMI_xt(mi,xPoints,cue_name,nTri)
  [nNeu,l,nCue]=size(mi);
  if(length(xPoints)!=l)  error('Unmatched xPoint and mi');  end;
  if(length(cue_name)!=nCue)  error('Unmatched cue_name length and mi');  end;
  mi2=zeros(size(mi));
  for i=1:prod(size(mi)); mi2(i)=sum(sum(cell2mat(mi(i)))); end;
  mi2/=(nTri-1)*nTri/2;
  for cue_id=1:nCue;
    subplot(2,2,cue_id);plot(xPoints,mi2(:,:,cue_id));
    title([cell2mat(cue_name(cue_id)),' X-trial MI on all neurons']);
    xlabel('log10(window size)');ylabel('mean MI over all trial-pairs');
    %legend(num2str((1:nNeu)'));
  end;
end
showMI_xt(mi,log10(window_size/timeUnit2ms),cue_name,nTri)

%figure for MI of 4 trial pairs on their own cues
function showMI_xt_4single(mi,xPoints,cue_name,cue_trials_mat)
  %cue_trials_mat(1,1)-cueID, cue_trials_mat(1,2)-trialFrom, cue_trials_mat(1,3)-trialTo
  [nNeu,l,nCue]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoint and mi');  end;
  len=length(cue_trials_mat,1);
  if(size(cue_trials_mat,2)!=3)  error('Wrong coordinate size'); end;
  %make sure trial_id_source is small that trial_id_target (mi is symmetric)
  cue_trials_mat=sort(tid_mat,2);
  mi3=zeros(nNeu,length(xPoints));
  for k=1:min(4,len); %first 4
    cue_id=cue_trials_mat(k,1);tid_s=cue_trials_mat(k,2);tid_t=cue_trials_mat(k,3);
    for i=1:nNeu;for j=1:l;
      mi3(i,j)=(cell2mat(mi(i,j,cue_id)))(tid_s,tid_t);
    end;end;
    mi3=max(mi3,0);
    subplot(2,2,k);plot(xPoints,mi3(:,:));xlabel('log10(window size)');ylabel('MI');
    title([cell2mat(cue_name(cue_id)),': trial ',num2str(tid_s),'-',num2str(tid_t),' MI on all neurons']);
    %legend(num2str((1:nNeu)'));
  end
end

tid_mat=[zeros(4,1)+2,zeros(4,1)+5];
showMI_xt_4single(mi,log10(window_size/timeUnit2ms),cue_name,[(1:4)';tid_mat)
showMI_xt_4single(mi,log10(window_size/timeUnit2ms),cue_name, ...
  [1 3 5; 2 5 8; 3 8 14; 4 9 19])


###################
#cross CUE mutual information on identical neuron

%initialization part is the same as cross TRIAL part

function mi=calMI_xc_one(rDataList1,rDataList2,idx,maxTime,ws)
%mean MI for all trial pairs
  vecLength=ceil(maxTime/ws);
  l1=length(rDataList1); l2=length(rDataList2);
  data1=zeros(vecLength,length(rDataList1));
  global disFun infoFun
  for i=1:l1;
    data1(:,i)=disFun(cell2mat(rDataList1(i,idx)),ws,0,vecLength);    
  end;
  mi=0; %mi=zeros(l1,l2);
  for i=1:l2;
    data2=discretize(cell2mat(rDataList2(i,idx)),ws,0,vecLength);    
    for j=1:l1;
      mi+=infoFun(data2,data1(:,j));
      %mi(j,i)=infoFun(data2,data1(:,j));
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

window_size=[((1:2:10)'*(10.^(1:3)))(:);10^4]*timeUnit2ms; %log-scale
window_size=[0.5, 1:2:20, 20]*100*timeUnit2ms;  %around peak 

%type: mi=cell(nNeu,length(window_size)); mi(1)=zeros(nCue);
mi=calMI_xc(rDataList,window_size);
save('Xcue-log.mat','window_size','mi');

save('Xcue-focus.mat','window_size','mi');


function showMI_xc(mi,xPoints,nid,nCue)
  [nNeu,l]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoint and mi');  end;
  idx=[]; ticks=num2str([]);
  for i=1:nCue;for j=i+1:nCue;
    idx=[idx; i+nCue*(j-1)];
    ticks=[ticks; sprintf('%d-%d',i,j)];
  end;end;
  sort(idx);
  data=zeros(length(idx),l);
  for j=1:l;  data(:,j)=cell2mat(mi(nid,j))(idx); end;
  plot(xPoints,data);%legend(ticks)
end

for nid=1:nNeu;%log-scale
  subplot(4,5,nid);showMI_xc(mi,log10(window_size/timeUnit2ms),nid,nCue);grid;set(gca,'xtick',1:4)
  title(['N',num2str(nid),' X-cue MI']);xlabel('log10(WS)');%ylabel('MI');
end;

for nid=1:nNeu;%linear-scale
  subplot(4,5,nid);showMI_xc(mi,(window_size/timeUnit2ms),nid,nCue);
  set(gca,'xtick',[5:5:20]*100);set(gca,'xticklabel',{'';'1s';'';'2s'});grid;
  title(['N',num2str(nid),' X-cue MI']);%xlabel('log10(WS)');ylabel('MI');
end;

nid=1;
showMI_xc(mi,log10(window_size/timeUnit2ms),nid,nCue);




