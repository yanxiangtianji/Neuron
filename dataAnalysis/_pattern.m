addpath([pwd,'/../mBasic/'])
addpath([pwd,'/fine2/'])
addpath([pwd,'/pattern/'])

pre_fn='E:\Data\Data for MUA\';
pre_fn_sub={'PL','IL','OFC'};

[fnl_ps,fnl_pb]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(1))]);
%[fnl_is,fnl_ib]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(2))]);
%[fnl_os,fnl_ob]=makeFileListOfFolder([pre_fn,cell2mat(pre_fn_sub(3))]);
[~,~,fnl_e]=makeFileListOfFolder([pre_fn,'PFC_events']);
map_p=mapBehFile2EvnFile(fnl_pb,fnl_e);
%map_i=mapBehFile2EvnFile(fnl_ib,fnl_e);
%map_o=mapBehFile2EvnFile(fnl_ob,fnl_e);

rat_name={'R001','R002','R003','R004','R005','R006','R009','R016','R017','R018','R096','R108'};
%countTrials(fnl_pb)
nCue=1;
cid=1;
nRat=length(fnl_pb);

timeUnit2ms=10;
trialLength=10*1000*timeUnit2ms;

##############
# event related data
##############

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
%nVld=checkNTri(fnl_pb,fnl_e(map_p),1,entPhase,-1000*timeUnit2ms);
%nTri=min(nVld)

nTri=41;

%data=cell(nTri,nNeu,nPha);
[data,nNeuList]=pickTrialByEventFromFiles(fnl_ps,fnl_pb,fnl_e(map_p),1,nTri,entPhase,-1000*timeUnit2ms,2000*timeUnit2ms,-500*timeUnit2ms,true);
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
rtmz=zscore(rtm);
rtmz2=baselineZscore(rtm,1:20,1);

return

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
entTime=getEventTime(fnl_pb,fnl_e(map_p),cid,nTri,entPhase,-100*timeUnit2ms);

# time delay between actions
entDiff=diff(entTime,1,2);
colormap(summer);
for i=1:nRat
  subplot(3,2,i);[y,x]=hist(entDiff(:,:,i)/1000/timeUnit2ms,40);bar(x,y/nTri);
  set(gca,'xtick',linspace(0,xlim()(2),11));legend({'tone-lever';'lever-well'})
  title(['Rat: ',num2str(i)]);xlabel('delay (s)');ylabel('frequency');
end



##############
# dynamic
##############

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
sepper=[20,30,40];
showDynamicAll(rtm,1,nRow,nCol,1:nNeu,nNeuList,4,-1,2,0.03,sepper,'tone-')
showDynamicAll(rtm,2,nRow,nCol,1:nNeu,nNeuList,4,-1,2,0.03,sepper,'lever-')
showDynamicAll(rtm,3,nRow,nCol,1:nNeu,nNeuList,4,-1,2,0.03,sepper,'well-')


function showDynamicPhase(rtm,nRow,idx,nNeuList,nTick,tckBeg,tckEnd,dashThre,sepper)
  nPha=size(rtm,3);
  for row=1:min(nRow,length(idx));
    gnid=idx(row);
    rlnID=mapGNId2Local(gnid,nNeuList);
    for pid=1:nPha;
      i=(row-1)*3+pid; subplot(nRow,nPha,i);
      showDynamic(rtm(:,:,pid),gnid,rlnID,nTick,tckBeg,tckEnd,dashThre,sepper);
      title([get(get(gca,'title'),'string'),'-',num2str(pid)]);
      %dif=mean(entTime(:,pid,rlnID(1))-entTime(:,1,rlnID(1)))/1000/timeUnit2ms;
      %setTimeX(nBin,nTick,dif-1,dif+2);xlabel('mean time')
    end
  end
end

nRow=4;
sepper=[20 30 40];
idx=33:37;
showDynamicPhase(rtm,nRow,idx,nNeuList,4,-1,2,0.03,sepper)


##############
# pattern
##############

function ft=genDynamicFeature(rtm,sepper)
  [nBin,nNeu,nPha]=size(rtm);
  sepper=[0;sepper(sepper>0 & sepper<nBin)(:);nBin];
  nFea=length(sepper)-1;
  ft=zeros(nFea,nNeu,nPha);
  for pid=1:nPha;for nid=1:nNeu;for fid=1:nFea
    ft(fid,nid,pid)=mean(rtm(sepper(fid)+1:sepper(fid+1),nid,pid));
  end;end;end
end

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