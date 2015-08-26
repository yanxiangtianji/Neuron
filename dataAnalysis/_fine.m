#prepare 
addpath([pwd,'/../mBasic/'])
addpath([pwd,'/fine/'])
nTri=50;
%nCue=2;
basicDataParameters
clear fn_c1 fn_c2 fn_r1 fn_r2

data=readRaw([fn_prefix,'all.txt']);
beh=readCue([fn_prefix,'beh.txt']);
cue1=beh(find(beh(:,1)==1),:);
cue2=beh(find(beh(:,1)==2),:);
cue3=cue1; cue3(:,[2,3])=bsxfun(@plus,cue3(:,[2,3]),cue3(:,4)/2-triLength/2); cue3=cue3(find(cue3(:,4)>=triLength),:);
cue4=cue2; cue4(:,[2,3])=bsxfun(@plus,cue4(:,[2,3]),cue4(:,4)/2-triLength/2); cue4=cue4(find(cue4(:,4)>=triLength),:);
cue=[cue1(1:nTri,2),cue2(1:nTri,2),cue3(1:nTri,2),cue4(1:nTri,2)];
%clear cue1 cue2 cue3 cue4

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
cueBinEnd=ceil((cue+offsetEnd)/binSize)-1;
xAxisTicks=(offsetBeg:binSize:offsetEnd)/timeUnit2ms/1000;
if(length(xAxisTicks)>ceil(maxTime/binSize))xAxisTicks=xAxisTicks(1:ceil(maxTime/binSize));end

dt=cell(nTri,nNeu,nCue);
for cid=1:nCue;for tid=1:nTri;
  dt(tid,:,cid)=pickRawFromRng(data,cue(tid,cid)+offsetBeg,cue(tid,cid)+offsetEnd);
end;end;

rt=zeros(ceil(maxTime/binSize),nTri,nNeu,nCue);
for cid=1:nCue; for nid=1:nNeu; for tid=1:nTri;
  rt(:,tid,nid,cid)=discretize(dt(tid,nid,cid),binSize,cue(tid,cid)+offsetBeg,ceil(maxTime/binSize),'count');
end;end;end;
rtz=zscore(rt);

%function rt=cutRateDate2Trial(rate,cueBinBeg,cueBinEnd,tids,nids,cids)

return;
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

