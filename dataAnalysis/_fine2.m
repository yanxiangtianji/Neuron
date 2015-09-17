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

%rlnID=mapGNId2Local(31,nNeuList);

%entPhase=zeros(nCue,nPha); %(:,1)->init event, (:,2)->first phasic event
%entPhase=[8 6 10;9 9 9];
entPhase=[8 10;9 9];
nPha=size(entPhase,2);

%trialPhase=zeros(nTri,nCue,length(fnl_pb)); %values in range [1,nPha]
%function trialPhase=makeTrialPhaseFromFiles(fnlb,fnle,fmap,entPhase,nTri,offset=-100)
trialPhase=makeTrialPhaseFromFiles(fnl_pb,fnl_e,map_p,entPhase,nTri,'offset');

function rtpm=calPhaseRTEM(rt,nNeuList,trialPhase,phaRng)
  [nBin,nTri,nNeu,nCue]=size(rt);
  [~,~,nFile]=size(trialPhase);
  nNeuSum=[0;cumsum(nNeuList)(:)];
  rtpm=zeros(nBin,nNeu,nCue,length(phaRng));
  for fid=1:nFile;
    nids=(nNeuSum(fid)+1):nNeuSum(fid+1);
    for cid=1:nCue; for pid_i=1:length(phaRng); pid=phaRng(pid_i);
      tids=find(trialPhase(:,cid,fid)==pid);
      rtpm(:,nids,cid,pid)=reshape(mean(rt(:,tids,nids,cid),2),nBin,nNeuList(fid));
  end;end;end
end
rtpm=calPhaseRTEM(rt,nNeuList,trialPhase,1:nPha);

##############
# other normalization:

%function z=baselineZscore(x,rngBL,dim=1);

##############
# display:

rtm=reshape(mean(rt,2),nBin,nNeu,nCue);
rtmz=zscore(rtm);
rtmz2=baselineZscore(rtm,1:20,1);
rtzm=reshape(mean(rtz,2),nBin,nNeu,nCue);

rtsm=reshape(mean(rts,2),nBin,nNeu,nCue);
rtsz=zscore(rts);
rtsmz=zscore(rtsm);

rtpmz=zscore(rtpm);
rtpmz2=baselineZscore(rtpm,1:20,1);

