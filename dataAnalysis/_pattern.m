addpath([pwd,'/../mBasic/'])
addpath([pwd,'/fine2/'])
addpath([pwd,'/pattern/'])

pre_fn='E:\Data\Data for MUA\';
pre_fn_sub={'PL','IL','OFC'};

%[fnl_sp,fnl_bp]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(1))]);
%[fnl_si,fnl_bi]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(2))]);
%[fnl_so,fnl_bo]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(3))]);
%fnl_s=fnl_sp;fnl_b=fnl_bp;

[~,~,fnl_e]=makeFileListOfFolder([pre_fn,'PFC_events']);
%fnm_be_p=mapBehFile2EvnFile(fnl_bp,fnl_e);
%fnm_be_i=mapBehFile2EvnFile(fnl_bi,fnl_e);
%fnm_be_o=mapBehFile2EvnFile(fnl_bo,fnl_e);
%fnm_be=fnm_be_p;

[fnl_s,fnl_b]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(2))]);
fnm_be=mapBehFile2EvnFile(fnl_b,fnl_e);

rat_name={'R001','R002','R003','R004','R005','R006','R009','R016','R017','R018','R096','R108'};
%countTrials(fnl_b)
nCue=1;
cid=1;
nRat=length(fnl_b);

timeUnit2ms=10;
trialLength=10*1000*timeUnit2ms;

##############
# event related data

%event ID:
%8: reward tone
%6: reward lever pushed
%10: for sucrose pump, 11: for well entry. 10 is usually before 11.

%entPhase=[8 6 10];
entPhase=[8 6 11];

nPha=length(entPhase);

function nVld=checkNTri(fnl_b,fnl_e,cid,entPhase,offMismatch)
  nVld=zeros(length(fnl_b),1);
  for i=1:length(fnl_b)
    times=findEventTimeInTrialByFile(fnl_b(i),fnl_e(i),cid,entPhase,offMismatch,true);
    nVld(i)=sum(all(isnan(times)==0,2));
    disp([size(times,1) nVld(i)])
  end
end
%nVld=checkNTri(fnl_b,fnl_e(fnm_be),1,entPhase,-1000*timeUnit2ms);
%nTri=min(nVld)

nTri=41;

%data=cell(nTri,nNeu,nPha);
[data,nNeuList]=pickTrialByEventFromFiles(fnl_s,fnl_b,fnl_e(fnm_be),1,nTri,entPhase,-1000*timeUnit2ms,2000*timeUnit2ms,-500*timeUnit2ms,true);
nNeu=size(data,2); %nNeu=sum(nNeuList);
nNeuSum=[0;cumsum(nNeuList)(:)];

binSize=50*timeUnit2ms;
maxTime=3000*timeUnit2ms;
nBin=ceil(maxTime/binSize);

rt=zeros(nBin,nTri,nNeu,nPha);
for pid=1:nPha; for nid=1:nNeu; for tid=1:nTri;
  rt(:,tid,nid,pid)=discretize(data(tid,nid,pid),binSize,0,ceil(maxTime/binSize),'count');
end;end;end;
%rtz=zscore(rt);

rtm=squeeze(mean(rt,2));% size=(nBin,nNeu,nPha)
%rtmz=zscore(rtm);
%rtmz2=baselineZscore(rtm,1:20,1);
mu=mean(rtm(1:20,:,1));
sigma=std(rtm(1:20,:,1)); sigma(sigma==0)=1;
rtmz=zeros(size(rtm));
for i=1:nPha
  rtmz(:,:,i)=bsxfun (@rdivide, bsxfun (@minus, rtm(:,:,i), mu), sigma);
end

return

##############
# global display on event separated by rat
##############

##############
# who respond

pid=1;
rng=21:30;
blRng=1:20;
idx=sortNID(rtmz(rng,:,pid),@sum);
breakPoint=max(find(sum(rtmz(rng,idx,pid))<=0));
plot(zeros(nBin,1),'--',baselineZscore(sum(rtm(:,:,pid),2),blRng),';all;','linewidth',2,
  baselineZscore(sum(rtm(:,idx(breakPoint+1:end),pid),2),blRng),';+;',
  baselineZscore(sum(rtm(:,idx(1:breakPoint),pid),2),blRng),';-;');

%function showMeanDynamic(rtm,rtmz,pid,rng,blRng, nPoints,tickBeg,tickEnd)

%mean response of all neurons (+ neurons and - neurons)
subplot(2,2,1);
showMeanDynamic(rtm,rtmz,pid,rng,blRng, 7,-1,2);

