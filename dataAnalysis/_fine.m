#prepare 
addpath([pwd,'/../mBasic/'])
nTri=50;nCue=2;
basicDataParameters
clear fn_c1 fn_c2 fn_r1 fn_r2

data=readRaw([fn_prefix,'all.txt']);
beh=readCue([fn_prefix,'beh.txt']);
cue1=beh(find(beh(:,1)==1),:);
cue2=beh(find(beh(:,1)==2),:);
cue3=cue1; cue3(:,[2,3])=bsxfun(@plus,cue3(:,[2,3]),cue3(:,4)/2-triLength/2); cue3=cue3(find(cue3(:,4)<=triLength),:);
cue4=cue2; cue4(:,[2,3])=bsxfun(@plus,cue4(:,[2,3]),cue4(:,4)/2-triLength/2); cue4=cue4(find(cue4(:,4)<=triLength),:);
cue=[cue1(1:nTri,2),cue2(1:nTri,2),cue3(1:nTri,2),cue4(1:nTri,2)];

binSize=50*timeUnit2ms;

#whole period:
maxTime=findMaxTime(data);
rate=zeros(ceil(maxTime/binSize),nNeu);
for nid=1:nNeu;
  rate(:,nid)=discretize(data(nid),binSize,0,ceil(maxTime/binSize),'count');
end;
ratez=zscore(rate);

#cue-trial period:
offsetBeg=-1000*timeUnit2ms;
offsetEnd=2000*timeUnit2ms;
maxTime=offsetEnd-offsetBeg;
cueBinBeg=ceil((cue+offsetBeg)/binSize);
cueBinEnd=ceil((cue+offsetEnd)/binSize);
xAxisTicks=(offsetBeg:binSize:offsetEnd)/timeUnit2ms/1000;
if(length(xAxisTicks)>ceil(maxTime/binSize))xAxisTicks=xAxisTicks(1:ceil(maxTime/binSize));end

dt=cell(nTri,nNeu,2);
for cid=1:2;for tid=1:nTri;
  dt(tid,:,cid)=pickRawFromRng(data,cue(tid,cid)+offsetBeg,cue(tid,cid)+offsetEnd);
end;end;

rt=zeros(ceil(maxTime/binSize),nTri,nNeu,2);
for cid=1:2; for nid=1:nNeu; for tid=1:nTri;
  rt(:,tid,nid,cid)=discretize(dt(tid,nid,cid),binSize,cue(tid,cid)+offsetBeg,ceil(maxTime/binSize),'count');
end;end;end;
rtz=zscore(rt);

####################
# z-score (follow David's work)
####################
pkg load 'data-smoothing';

