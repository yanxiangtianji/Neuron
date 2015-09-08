addpath([pwd,'/../mBasic/'])

pre_fn='E:\Data\Data for MUA\';
pre_fn_sub={'PL','IL','OFC'};

[fnl_ps,fnl_ph]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(1))]);
[fnl_is,fnl_ih]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(2))]);
[fnl_os,fnl_oh]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(3))]);

%countTrials(fnl_ph)
nTri=50;
nCue=2;

timeUnit2ms=10;
trialLength=10*1000*timeUnit2ms;

%data=zeros(nTri,nNeu,nCue);
data=pickTrialFromFiles(fnl_ps,fnl_ph,1:nCue,1:nTri,-1000*timeUnit2ms,-8000*timeUnit2ms);
nNeu=size(data,2);

binSize=50*timeUnit2ms;
maxTime=3000*timeUnit2ms;
nBin=ceil(maxTime/binSize);

rt=zeros(nBin,nTri,nNeu,nCue);
for cid=1:nCue; for nid=1:nNeu; for tid=1:nTri;
  rt(:,tid,nid,cid)=discretize(data(tid,nid,cid),binSize,0,ceil(maxTime/binSize),'count');
end;end;end;
rtz=zscore(rt);

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

function setTimeX(nBin,nPoints,tickBeg,tickEnd)
  set(gca,'xtick',floor(linspace(0,nBin,nPoints)));
  set(gca,'xticklabel',linspace(tickBeg,tickEnd,nPoints));
end

rtm=reshape(mean(rt,2),nBin,nNeu,nCue);
rtzm=reshape(mean(rtz,2),nBin,nNeu,nCue);
rtsm=reshape(mean(rts,2),nBin,nNeu,nCue);
rtsz=zscore(rts);
rtszm=reshape(mean(rtsz,2),nBin,nNeu,nCue);

cid=1;
%imagesc(rtzm(:,:,cid)');colorbar;
function idx=reorderMatIdx(rtm_mat,range,method=@sumsq)
  [nBin,nNeu]=size(rtm_mat);
  t=sortrows([method(rtm_mat(range,:))',(1:nNeu)']);
  idx=t(:,2);
end

function showByRng(rtm,cid,range,nPoints,tickBeg,tickEnd,tltPre='',crng='auto',method=@sum)
  idx=reorderMatIdx(rtm(:,:,cid),range,method);
  imagesc(rtm(:,idx,cid)');colorbar;caxis(crng);
  setTimeX(size(rtm,1),nPoints,tickBeg,tickEnd);
  xlabel('time');ylabel('neuron');title([tltPre,'cue: ',num2str(cid)]);
end

%idx=reorderMatIdx(rtzm(:,:,cid),1:nBin,@sumsq);
%idx=reorderMatIdx(rtzm(:,:,cid),21:40,@sum);
%imagesc(rtzm(:,idx,cid)');setTimeX(nBin,7,-1,2);colorbar;

rng=21:40;
showByRng(rtm,cid,rng,7,-1,2,'sc ',[0 1.4])
showByRng(rtzm,cid,rng,7,-1,2,'zscore ',[-0.5 0.9])
showByRng(rtzm,cid,1:nBin,7,-1,2,'zscore ',[-0.5 0.9],@sumsq)
showByRng(rtszm,cid,rng,7,-1,2)

close all
for cid=1:2;figure
  showByRng(rtzm,cid,rng,7,-1,2,'zscore ',[-0.5 0.9],@sumsq);
end

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
  subplot(2,2,i);[lt,lb]=calOverlap(rtzm,rng,@sum);
  [lt(20),lb(20)]
  plot(1:nNeu,lt,1:nNeu,lb,1:nNeu,'--');
  legend({'top k','bottom k','best line'},'location','southeast')
  xlabel('for top x neuorns');ylabel('# of overlap');
  title(['range ',num2str(i*0.5-0.5),'s-',num2str(i*0.5),'s']);
end