%individual response to the same event are different across neurons
subplot(2,2,2);
showGDSortInRng(rtmz(:,:,pid),rng, 7,-1,2,[-5 10]);
title('sorted individual zscore');

##############
# global summary

%function showGDWithSepper(rtm,sepper,nPoints,tickBeg,tickEnd,crng='auto',withCountTick=false)

for pid=1:nPha
  subplot(2,2,pid);showGDWithSepper(rtmz2(:,:,pid),nNeuSum,7,-1,2,[-5 10],false)
end

function showGlobalAnalysisOfEvent(rtm,rtmz,pid,nNeuSum,rng,blRng, nPoints,tickBeg,tickEnd,crng='auto')
  subplot(2,2,1);idx=sortNIDByRat(rtmz(rng,:,pid),nNeuSum,@sum);
  showGDWithSepper(rtmz(:,idx,pid),nNeuSum,nPoints,tickBeg,tickEnd,crng,false);%no individual count
  title('sorted zscore (by rat)');
  subplot(4,2,2);[y,x]=hist(rtmz(:,:,pid)(:),50);bar(x,y/sum(y));grid;
  title('distr. of zscore');xlabel('zscore');ylabel('frequency')
  subplot(4,2,4);plot(zeros(1,size(rtmz,1)),'--',baselineZscore(sum(rtm(:,:,pid),2),blRng));grid;
  title('global zscore');setTimeX(nPoints,tickBeg,tickEnd);xlabel('time');ylabel('zscore')
  subplot(2,2,3);idx=showGDSortInRng(rtmz(:,:,pid),rng,nPoints,tickBeg,tickEnd,crng);
  title('sorted zscore (global)')
  subplot(2,2,4);imagesc(rtm(:,idx,pid)');colorbar;
  title('count (sort by zscore)');setTimeX(nPoints,tickBeg,tickEnd);xlabel('time');ylabel('neuron')
end

pid=1;
rng=21:30;
blRng=1:20;
showGlobalAnalysisOfEvent(rtm,rtmz,pid,nNeuSum,rng,blRng, 7,-1,2,[-5 10])

for i=1:4;rng=20+[10*(i-1)+1:10*i]; %each half second
  subplot(2,2,i);showGDSortInRng(rtmz(:,:,pid),rng,7,-1,2,[-5 10]);
  title(sprintf('zscore (scorted by [%.1f,%.1f]s)',0.5*(i-1),0.5*i));
end

for i=1:3;rng=20+[10*(i-1)+1:10*(i+1)]; %each whole second
  subplot(2,2,i);showGDSortInRng(rtmz(:,:,pid),rng,7,-1,2,[-5 10]);
  title(sprintf('zscore (scorted by [%.1f,%.1f]s)',0.5*(i-1),0.5*(i+1)));
end

##############
# resposne group

%global response significance of all event on all period
for i=1:3;rng=20+[10*(i-1)+1:10*i];
  for j=1:3;
    subplot(3,3,3*(i-1)+j);showGDSortInRng(rtmz(:,:,j),rng,7,-1,2,[-5 10]);
    xlabel('time');ylabel('neuron');title(sprintf('zs of E%d by %.1f~%.1f s',j,0.5*(i-1),0.5*i));
  end
end

%response groups of differnt event:

% row: use the same neuron order for all 3 events
% column: align with different period
pid=1;  %the order is sorted for this event
for i=1:3;rng=20+[10*(i-1)+1:10*i]; %each half second
idx=sortNID(rtmz(rng,:,pid),@sum);
for j=1:3; %each event with the same neuron order
  subplot(3,3,3*(i-1)+j);imagesc(rtmz(:,idx,j)');colorbar;caxis([-5 10]);
  setTimeX(7,-1,2);xlabel('time');ylabel('neuron');
  title(sprintf('zs of E%d by %.1f~%.1f s',j,0.5*(i-1),0.5*i));
end
end


##############
# event
##############

function entTime=getEventTime(fnl_b,fnl_e,cid,nTri,entPhase,offMismatch)
  nRat=length(fnl_b);
  nPha=length(entPhase);
  entTime=zeros(nTri,nPha,nRat);
  for i=1:nRat;
    times=findEventTimeInTrialByFile(fnl_b(i),fnl_e(i),cid,entPhase,offMismatch,true);
    idx=find(all(isnan(times)==0,2));
    entTime(:,:,i)=times(idx(1:nTri),:);
  end
end
entTime=getEventTime(fnl_b,fnl_e(fnm_be),cid,nTri,entPhase,-100*timeUnit2ms);

##############
# time delay between actions (events)
entDiff=diff(entTime,1,2);
%function showEventInterval(entDiff,names,timeUnit2ms)
showEventInterval(entDiff,{'tone-lever';'lever-well'},timeUnit2ms)


##############
# dynamic
##############

%show all neurons' response to one certain event.
function showDynamicAll(rtm,cid,nRow,nCol,idx,nNeuList, nTick,tckBeg,tckEnd,dashThre=0,sepper,prefix='')
  nNeu=length(idx);
  if(nNeu!=sum(nNeuList))
    error('neuron number doesnot match in idx(%d) and nNeuList(%d)',nNeu,sum(nNeuList));
  end
  for fid=1:ceil(nNeu/nRow/nCol);
    inner_idx=idx((fid-1)*nRow*nCol+1:min(end,fid*nRow*nCol));
    close;
    showDynamicMat(rtm,cid,nRow,nCol,inner_idx,nNeuList, nTick,tckBeg,tckEnd,dashThre,sepper)
    saveas(gcf,[prefix,num2str(fid),'.png']);
  end
end

nRow=4;nCol=4;
sepper=[20,30,40,50];
showDynamicAll(rtm,1,nRow,nCol,1:nNeu,nNeuList,4,-1,2,0.03,sepper,'tone-')
showDynamicAll(rtm,2,nRow,nCol,1:nNeu,nNeuList,4,-1,2,0.03,sepper,'lever-')
showDynamicAll(rtm,3,nRow,nCol,1:nNeu,nNeuList,4,-1,2,0.03,sepper,'well-')

%show SOME (specified with IDX) neurons' response to all 3 events.
function showDynamicPhase(rtm,nRow,idx,nNeuList,nTick,tckBeg,tckEnd,dashThre,sepper)
  nPha=size(rtm,3);
  for row=1:min(nRow,length(idx));
    gnid=idx(row);
    rlnID=mapGNId2Local(gnid,nNeuList);
    yRng=[NaN NaN];
    for pid=1:nPha; i=(row-1)*3+pid;
      subplot(nRow,nPha,i);
      showDynamic(rtm(:,:,pid),gnid,rlnID,nTick,tckBeg,tckEnd,dashThre,sepper);
      title([get(get(gca,'title'),'string'),'-',num2str(pid)]);
      t=ylim(); yRng(1)=min(yRng(1),t(1)); yRng(2)=max(yRng(2),t(2));
      %dif=mean(entTime(:,pid,rlnID(1))-entTime(:,1,rlnID(1)))/1000/timeUnit2ms;
      %setTimeX(nTick,dif-1,dif+2);xlabel('mean time')
    end
    for pid=1:nPha; i=(row-1)*3+pid;
      subplot(nRow,nPha,i);ylim(yRng);
    end
  end
end

nRow=4;
sepper=[20 30 40];
idx=33:37;
showDynamicPhase(rtm,nRow,idx,nNeuList,4,-1,2,0.03,sepper)

##############
# delay of response
##############

%function chp=findChangePoint(vec,startIdx,thres,granu=1)
%findChangePoint(rtm(:,1,1),21,0.2)

%function cp=calResponseDelay(rtm,threshold,startIdx)

threshold=0.3; %threshold=0.5
cp=calResponseDelay(rtm,threshold,21);
cpz=calResponseDelay(rtmz,threshold,21);

%function showResponseDelay(cp,threshold,nPoints,nTick,tickBeg,tickEnd)

showResponseDelay(cp,threshold,40,5,0,2)

[~,idx]=sort(cp);

pid=1;
showGD_core(rtmz(:,idx(:,pid),pid),7,-1,2,[-5 10]);title(['zscore of E',num2str(pid),' by delay'])

function showDelaySummary(rtm,rtmz,startIdx,threshold, nTick_d, nTick,tickBeg,tickEnd,crng)
  [nBin,~,nPha]=size(rtm);
  cp=calResponseDelay(rtm,threshold,startIdx);
  nPoints_d=nBin-startIdx+1;
  subplot(2,2,1);showResponseDelay(cp,threshold,nPoints_d,nTick_d,0,tickEnd)
  [~,idx]=sort(cp);
  for pid=1:nPha;
    subplot(2,2,1+pid);
    showGD_core(rtmz(:,idx(:,pid),pid),nTick,tickBeg,tickEnd,crng);
    title(['zscore of E',num2str(pid),' by delay'])
  end
end

threshold=0.3;
showDelaySummary(rtm,rtmz,21,threshold, 5,7,-1,2,[-5 10]);

##############
# pattern (old)
##############

%function ft=genDynamicFeature(rtm,sepper,method=@mean)

sepper=[20 30 40];
ft=genDynamicFeature(rtm,sepper);
ftz=genDynamicFeature(rtmz,sepper);
ftz2=genDynamicFeature(rtmz2,sepper);


pid=1;

stage1=2;%0~0.5s
stage2=4;%1~2s

# metric: zscore
th=[-1 1]*0.75;
[~,idx1]=sort(ftz2(stage1,:,pid));
[~,idx2]=sort(ftz2(stage2,:,pid));
gp1=calNeuGroupTbl(nNeuList,idx1,sepByThrsld(ftz2(stage1,:,pid),th));
gp2=calNeuGroupTbl(nNeuList,idx2,sepByThrsld(ftz2(stage2,:,pid),th));

# metric: spike rate ratio
th=[2/3 3/2];
[~,idx1]=sort(ft(stage1,:,pid)./ft(1,:,pid));
[~,idx2]=sort(ft(stage2,:,pid)./ft(1,:,pid));
gp1=calNeuGroupTbl(nNeuList,idx1,sepByThrsld(ftz2(stage1,:,pid)./ft(1,:,pid),th));
gp2=calNeuGroupTbl(nNeuList,idx2,sepByThrsld(ftz2(stage2,:,pid)./ft(1,:,pid),th));

%getGpCount(gp1)

function ptn=getPtnNeurons(gp1,gp2,idx1,idx2)
  nRat=size(gp1,1);
  ptn=cell(nRat,1);
  for i=1:nRat
    ptn(i)=intersect(cell2mat(gp1(i,idx1)),cell2mat(gp2(i,idx2)));
  end
end
function ptn=getAllPtnNeurons(gp1,gp2)
  nRat=size(gp1,1);
  ptn=cell(size(gp1,2),size(gp2,2),nRat);
  for j1=1:size(gp1,2); for j2=1:size(gp2,2);
    ptn(j1,j2,:)=getPtnNeurons(gp1,gp2,j1,j2);
  end; end
end

%ptn_all=cell(size(gp1,2),size(gp2,2),nRat);
ptn_all=getAllPtnNeurons(gp1,gp2);
ptn_all_cnt=getGpCount(ptn_all)


ptn_all=cell(size(gp1,2),size(gp2,2),nRat,nPha);
for pid=1:nPha;
  [~,idx1]=sort(ftz2(stage1,:,pid));
  [~,idx2]=sort(ftz2(stage2,:,pid));
  gp1=calNeuGroupTbl(nNeuList,idx1,sepByThrsld(ftz2(stage1,:,pid),th));
  gp2=calNeuGroupTbl(nNeuList,idx2,sepByThrsld(ftz2(stage2,:,pid),th));
  ptn_all(:,:,:,pid)=getAllPtnNeurons(gp1,gp2);
end

function ptns=findNeuPtnOverPhase(ptn_all,gnid,nNeuList)
  [np1,np2,~,nPha]=size(ptn_all);
  ptns=zeros(2,nPha);
  rlnID=mapGNId2Local(gnid,nNeuList);
  for pid=1:nPha;
    for i=1:np1; for j=1:np2;
      if(ismember(gnid,cell2mat(ptn_all(i,j,rlnID(1),pid))))
        ptns(:,pid)=[i;j];
        break;
      end
    end;end
  end
end

findNeuPtnOverPhase(ptn_all,5,nNeuList)

%number of neurons hold same pattern all the time
neuHold=cell(size(gp1,2),size(gp2,2),nRat);
for gnid=1:nNeu
  ptns=findNeuPtnOverPhase(ptn_all,gnid,nNeuList);
  rlnID=mapGNId2Local(gnid,nNeuList);
  if(all(ptns(1,:)==ptns(2,:)))
    neuHold(ptns(1),ptns(2),rlnID(1))=[cell2mat(neuHold(ptns(1),ptns(2),rlnID(1))),gnid];
  end
end

getGpCount(neuHold)

##############
# pattern (fine classified)
##############

sepper=[20 30 40 50];
ft=genDynamicFeature(rtm,sepper);
ftz=genDynamicFeature(rtmz,sepper);






