addpath([pwd,'/../mBasic/'])
addpath([pwd,'/fine2/'])

pre_fn='E:\Data\Data for MUA\';
pre_fn_sub={'PL','IL','OFC'};

[fnl_ps,fnl_pb]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(1))]);
%[fnl_is,fnl_ib]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(2))]);
%[fnl_os,fnl_ob]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(3))]);
[~,~,fnl_e]=makeFileListOfFolder([pre_fn,'PFC_events']);
map_p=mapBehFile2EvnFile(fnl_pb,fnl_e);
%map_i=mapBehFile2EvnFile(fnl_ib,fnl_e);
%map_o=mapBehFile2EvnFile(fnl_ob,fnl_e);

%countTrials(fnl_pb)
nTri=50;
nCue=2;

timeUnit2ms=10;
trialLength=10*1000*timeUnit2ms;

%data=zeros(nTri,nNeu,nCue);
[data,nNeuList]=pickTrialFromFiles(fnl_ps,fnl_pb,1:nCue,1:nTri,-1000*timeUnit2ms,-8000*timeUnit2ms);
nNeu=size(data,2); %nNeu=sum(nNeuList);
nNeuSum=[0;cumsum(nNeuList)(:)];

binSize=50*timeUnit2ms;
maxTime=3000*timeUnit2ms;
nBin=ceil(maxTime/binSize);

rt=zeros(nBin,nTri,nNeu,nCue);
for cid=1:nCue; for nid=1:nNeu; for tid=1:nTri;
  rt(:,tid,nid,cid)=discretize(data(tid,nid,cid),binSize,0,ceil(maxTime/binSize),'count');
end;end;end;
rtz=zscore(rt);

return

