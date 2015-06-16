#################
#basic:

basicParameters()
basicStatFuns()

#################
#get data

function [Aarr,Warr,CMarr]=whole_list_AW(fn_list,n_trial,n,D,lambdaA,lambdaW,fRep,Ainit,Winit)
  Aarr=cell(n_trial,1);   #Adjacent (n*n)
  Warr=cell(n_trial,1);   #Weight (n*n)
  CMarr=cell(n_trial,1);  #Confusion Matrix (n*4)
  for i=1:n_trial
    %disp(fn_list(i))
    %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
    rData=readRaw(cell2mat(fn_list(i)));   %dMin=1; dUnit=1;
    %rData=pickDataByTime(rData,30000,60000);
    [A,W,CM]=trainAW(rData,D,lambdaA,lambdaW,fRep,Ainit,Winit);
    Aarr(i)=A;
    Warr(i)=W;
    CMarr(i)=CM;
  end
end

m=40;
%m=20; idx=randperm(40,m);

Aarr=cell(m,4);Warr=cell(m,4);CMarr=cell(m,4);
for i=1:4
  tic;[Aarr(:,i),Warr(:,i),CMarr(:,i)]=whole_list_AW(fnlist(:,i),m,n,D,lambdaA,lambdaW,fRep,Ainit,Winit);toc;
end
save('../data/data1.mat','D','Ainit','Winit','Aarr','Warr','CMarr')

#################
#num of spike:

function Carr=countSpikes(fn_list,n_trial,n)
  Carr=cell(n_trial,1); #Spike Count (n*1)
  for i=1:n_trial
    rData=readRaw(cell2mat(fn_list(i)));
    sc=zeros(n,1);
    for j=1:n;  sc(j)=length(cell2mat(rData(j)));  end
    Carr(i)=sc;
  end
end

Carr=cell(m,4);
for i=1:4
  Carr(:,i)=countSpikes(fnlist(:,i),m,n);
end

Cdis=distriVec(SCarr);

Ca=zeros(n,5);  Cs=zeros(n,5);
for i=1:4
  [Ca(:,i),Cs(:,i)]=statVec(Cdis(:,m*(i-1)+1:m*i));
end
[Ca(:,5),Cs(:,5)]=statVec(Cdis);

save('../data/count.mat','Carr','Cdis','Ca','Cs')

##################
#accurancy & valid:

#accurancy:
function disAcc=distriCMmat_acc(CMarr)
  l=length(CMarr(:));
  if(l!=0)
    n=size(cell2mat(CMarr(1)),1);
  else
    n=0;
  end
  disAcc=zeros(n,l);
  for i=1:l
    x=cell2mat(CMarr(i));
    disAcc(:,i)=(x(:,1)+x(:,4))./sum(x,2);
  end
end

AccD=distriCMmat_acc(CMarr(:));

AccAvg=zeros(n,5);  AccStd=zeros(n,5);
for cue_id=1:4;
  [AccAvg(:,cue_id),AccStd(:,cue_id)]=statVec(AccD(:,m*(cue_id-1)+1:m*cue_id));
end
[AccAvg(:,5),AccStd(:,5)]=statVec(AccD);

save('../data/acc.mat','AccD','AccAvg','AccStd');

%statistics of Accurancy
subplot(3,1,1);imagesc(AccAvg');title('AVG accurancy');caxis([0 1]);colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'],'xtick',[1:19])
subplot(3,1,2);imagesc(AccStd');title('STD accurancy');caxis([0 1]);colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'],'xtick',[1:19])
subplot(3,1,3);hist(AccD(:),50);title('Distribution of accurancy');
set(gca,'xtick',[0:0.1:1]);

%distribution of accurancy
for i=1:19;
  subplot(5,4,i);hist(AccD(i,:),20);title(['Acc. distr. on N',num2str(i)]);xlim([0,1]);set(gca,'xtick',[0 0.5 1]);
end

function plotAccDis(AccD)
  subplot(2,1,1);hist(AccD(:),50);title('Overall accurancy distribution');
  xlabel('accurancy');ylabel('frequency');
  subplot(2,1,2);plotcdf(AccD(:),50,'Overall accurancy CDF','accurancy','CDF (fraction of nuerons)');
end
#valid:

function [nValid_avg,nValid_std]=statCMmat_vld(CMarr)
  l=length(CMarr(:));
  n=size(cell2mat(CMarr(1)),1);
  sum1=zeros(n,1);
  for i=1:l
    x=cell2mat(CMarr(i));
    t=(x(:,1)+x(:,4))./sum(x,2)>0.5; %binary
    sum1+=t;    %sum2+=t.^2; is equal to sum1
  end
  nValid_avg=sum1/l;
  nValid_std=sqrt(nValid_avg.*(1-nValid_avg)); %handle float error