####
#data is whole period:
maxTime=findMaxTime(data);
vecLength=ceil(maxTime/binSize);
rates=zeros(vecLength,nNeu);
warning off;
for nid=1:nNeu;
  #tic;rates(:,nid)=regdatasmooth(1:vecLength,rate(:,nid));toc;
  #tic;rates(:,nid)=rgdtsmcore((1:vecLength)',rate(:,nid),2,2);toc;
  tic;rates(:,nid)=max(0,smooth(rate(:,nid)',9,'sgolay')');toc;
end;
warning on;
save('rate_s.mat','rates');
ratesz=zscore(rates);
%figure: rate of one trial of one neuron
tid=1;nid=9;cid=1;
plot(ratesz(cueBinBeg(tid,cid):cueBinEnd(tid,cid),nid));
%figure: rate of all neurons on one trial
imagesc(ratesz(cueBinBeg(tid,cid):cueBinEnd(tid,cid),:)');colorbar;ylabel('neuron id');

####
#data is cue-trial period:
maxTime=offsetEnd-offsetBeg;
vecLength=ceil(maxTime/binSize);
rts=zeros(vecLength,nTri,nNeu,2);
for cid=1:2;
  tic;for i=1:nid;for tid=1:nTri;
    #rts(:,tid,nid,cid)=regdatasmooth(1:vecLength,rt(:,tid,nid,cid));
    rts(:,tid,nid,cid)=rgdtsmcore((1:vecLength)',rt(:,tid,nid,cid),2,2);
  end;end;toc;
end;
save('rt_s.mat','rts');
rtsz=zscore(rts);
%figure: rate of one trial of one neuron
tid=1;nid=10;cid=1;
plot(xAxisTicks,rtsz(:,tid,nid,1),xAxisTicks,rtsz(:,tid,nid,2));
errorbar(xAxisTicks,mean(rt(:,:,nid,1),2),std(rt(:,:,nid,1),0,2));
%figure: rate of all neurons on one trial
function show_rt_xt(rt,xPoints)
  [nTri,vecLength]=size(rt);
  imagesc(rt);colorbar;ylabel('trial');xlabel('time');
  %title(['cue: ',num2str(cid),',neuron: ',num2str(nid)])
  l=length(xPoints);
  set(gca,'xtick',(0:l-1)*vecLength/max(1,l-1));set(gca,'xticklabel',xPoints);
end
function show_rt4(nid,cid,rt,rtz,rts,rtsz,xPoints)
  subplot(2,2,1);show_rt_xt(rt(:,:,nid,cid)',  xPoints);title('rt')
  subplot(2,2,2);show_rt_xt(rtz(:,:,nid,cid)', xPoints);title('rtz')
  subplot(2,2,3);show_rt_xt(rts(:,:,nid,cid)', xPoints);title('rts')
  subplot(2,2,4);show_rt_xt(rtsz(:,:,nid,cid)',xPoints);title('rtsz')
end

xPoints=(offsetBeg:maxTime/6:offsetEnd)/timeUnit2ms/1000;
nid=10;cid=1;
show_rt_xt(rt(:,:,nid,cid)',xPoints);title(['cue: ',num2str(cid),',neuron: ',num2str(nid)])
show_rt4(nid,cid,rt,rtz,rts,rtsz,xPoints)

####################
# dot-product
####################

#cross TRIAL:

%whole
function dp=cal_xt_whole(rate,trialBinBeg,trialBinEnd)
  [vecLength,nNeu]=size(rate);
  nTri=length(trialBinBeg);
  dp=zeros(nTri,nTri,nNeu);
  for nid=1:nNeu; for tid1=1:nTri;
    d1=rate(trialBinBeg(tid1):trialBinEnd(tid1),nid);
    for tid2=tid1+1:nTri;
      d2=rate(trialBinBeg(tid2):trialBinEnd(tid2),nid);
      dp(tid1,tid2,nid)=dot_product(d1,d2);
    end;
  end;end;
end
dp=zeros(nTri,nTri,nNeu,nCue);
for cid=1:nCue;
  dp(:,:,:,cid)=cal_xt(ratesz,cueBinBeg(:,cid),cueBinEnd(:,cid));
end

%cue-trial cut
function dp=cal_xt_cut(rt)
  %calculate do for only one cue
  [vecLength,nTri,nNeu]=size(rt);
  dp=zeros(nTri,nTri,nNeu);
  for nid=1:nNeu;
    for tid1=1:nTri; for tid2=tid1+1:nTri;
      dp(tid1,tid2,nid)=dot_product(rt(:,tid1,nid),rt(:,tid2,nid));
    end;end;
  end;
end
dp=zeros(nTri,nTri,nNeu,nCue);
for cid=1:nCue;
  dp(:,:,:,cid)=cal_xt_cut(rtsz(:,:,:,cid));
end

%show
function show_xt_each(dp)
  [nTri,~,nNeu]=size(dp);
  vld_idx=find(triu(ones(nTri),1));
  temp=zeros(nTri*(nTri-1)/2,nNeu);
  for nid=1:nNeu;  temp(:,nid)=dp(:,:,nid)(vld_idx);  end;
  imagesc(temp');colorbar;
end

show_xt_each(dp1);xlabel('trial-pair');ylabel('neuron');

nid=10;
imagesc(dp1(:,:,nid));colorbar;

#cross NEURON:
%whole
function dp=cal_xn(rate,trialBinBeg,trialBinEnd)
  [vecLength,nNeu]=size(rate);
  nTri=length(trialBinBeg);
  dp=zeros(nNeu,nNeu,nTri);
  for tid=1:nTri; for nid1=1:nNeu;
    d1=rate(trialBinBeg(tid):trialBinEnd(tid),nid1);
    for nid2=1:nNeu;
      d2=rate(trialBinBeg(tid):trialBinEnd(tid),nid2);
      dp(nid1,nid2,tid)=dot_product(d1,d2);
    end;
  end; end
end
dp=zeros(nTri,nTri,nNeu,nCue);
for cid=1:nCue;
  dp(:,:,:,cid)=cal_xn(rtsz(:,:,:,cid));
end

%cue-trial cut
function dp=cal_xn_cut(rt)
  [vecLength,nTri,nNeu]=size(rt);
  dp=zeros(nNeu,nNeu,nTri);
  for tid=1:nTri;
    for nid1=1:nNeu; for nid2=nid1+1:nNeu;
      dp(nid1,nid2,tid)=dot_product(rt(:,tid,nid1),rt(:,tid,nid2));
    end;end;
  end
end
dp=zeros(nTri,nTri,nNeu,nCue);
for cid=1:nCue;
  dp(:,:,:,cid)=cal_xn(rtsz(:,:,:,cid));
end

%show
function show_xn(dp)
  [nNeu,~,nTri]=size(dp);
  vld_idx=find(triu(ones(nNeu),1));
  temp=zeros(nTri*(nTri-1)/2,nNeu);
  for tid=1:nTri;  temp(:,tid)=dp(:,:,tid)(vld_idx);  end;
  imagesc(temp');colorbar;
end

show_xn(dp1);xlabel('neuron-pair');ylabel('trial');

tid=1;
imagesc(dp1(:,:,tid));colorbar;