####
#data is cue-trial cut period:
maxTime=offsetEnd-offsetBeg;
vecLength=ceil(maxTime/binSize);
rts=zeros(vecLength,nTri,nNeu,nCue);
for cid=1:nCue;
  tic;for nid=1:nNeu;for tid=1:nTri;
    #rts(:,tid,nid,cid)=regdatasmooth(1:vecLength,rt(:,tid,nid,cid));
    #rts(:,tid,nid,cid)=rgdtsmcore((1:vecLength)',rt(:,tid,nid,cid),2,2);
    rts(:,tid,nid,cid)=max(0,smooth(rt(:,tid,nid,cid)',9,'sgolay')');
  end;end;toc;
end;
save('rt_s.mat','rts');
rtsz=zscore(rts);

####
#Figures:
vecLength=ceil((offsetEnd-offsetBeg)/binSize);

%figure: rate of ONE trial of ONE neuron ONE cue
tid=1;nid=10;cid=1;
plot(xAxisTicks,cutRateDate2Trial(rate,cueBinBeg,cueBinEnd,tid,nid,cid));
plot(xAxisTicks,rtsz(:,tid,nid,cid));
title([cue_name(cid),',neuron-',num2str(nid),',trial-',num2str(tid)])

%figure: rate of ONE trial of ONE neuron ALL cue
function show_rt_one_m(data,tid,nid,xAxisTicks,cue_name,titlePrefix='')
  %data is a 2D matrix
  clf;hold all; nCue=size(data,2);
  for cid=1:nCue;
    plot(xAxisTicks,data(:,cid));
  end;
  title([titlePrefix,',neuron-',num2str(nid),',trial-',num2str(tid)])
  hold off;legend(cue_name);legend('boxoff')
end
show_rt_one_m(reshape(rtsz(:,tid,nid,1:nCue),vecLength,nCue),tid,nid,xAxisTicks,cue_name,'rtsz: ');
show_rt_one_m(reshape(cutRateDate2Trial(rates,cueBinBeg,cueBinEnd,tid,nid,1:nCue),vecLength,nCue),
  tid,nid,xAxisTicks,cue_name,'rts: ');

function show_rt_eb(rt,nid,cid,xAxisTicks)
  t=rt(:,:,nid,cid)';
  errorbar(xAxisTicks,mean(t),std(t));xlim([xAxisTicks(1),xAxisTicks(end)])
end;
show_rt_eb(rt,nid,cid,xAxisTicks)

%figure: rate of ONE trial of ALL neurons
imagesc(ratesz(cueBinBeg(tid,cid):cueBinEnd(tid,cid),:)');colorbar;ylabel('neuron id');


%figure: rate of ALL trials on ONE neuron

%function _show_rt_xt_kernel(rt,xPoints)
%function show_rt_xt_w(rate,nid,cid,xPoints,cueBinBeg,cueBinEnd,titlePrefix='')
%function show_rt_w_m(nid,cid,rate,ratez,rates,ratesz,xPoints,cueBinBeg,cueBinEnd)
%function show_rt_xt_c(rt,nid,cid,xPoints,titlePrefix='')
%function show_rt_c_m(nid,cid,rt,rtz,rts,rtsz,xPoints)

xPoints=(offsetBeg:maxTime/6:offsetEnd)/timeUnit2ms/1000;
nid=10;cid=1;
show_rt_m_c(nid,cid,rt,rtz,rts,rtsz,xPoints)

%show_rt_xt(rt(:,:,nid,cid)',xPoints);title(['cue: ',num2str(cid),',neuron: ',num2str(nid)])

####################
# dot-product
####################

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
infoFun=@(data1,data2)pearson_corr(data1(:),data2(:));
type='PC';

#cross TRIAL:

%whole
function info=cal_xt_w(rate,trialBinBeg,trialBinEnd)
  [vecLength,nNeu]=size(rate);
  nTri=length(trialBinBeg);
  info=zeros(nTri,nTri,nNeu);
  global infoFun
  for nid=1:nNeu; for tid1=1:nTri;
    d1=rate(trialBinBeg(tid1):trialBinEnd(tid1),nid);
    for tid2=tid1+1:nTri;
      d2=rate(trialBinBeg(tid2):trialBinEnd(tid2),nid);
      info(tid1,tid2,nid)=infoFun(d1,d2);
    end;
  end;end;
end
info_xt=zeros(nTri,nTri,nNeu,nCue);
for cid=1:nCue;
  tic;info_xt(:,:,:,cid)=cal_xt_w(ratesz,cueBinBeg(:,cid),cueBinEnd(:,cid));toc;
end

%cue-trial cut
function info=cal_xt_c(rt)
  %calculation goes on only one cue
  [vecLength,nTri,nNeu]=size(rt);
  info=zeros(nTri,nTri,nNeu);
  global infoFun
  for nid=1:nNeu;
    for tid1=1:nTri; for tid2=tid1+1:nTri;
      info(tid1,tid2,nid)=infoFun(rt(:,tid1,nid),rt(:,tid2,nid));
    end;end;
  end;
end
info_xt=zeros(nTri,nTri,nNeu,nCue);
for cid=1:nCue;
  tic;info_xt(:,:,:,cid)=cal_xt_c(rtsz(:,:,:,cid));toc;
end
save('info_xt.mat','info_xt');

%show
%function [mr,mc]=show_xt(info,more=0)

cid=1
show_xt(info_xt(:,:,:,cid));title([cue_name(cid),': x-trial corr.'])
show_xt(info_xt(:,:,:,cid),1);title([cue_name(cid),': x-trial corr.'])
nid=10;
imagesc(info_xt(:,:,nid,cid));colorbar;

mr=zeros(nNeu,nCue); mc=zeros(nTri*(nTri-1)/2,nCue);
rtc=zeros(nNeu,nCue);
for cid=1:nCue;
  [mr(:,cid),mc(:,cid)]=show_xt(info_xt(:,:,:,cid));
  rtc(:,cid)=mean(sum(rt(:,:,:,cid)))(:);
end;
function show_xt_cor_rate(mr,rtc,cid,yl1='',yl2='')
  bar(mr(:,cid));hold on;hAx=plotyy(1,0,1:size(rtc,1),rtc(:,cid));hold off;
  p1=get(hAx(1),'ylim');p2=get(hAx(2),'ylim');
  set(hAx(2),'ylim',p2(2)*[p1(1)/p1(2),1])
  #ylabel(hAx(1),'pcorr');ylabel(hAx(2),'spike #');
  ylabel(hAx(1),yl1);ylabel(hAx(2),yl2);
end;
for cid=1:nCue;
  subplot(2,2,cid);if(mod(cid,2)==1)yl1='pcorr';yl2='';else;yl1='';yl2='spike #';end;
  show_xt_cor_rate(mr,rtc,cid,yl1,yl2);title(cue_name(cid));set(gca,'xtick',1:2:nNeu)
end

#cross NEURON:
%whole
function info=cal_xn_w(rate,trialBinBeg,trialBinEnd)
  [vecLength,nNeu]=size(rate);
  nTri=length(trialBinBeg);
  info=zeros(nNeu,nNeu,nTri);
  global infoFun
  for tid=1:nTri; for nid1=1:nNeu;
    d1=rate(trialBinBeg(tid):trialBinEnd(tid),nid1);
    for nid2=1:nNeu;
      d2=rate(trialBinBeg(tid):trialBinEnd(tid),nid2);
      info(nid1,nid2,tid)=infoFun(d1,d2);
    end;
  end; end
end
info_xn=zeros(nNeu,nNeu,nTri,nCue);
for cid=1:nCue;
  tic;info_xn(:,:,:,cid)=cal_xn_w(ratesz,cueBinBeg(:,cid),cueBinEnd(:,cid));toc;
end

%cue-trial cut
function info=cal_xn_c(rt)
  [vecLength,nTri,nNeu]=size(rt);
  info=zeros(nNeu,nNeu,nTri);
  global infoFun
  for tid=1:nTri;
    for nid1=1:nNeu; for nid2=nid1+1:nNeu;
      info(nid1,nid2,tid)=infoFun(rt(:,tid,nid1),rt(:,tid,nid2));
    end;end;
  end
end
info_xn=zeros(nNeu,nNeu,nTri,nCue);
for cid=1:nCue;
  tic;info_xn(:,:,:,cid)=cal_xn_c(rtsz(:,:,:,cid));toc;
end
save('info_xn.mat','info_xn')

%show
%function [mr,mc]=show_xn(info,more=0)

cid=1
show_xn(info_xn(:,:,:,cid));title([cell2mat(cue_name(cid)),': x-neuron corr.'])
show_xn(info_xn(:,:,:,cid),1);title([cell2mat(cue_name(cid)),': x-neuron corr.'])
tid=1;
imagesc(info_xn(:,:,tid,cid));colorbar;