end

function [nValid_avg,nValid_std]=acc2vld(accDis,thrd=0.5)
  vmat=accDis>=thrd;
  [nValid_avg,nValid_std]=statVec(vmat,1,2);
end
%Va=cell(1,4); Vs=cell(1,4);
%for i=1:4;  [Va(i),Vs(i)]=statCMmat_vld(CMarr(i,:));    end
%[Vat,Vst]=statCMmat_vld(CMarr(:));
%valid_avg_all=[cell2mat(Va), Vat]; valid_std_all=[cell2mat(Vs), Vst];

Va=zeros(n,5); Vs=zeros(n,5);
vld_idx=cell(1,5);
for i=1:4
  [Va(:,i),Vs(:,i)]=acc2vld(AccD(:,m*(i-1)+1:m*i));
  vld_idx(i)=find(Va(:,i)>0.5)';
end
[Va(:,5),Vs(:,5)]=acc2vld(AccD);
vld_idx(5)=find(Va(:,5)>0.5)';

save('../data/valid.mat','Va','Vs','vld_idx')

%relation between being valid and number of spikes
function plotValidNCount(Va,Vs,Ca)
  subplot(3,1,1);imagesc(Va');title('Prob.(AVG) of a neuron being valid');caxis([0 1]);colorbar;colormap(gray);
  set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
  set(gca,'xtick',[1:19])
  subplot(3,1,2);imagesc(Vs');title('STD of a neuron being valid');caxis([0 1]);colorbar;colormap(gray);
  set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
  set(gca,'xtick',[1:19])
  fraction=bsxfun(@rdivide,Ca,sum(Ca));
  subplot(3,1,3);imagesc(log10(fraction'));title('Log10 of spikes count fraction');colorbar;colormap(gray);
  set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
  set(gca,'xtick',[1:19])
end
plotValidNCount(Va,Vs,Ca)

#################
#Adj and weight

Aa=cell(1,5); As=cell(1,5);
for i=1:4;  [Aa(i),As(i)]=statMat(Aarr(:,i));   end
[Aa(5),As(5)]=statMat(Aarr(:));
Wa=cell(1,5); Ws=cell(1,5);
for i=1:4;  [Wa(i),Ws(i)]=statMat(Warr(:,i));   end
[Wa(5),Ws(5)]=statMat(Warr(:));

save('../data/statAW.mat','Aa','As','Wa','Ws')

%%figures of A (statistics data)
function show4A(Adata,titlePre,titleVar,titleSuf)
  for i=1:4;
    temp=cell2mat(Adata(i));
    subplot(2,2,i);imagesc(temp);title(['AVG adjacency of ',cell2mat(titleVar(i))]);caxis([0 1]);colorbar;colormap(gray);
  end
end

show4A(Aa,'AVG adjacency of ',cue_name,'')
show4A(As,'STD adjacency of ',cue_name,'')

subplot(2,2,1);imagesc(cell2mat(Aa(5)));title('AVG adjacency overall');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,2);imagesc(cell2mat(As(5)));title('STD adjacency overall');caxis([0 1]);colorbar;colormap(gray);

#A pairwise cue difference/similarity
pw_a1=zeros(4);pw_a2=zeros(4);pw_a3=zeros(4);pw_std=zeros(4);
for i=1:4;for j=1:4;
  %if(i==j)continue;end
  pw_a1(i,j)=sum(sum( (cell2mat(Aa(i))==1) != (cell2mat(Aa(j))==1) ));
  pw_a2(i,j)=sum(sum( (cell2mat(Aa(i))>0) != (cell2mat(Aa(j))>0) ));
  pw_a3(i,j)=sum(sum( cell2mat(Aa(i)) != cell2mat(Aa(j)) ));
  [~,_t]=statMat([Aarr(:,i);Aarr(:,j)]);
  pw_std(i,j)=sum(sum(_t));
end;end
pw_a1,pw_a2,pw_a3,pw_std,sum(sum(cell2mat(As(5))))

#individual difference check of A
function bone=findBoneAvg(Aa,thrd=0.5)
  bone=cell(size(Aa));
  for i=1:length(Aa(:)); bone(i)=cell2mat(Aa(i))>thrd; end;
end
function bone=findBoneStd(Aa,As,thrd=0.5)
  %0 -> not connected, 1 -> connected, 0.5 -> not sure
  bone=cell(size(As));
  for i=1:length(As(:))
    mask=cell2mat(As(i))>thrd;
    bone(i)=cell2mat(Aa(i)).*mask+(zeros(size(mask))+0.5).*(1-mask);
  end;
end

function [dif_10]=boneDiff(bone)
  n=length(bone(:));
  dif_10=zeros(n);
  for i=1:n;for j=1:n;
    dif_10(i,j)=sum(sum( (cell2mat(bone(i))==1) & (cell2mat(bone(j))==0) ));
  end;end
end

bone50=findBoneAvg(Aa(1:4),0.5);
show4A(bone50,'Core Connectivity of ',cue_name,'')
dif_10=boneDiff(bone50(1:4))
dif_01=dif_10'

%%figures of A (individual data)
function showIndividualA(Aarr,bone)
  if(iscell(bone)) bone=cell2mat(bone); end
  for i=1:9
    temp=cell2mat(Aarr(i))-0.5*bone;
    %-0.5 -> miss; 0 -> common unconnected; 0.5 -> common connected; 1 -> new
    subplot(3,3,i);imagesc(temp);caxis([-0.5 1]);colorbar;colormap(jet(4));%title(['adjacency']);
  end;
  cbh = findobj( gcf(), 'tag', 'colorbar');
  set(cbh,'ytick',-.5:.5:1,'yticklabel',{'miss','c-unc','c-con','new'})
end

cue_id=1;
rndidx=randperm(m,9);
showIndividualA(Aarr(rndidx,cue_id),bone50(cue_id));

%distribution of plus/miss compared with bone
function [numPlus,numMiss,matPlus,matMiss]=distriPlusMiss(Aarr,bones)
  if(size(Aarr,2)>length(bones)) error('length of bones is too small'); end;
  [m,n]=size(Aarr);
  numPlus=zeros(m,n);  numMiss=zeros(m,n);%on each trial
  matPlus=cell(1,n);  matMiss=cell(1,n);%on each neuron pair
  for j=1:n
    b=cell2mat(bones(j));
    mp=zeros(size(b)); mm=zeros(size(b));
    for i=1:m
      temp=cell2mat(Aarr(i,j))-b;
      %-1 -> miss(0-1); 0 -> same(0-0,1-1); 1 -> plus(1-0)
      tp=temp==1; tm=temp==-1;
      mp+=tp;
      mm+=tm;
      numPlus(i,j)=sum(sum(tp));
      numMiss(i,j)=sum(sum(tm));
    end
    matPlus(j)=mp;  matMiss(j)=mm;
  end
end

[numPlus,numMiss,matPlus,matMiss]=distriPlusMiss(Aarr,bone50);

%figure for # distribution on cues
for i=1:4;
  [h,v]=hist([numPlus(:,i),numMiss(:,i)],8);
  subplot(2,2,i);bar(v,h/m);legend('+','-',"location",'northeast');colormap('summer');
  xlabel('number');ylabel('percentage');title(['Dis. of +/- edges # on ',cell2mat(cue_name(i))]);
end
[h,v]=hist([numPlus(:),numMiss(:)],12);
subplot(2,2,1);bar(v,h/4/m);legend('+','-',"location",'northeast');colormap('summer');
xlabel('number');ylabel('percentage');title('Dis. of +/- edges # on all trials');

%figure for # distribution on neuron pairs
for i=1:4;
  subplot(2,2,i);imagesc(cell2mat(matPlus(i))/m);colorbar;caxis([0,1]);title(['+ dis. for all pairs on ',cell2mat(cue_name(i))]);
end;
for i=1:4;
  subplot(2,2,i);imagesc(cell2mat(matMiss(i))/m);colorbar;caxis([0,1]);title(['- dis. for all pairs on ',cell2mat(cue_name(i))]);
end;

for i=1:4; sum(sum(cell2mat(matPlus(i))!=0 & cell2mat(matMiss(i))!=0)) end;
%the results are all 0, so the 2 figures can be merged
for i=1:4;
  subplot(2,2,i);imagesc(cell2mat(matPlus(i))/m-cell2mat(matMiss(i))/m);colorbar;caxis([-1,1]);
  title(['+/- dis. for all pairs on ',cell2mat(cue_name(i))]);colormap(jet);
end;


%%figures of W
for i=1:4;
  temp=cell2mat(Wa(i)); tit='AVG weight of cue ';
  temp=(cell2mat(Aa(i))>0).*temp;   tit='valid AVG weight of cue ';
  subplot(2,2,i);imagesc(temp);title([tit,num2str(i)]);caxis([-1 1]);colorbar;colormap(jet);
end

for i=1:4;
  temp=cell2mat(Ws(i)); tit='STD weight of cue ';
  temp=(cell2mat(Aa(i))>0).*temp;   tit='valid STD weight of cue ';
  subplot(2,2,i);imagesc(temp);title([tit,num2str(i)]);caxis([0 1]);colorbar;colormap(gray);
end

temp=cell2mat(Wa(5)).*(cell2mat(Aa(5))>0);
subplot(2,2,1);imagesc(temp);title('valid AVG weight overall');caxis([-1 1]);colorbar;colormap(gray);
temp=Ws(5).*(cell2mat(Aa(5))>0);
subplot(2,2,2);imagesc(temp);title('valid STD weight overall');caxis([0 1]);colorbar;colormap(gray);

#weight statistics:
function showWeightXtrial(Wa,Ws,varargin)
  l=length(Wa);
  if(nargin==3)
    idx=cell2mat(varargin);
  end
  x=zeros(1,l); x2=zeros(2,l); %averaged weight 
  y=zeros(1,l); y2=zeros(2,l); %stardard derivation of weight
  for i=1:l
    temp=cell2mat(Wa(i));
    if(nargin==3)
      idx_i=cell2mat(idx(i));
      temp=temp(idx_i,idx_i);
    end
    x(i)=mean(mean(temp));
    x2(:,i)=[max(max(temp)); min(min(temp))];
    temp=cell2mat(Ws(i));
    y(i)=mean(mean(temp));
    y2(:,i)=[max(max(temp)); min(min(temp))];
  end
  x   %avg weight on each cue
  y   %std weight on each cue
  (y-y2(2,:))./(y2(1,:)-y2(2,:))*100  %normalized std weight
end

showWeightXtrial(Wa,Ws);
showWeightXtrial(Wa,Ws,vld_idx);


#weight pairwise cue difference/similarity
pw_w=zeros(4);
for i=1:4;
  _t=cell2mat(Wa(i));_s=sum(sum(abs(_t)));
  for j=1:4;
    if(i==j)continue;end
    pw_w(i,j)=sum(sum(abs( _t - cell2mat(Wa(j)) )))/_s;
end;end

#weight distribution

Wdis=distriMat(Warr(:));

for i=1:4
  _t=Wdis(:,:,m*(i-1)+1:m*i);
%  _t=Wdis(cell2mat(vld_idx(i)),cell2mat(vld_idx(i)),m*(i-1)+1:m*i);
  subplot(4,2,2*i-1);hist(_t(:),20);title(['Dist. on ',cell2mat(cue_name(i))]);ylabel('frequency');
  subplot(4,2,2*i);plotcdf(_t(:),50);title(['CDF on ',cell2mat(cue_name(i))]);ylabel('CDF');
end

%figure on overall data
function plotWeightDisCmp(Wdis,vld_idx)
  subplot(2,2,1);hist(Wdis(:),100);title('Distribution of all weights');ylabel('frequency');
  subplot(2,2,2);plotcdf(Wdis(:),50);title('CDF of all weights');ylabel('CDF');
  t=Wdis(vld_idx,vld_idx,:)(:);
  subplot(2,2,3);hist(t,100);title('Distribution of all valid weights');ylabel('frequency');
  subplot(2,2,4);plotcdf(t,50);title('CDF of all weights');ylabel('CDF');
end
plotWeightDisCmp(Wdis,cell2mat(vld_idx(5)))


%distribution on some edges
dis_idx1=randperm(19,9); dis_idx2=randperm(19,9);
cue_id=1;
for i=1:9; %distribution of 9 edges on the same cue
  subplot(3,3,i);hist(Wdis(dis_idx1(i),dis_idx2(i),(cue_id-1)*40+1:cue_id*40));
  title(['W dist. ',num2str(dis_idx1(i)),'-',num2str(dis_idx2(i)), ...
    ' on cue ',num2str(cue_id),', A=',num2str(cell2mat(Aa(cue_id))(dis_idx1(i),dis_idx2(i)))]);
end

for i=1:4; %distribution of 1 edge on 4 cues
  subplot(2,2,i);hist(Wdis(dis_idx1(i),dis_idx2(i),(cue_id-1)*40+1:cue_id*40));
  title(['W dist. ',num2str(dis_idx1(i)),'-',num2str(dis_idx2(i)), ...
    ' on cue ',num2str(cue_id),', A=',num2str(cell2mat(Aa(cue_id))(dis_idx1(i),dis_idx2(i)))]);
end


