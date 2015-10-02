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
    showDynamicMat(rtm,cid,nRow,nCol,inner_idx,nNeuList, nTick,tckBeg,tckEnd,dashThre=0,sepper)
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
showDynamicPhase(rtm,nRow,1:nRow,nNeuList,4,-1,2,0.03,sepper)


##############
# pattern
##############