rts=zeros(nBin,nTri,nNeu,nCue);
for cid=1:nCue;
  tic;for nid=1:nNeu;for tid=1:nTri;
    #rts(:,tid,nid,cid)=regdatasmooth(1:vecLength,rt(:,tid,nid,cid));
    #rts(:,tid,nid,cid)=rgdtsmcore((1:vecLength)',rt(:,tid,nid,cid),2,2);
    rts(:,tid,nid,cid)=max(0,smooth(rt(:,tid,nid,cid)',9,'sgolay')');
  end;end;toc;
end;
%save('rts_a.mat','rts')

##############
# analysis
##############

##############
# event

%trialInfo=genTrialInfo(readCue(fnl_pb(1)),1:nCue,1:nTri);
%event=readEvent(fnl_e(1));
%event=readEvent(fnl_e(map_p(1)));
%x=makeTrialEventTable(trialInfo,event,[8 10;9 9],-100);sum(x)
%y=makeTrialEventTableFromFile(fnl_pb(1),fnl_e(map_p(1)),1:nCue,1:nTri,0,0,[8 10;9 9],-100);sum(y)

%[rid,lnid]=mapNid2Local(31,nNeuList);

%entPhase=zeros(nCue,nPha); %(:,1)->init event, (:,2)->first phasic event
%entPhase=[8 6 10;9 9 9];
entPhase=[8 10;9 9];
nPha=size(entPhase,2);

%trialPhase=zeros(nTri,nCue,length(fnl_pb)); %values in range [0,nPha]
%function trialPhase=makeTrialPhaseFromFiles(fnlb,fnle,fmap,entPhase,nTri,offset=-100)
trialPhase=makeTrialPhaseFromFiles(fnl_pb,fnl_e,map_p,entPhase,nTri);

function rtpm=calPhaseRTEM(rt,nNeuList,trialPhase,nPha)
  [nBin,nTri,nNeu,nCue]=size(rt);
  [~,~,nFile]=size(trialPhase);
  nNeuSum=[0;cumsum(nNeuList)(:)];
  rtpm=zeros(nBin,nNeu,nCue,nPha+1);
  for fid=1:nFile;
    nids=(nNeuSum(fid)+1):nNeuSum(fid+1);
    for cid=1:nCue; for pid=0:nPha;
      tids=find(trialPhase(:,cid,fid)==pid);
      rtpm(:,nids,cid,pid+1)=reshape(mean(rt(:,tids,nids,cid),2),nBin,nNeuList(fid));
  end;end;end
end
rtpm=calPhaseRTEM(rt,nNeuList,trialPhase,nPha);

##############
# display:
function setTimeX(nBin,nPoints,tickBeg,tickEnd)
  set(gca,'xtick',floor(linspace(0,nBin,nPoints)));
  set(gca,'xticklabel',linspace(tickBeg,tickEnd,nPoints));
end

rtm=reshape(mean(rt,2),nBin,nNeu,nCue);
rtmz=zscore(rtm);
rtsm=reshape(mean(rts,2),nBin,nNeu,nCue);
rtsz=zscore(rts);
rtsmz=zscore(rtsm);

rtpmz=zscore(rtpm);

cid=1;
%imagesc(rtmz(:,:,cid)');colorbar;
function idx=reorderMatIdx(rtm_mat,range,method=@sumsq)
  [nBin,nNeu]=size(rtm_mat);
  t=sortrows([method(rtm_mat(range,:))',(1:nNeu)']);
  idx=t(:,2);
end

function showByRng(rtm,cid,rng,nPoints,tickBeg,tickEnd,tltPre='',crng='auto',method=@sum)
  idx=reorderMatIdx(rtm(:,:,cid),rng,method);
  imagesc(rtm(:,idx,cid)');colorbar;caxis(crng);
  setTimeX(size(rtm,1),nPoints,tickBeg,tickEnd);
  xlabel('time');ylabel('neuron');title([tltPre,'cue: ',num2str(cid)]);
end

%idx=reorderMatIdx(rtmz(:,:,cid),1:nBin,@sumsq);
%idx=reorderMatIdx(rtmz(:,:,cid),21:40,@sum);
%imagesc(rtmz(:,idx,cid)');setTimeX(nBin,7,-1,2);colorbar;
%idx=reorderMatIdx(rtemz(:,:,cid),21:40,@sum);
%imagesc(rtemz(:,idx,1,cid)');setTimeX(nBin,7,-1,2);colorbar;

rng=21:40;
showByRng(rtm,cid,rng,7,-1,2,'sc ',[0 1.4])
showByRng(rtmz,cid,rng,7,-1,2,'zscore ');caxis()
showByRng(rtmz,cid,1:nBin,7,-1,2,'zscore ',[-3 5],@sumsq)
showByRng(rtsmz,cid,rng,7,-1,2)
pid=1;
showByRng(reshape(rtpmz(:,:,:,pid),nBin,nNeu,nCue),cid,rng,7,-1,2);caxis()
showByRng(reshape(rtpmz(:,:,:,pid),nBin,nNeu,nCue),cid,rng,7,-1,2,'zscore ',[-3 7])


close all
for cid=1:2;figure
  showByRng(rtmz,cid,rng,7,-1,2,'zscore ',[-3 5],@sum);
end

##############
# neuron grouping

function sepIds=sepByThrsld(values,thresholds)
%return number of values that are smaller than the thresholds
  if(!iscolumn(values)); values=values(:);end
  if(!isrow(thresholds)); thresholds=thresholds(:)';end
  sepIds=sum(values<thresholds);
end
%sepIds=sepByThrsld(sum(rtmz(21:40,idx_r,1)),[-1 1])

%on count:
rng=1:nBin;
cid=1;
idx_c=reorderMatIdx(rtm(:,:,cid),rng,@sum);

t=sum(rtm(rng,idx_c,cid));
hist(t,20);%[-1,1]
th_c=[9 30];
th_c=quantile(t,[1/3 2/3]);
sep_c=sepByThrsld(sum(rtm(rng,idx_c,cid)),th_c);

%neuGpTbl_c=size(nRat,nSep)
%function tbl=calNeuGroupTbl(nRat,sep,idx,nNeuSum)
neuGpTbl_c=calNeuGroupTbl(length(fnl_pb),idx_c,sep_c,nNeuList);

neuGpTbl_cnt_c=zeros(size(neuGpTbl_c));
for i=1:size(neuGpTbl_c,1);for j=1:size(neuGpTbl_c,2)
  neuGpTbl_cnt_c(i,j)=length(cell2mat(neuGpTbl_c(i,j)));
end;end
neuGpTbl_cnt_c

%on z-score:
rng=21:40;
cid=1;
idx_zs=reorderMatIdx(rtmz(:,:,cid),rng,@sum);

t=sum(rtmz(rng,idx_r,cid));
hist(t,20);%[-1,1]
th_zs=[-1 1];
sep_zs=sepByThrsld(sum(rtmz(rng,idx_r,cid)),th_zs);

%function tbl=calNeuGroupTbl(nRat,sep,idx,nNeuSum)
neuGpTbl_zs=calNeuGroupTbl(length(fnl_pb),idx_zs,sep_zs,nNeuList);

neuGpTbl_cnt_zs=zeros(size(neuGpTbl_zs));
for i=1:size(neuGpTbl_zs,1);for j=1:size(neuGpTbl_zs,2)
  neuGpTbl_cnt_zs(i,j)=length(cell2mat(neuGpTbl_zs(i,j)));
end;end
neuGpTbl_cnt_zs

#correalation
function cor=calCorr(rtm,nids)
  nNeu=lenght(nids);
  cor=zeros(nNeu);
  for i=1:nNeu; for j=1:nNeu;
    cor(i,j)=corr(rtm(:,nids(i)),rtm(:,nids(j)));
  end;end
end
function showCorr(cor,nidsnids)
  imagesc(cor);colorbar;caxis([-1 1]);
  xticklabel(num2str(nids(:)));yticklabel(num2str(nids(:)));
end

rid=1;
nids=cell2mat(neuGpTbl_zs(rid,[1,end])')
cor=calCorr(rtm(:,:,cid),nids);
showCorr(cor,nids)


##############
#overlay:
function [nOlTop,nOlBottom]=calOverlap(rtm,rng,method=@sum)
  nNeu=size(rtm,2);
  idx1=reorderMatIdx(rtm(:,:,1),rng);
  idx2=reorderMatIdx(rtm(:,:,2),rng);
  nOlTop=zeros(nNeu,1);
  nOlBottom=zeros(nNeu,1);
  for i=1:nNeu
    nOlTop(i)=length(intersect(idx1(nNeu+1-i:end),idx2(nNeu+1-i:end)));
    nOlBottom(i)=length(intersect(idx1(1:i),idx2(1:i)));
  end
end

rng=21:40;
nOvlp=calOverlap(rtm,rng,@sum);
plot(nOvlp);line([0,nNeu],[0,nNeu],'linestyle','--','color','r');
xlabel('for top x neuorns');ylabel('# of overlap')

for i=1:4;rng=[(i*10+11):i*10+20];
  subplot(2,2,i);[lt,lb]=calOverlap(rtmz,rng,@sum);
  [lt(20),lb(20)]
  plot(1:nNeu,lt,1:nNeu,lb,1:nNeu,'--');
  legend({'top k','bottom k','best line'},'location','southeast')
  xlabel('for top x neuorns');ylabel('# of overlap');
  title(['range ',num2str(i*0.5-0.5),'s-',num2str(i*0.5),'s']);
end