cid=1;
%imagesc(rtmz(:,:,cid)');colorbar;
function idx=sortedRowsId(rtm_mat,method=@sumsq)
  [~,idx]=sortrows([method(rtm_mat(:,:))',(1:size(rtm_mat,2))']);
end

function setTimeX(nBin,nPoints,tickBeg,tickEnd)
  set(gca,'xtick',floor(linspace(0,nBin,nPoints)));
  set(gca,'xticklabel',linspace(tickBeg,tickEnd,nPoints));
end
function showByRng(rtm,cid,rng,nPoints,tickBeg,tickEnd,tltPre='',crng='auto',method=@sum)
  idx=sortedRowsId(rtm(rng,:,cid),method);
  imagesc(rtm(:,idx,cid)');colorbar;caxis(crng);
  setTimeX(size(rtm,1),nPoints,tickBeg,tickEnd);
  xlabel('time');ylabel('neuron');title([tltPre,'cue: ',num2str(cid)]);
end

%idx=sortedRowsId(rtmz(:,:,cid),@sumsq);
%idx=sortedRowsId(rtmz(21:40,:,cid),@sum);
%imagesc(rtmz(:,idx,cid)');setTimeX(nBin,7,-1,2);colorbar;
%idx=sortedRowsId(rtemz(21:40,:,cid),@sum);
%imagesc(rtemz(:,idx,1,cid)');setTimeX(nBin,7,-1,2);colorbar;

rng=21:40;
showByRng(rtm,cid,rng,7,-1,2,'sc ',[0 1.4])
showByRng(rtmz,cid,rng,7,-1,2,'zscore ');caxis()
showByRng(rtmz,cid,1:nBin,7,-1,2,'zscore ',[-3 5],@sumsq)
showByRng(rtmz2,cid,21:nBin,7,-1,2,'bl-zscore ')
showByRng(rtmz2,cid,21:40,7,-1,2,'bl-zscore ')

showByRng(rtsmz,cid,rng,7,-1,2)

pid=2;
showByRng(rtpmz(:,:,:,pid),cid,rng,7,-1,2);caxis()
showByRng(rtpmz(:,:,:,pid),cid,rng,7,-1,2,'complete trials zscore ',[-3 5])


close all
for cid=1:2;figure
  showByRng(rtmz,cid,rng,7,-1,2,'zscore ',[-3 5],@sum);
%  showByRng(rtmz2,cid,rng,7,-1,2,'zscore ',[-4 6],@sum);
end

##############
# neuron grouping

%function sepIds=sepByThrsld(values,thresholds)
%sepIds=sepByThrsld(sum(rtmz(21:40,idx_r,1)),[-1 1])

%on count:
rng=1:nBin;
cid=1;
idx_c=sortedRowsId(rtm(rng,:,cid),@sum);

t=sum(rtm(rng,:,cid));
%hist(t,20);
th_c=[9 30];
th_c=quantile(t,[20 70]/nNeu);
sep_c=sepByThrsld(sum(rtm(rng,idx_c,cid)),th_c);

%neuGpTbl_c=size(nRat,nSep)
%function tbl=calNeuGroupTbl(nNeuList,sep,idx)
neuGpTbl_c=calNeuGroupTbl(nNeuList,idx_c,sep_c);

neuGpTbl_cnt_c=zeros(size(neuGpTbl_c));
for i=1:size(neuGpTbl_c,1);for j=1:size(neuGpTbl_c,2)
  neuGpTbl_cnt_c(i,j)=length(cell2mat(neuGpTbl_c(i,j)));
end;end
neuGpTbl_cnt_c

%on z-score:
rng=21:40;
cid=1;
idx_zs=sortedRowsId(rtmz(rng,:,cid),@sum);

t=mean(rtmz(rng,:,cid));
%hist(t,20);
th_zs=[-0.25,0.25];
sep_zs=sepByThrsld(mean(rtmz(rng,idx_zs,cid)),th_zs);
neuGpTbl_zs=calNeuGroupTbl(nNeuList,idx_zs,sep_zs);

neuGpTbl_cnt_zs=zeros(size(neuGpTbl_zs));
for i=1:size(neuGpTbl_zs,1);for j=1:size(neuGpTbl_zs,2)
  neuGpTbl_cnt_zs(i,j)=length(cell2mat(neuGpTbl_zs(i,j)));
end;end
neuGpTbl_cnt_zs

%on shape:

%function showShape(rtm,nRow,nCol,nids,nNeuList, nTick,tickBeg,tickEnd,dashThre)
showShape(rtm(:,:,1),5,4,idx_zs(1:20),nNeuList,4,-1,2,0.1)

cid=1;nRow=4;nCol=4;
for fid=1:6;
  nids=idx_zs(fid*nRow*nCol-nRow*nCol+1:min(end,fid*nRow*nCol));
  close;showShape(rtm(:,:,cid),nRow,nCol,nids,nNeuList,4,-1,2,0.03);
  saveas(gcf,[num2str(fid) '.png']);
end

%function res=condenseIntoPeriods(rtm,sepperORinterval)
%y=condenseIntoPeriods(rtm(:,1,1),10)
%rtmc=condenseIntoPeriods(rtm,10);
rtmc=condenseIntoPeriods(rtm,[1,20,30,40]);

cid=1;
[~,idx_s]=sort(rtmc(2,:,cid)./rtmc(1,:,cid));
th_s=[0.5, 2];
sep_s=sepByThrsld(rtmc(2,:,cid)./rtmc(1,:,cid),th_s);;
neuGpTbl_s=calNeuGroupTbl(nNeuList,idx_s,sep_s);

neuGpTbl_cnt_s=zeros(size(neuGpTbl_s));
for i=1:size(neuGpTbl_s,1);for j=1:size(neuGpTbl_s,2)
  neuGpTbl_cnt_s(i,j)=length(cell2mat(neuGpTbl_s(i,j)));
end;end
neuGpTbl_cnt_s


##############
# correalation
%function cor=calCorr(rtm,nids)
%function showCorr(cor,nids)

rid=1;
rng=21:40;
nids=cell2mat(neuGpTbl_zs(rid,[1,end])')
cor=calCorr(rtm(rng,:,cid),rlnID(:,2));
%showCorr(cor,nids)
rlnID=mapGNId2Local(nids,nNeuList);
showCorr(cor,rlnID(:,2))

%frequent neurons with significant changes
function gp=pickNeuronSet(gp_count,gp_zscore)
  nRat=size(gp_count,1);
  gp=cell(nRat,1);
  for i=1:nRat
    gp(i)=intersect(cell2mat(gp_count(i,:)'),cell2mat(gp_zscore(i,:)'));
  end
end
gp=pickNeuronSet(neuGpTbl_c(:,3),neuGpTbl_zs(:,[1 end]));

rid=4;
for rid=1:6; if(length(cell2mat(gp(rid)))<2); continue; end;
figure
nids=cell2mat(gp(rid));
%showCorr(calCorr(rtm(rng,:,cid),nids),nids)
showCorr(calCorr(rtmz2(rng,:,cid),nids),mapGNId2Local(nids,nNeuList)(:,2));
title(["rat ",num2str(rid),' frequent responsing'])
end


##############
#overlay:
function [nOlTop,nOlBottom]=calOverlap(rtm,rng,method=@sum)
  nNeu=size(rtm,2);
  idx1=sortedRowsId(rtm(rng,:,1),method);
  idx2=sortedRowsId(rtm(rng,:,2),method);
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




