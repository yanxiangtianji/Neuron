#################
#get data

%function [Aarr,Warr,CMarr,SCarr]=whole_list_AW(fn_list,n_trial,n,D,lambdaA,lambdaW,fRep,Ainit,Winit)
function [Aarr,Warr,CMarr]=whole_list_AW(fn_list,n_trial,n,D,lambdaA,lambdaW,fRep,Ainit,Winit)
  n_cue=length(fn_list);
  Aarr=cell(n_trial,1);   #Adjacent (n*n)
  Warr=cell(n_trial,1);   #Weight (n*n)
  CMarr=cell(n_trial,1);  #Confusion Matrix (n*4)
%  SCarr=cell(n_trial,1);  #Spike Count (n)
  for i=1:n_trial
    %disp(fn_list(i))
    %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
    rData=readRaw(cell2mat(fn_list(i)));   %dMin=1; dUnit=1;
    %rData=pickDataByTime(rData,30000,60000);
%    sc=zeros(n,1);
%    for j=1:n;  sc(j)=length(cell2mat(rData(j)));  end
%    SCarr(i)=sc;
    [A,W,CM]=trainAW(rData,D,lambdaA,lambdaW,fRep,Ainit,Winit);
    Aarr(i)=A;
    Warr(i)=W;
    CMarr(i)=CM;
  end
end

n=19;
m=40;
fnlist=cell(m,4);
fnlist(:,1)=fn_c1(1:m);fnlist(:,2)=fn_c2(1:m);fnlist(:,3)=fn_r1(1:m);fnlist(:,4)=fn_r2(1:m);
cue_name={'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'};

lambdaA=1;
lambdaW=1;
vanishTime95=2000;   %it takes 200ms(time unit in data file is 0.1ms) to degrade 95%.
fRep=-log(0.05)/vanishTime95;
%m=20; idx=randperm(40,m);

Aarr=cell(m,4);Warr=cell(m,4);CMarr=cell(m,4);SCarr=cell(m,4);
for i=1:4
%  tic;[Aarr(:,i),Warr(:,i),CMarr(:,i),SCarr(:,i)]=whole_list_AW(fnlist(:,i),m,n,D,lambdaA,lambdaW,fRep,Ainit,Winit);toc;
  tic;[Aarr(:,i),Warr(:,i),CMarr(:,i)]=whole_list_AW(fnlist(:,i),m,n,D,lambdaA,lambdaW,fRep,Ainit,Winit);toc;
end
save('data1.mat','D','Ainit','Winit','Aarr','Warr','CMarr','SCarr')

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

function [avgV,stdV]=statVec(dis)
  avgV=mean(dis,2);
  stdV=std(dis,1,2);
end

AccAvg=zeros(n,5);  AccStd=zeros(n,5);
for cue_id=1:4;
  [AccAvg(:,cue_id),AccStd(:,cue_id)]=statVec(AccD(:,m*(cue_id-1)+1:m*cue_id));
end
[AccAvg(:,5),AccStd(:,5)]=statVec(AccD);

save('acc.mat','AccD','AccAvg','AccStd');

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
for i=1:4;
  [Va(:,i),Vs(:,i)]=acc2vld(AccD(:,m*(i-1)+1:m*i));
end
[Va(:,5),Vs(:,5)]=acc2vld(AccD);

vld_idx=cell(1,5);
for i=1:5;
  vld_idx(i)=find(Va(:,i)>0.5)';
end

save('valid.mat','Va','Vs','vld_idx')


#################
#num of spike:

function dis=distriVec(arr)
  l=length(arr(:));
  n=size(cell2mat(arr(1)),1);
  disAcc=zeros(n,l);
  for i=1:l
    dis(:,i)=cell2mat(arr(i));
  end
end

Cdis=distriVec(SCarr);

Ca=zeros(n,5);  Cs=zeros(n,5);
for i=1:4
  [Ca(:,i),Cs(:,i)]=statVec(Cdis(:,m*(i-1)+1:m*i));
end
[Ca(:,5),Cs(:,5)]=statVec(Cdis);

save('count.mat','Cdis','Ca','Cs')


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

function [avgM,stdM]=statMat(arr)
  l=length(arr(:));
  t=cell2mat(arr(1));
  sum1=t;
  sum2=t.^2;
  for i=2:l
    t=cell2mat(arr(i));
    sum1+=t;
    sum2+=t.^2;
  end
  avgM=sum1/l;
  stdM=sqrt(max(0,sum2/l-avgM.^2));    %handle float error
end


Aa=cell(1,5); As=cell(1,5);
for i=1:4;  [Aa(i),As(i)]=statMat(Aarr(i,:));   end
[Aa(5),As(5)]=statMat(Aarr(:));
Wa=cell(1,5); Ws=cell(1,5);
for i=1:4;  [Wa(i),Ws(i)]=statMat(Warr(i,:));   end
[Wa(5),Ws(5)]=statMat(Warr(:));

save('statAW.mat','Aa','As','Wa','Ws')

%%figures of A
for i=1:4;
  temp=cell2mat(Aa(i));
  subplot(2,2,i);imagesc(temp);title(['AVG adjacency of ',cell2mat(cue_name(i))]);caxis([0 1]);colorbar;colormap(gray);
end

for i=1:4;
  temp=cell2mat(As(i));
  subplot(2,2,i);imagesc(temp);title(['STD adjacency of ',cell2mat(cue_name(i))]);caxis([0 1]);colorbar;colormap(gray);
end

subplot(2,2,1);imagesc(cell2mat(Aa(5)));title('AVG adjacency overall');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,2);imagesc(cell2mat(As(5)));title('STD adjacency overall');caxis([0 1]);colorbar;colormap(gray);

#A pairwise cue difference/similarity
pw_a1=zeros(4);pw_a2=zeros(4);pw_a3=zeros(4);
for i=1:4;for j=1:4;
  if(i==j)continue;end
  pw_a1(i,j)=sum(sum( (cell2mat(Aa(i))==1) != (cell2mat(Aa(j))==1) ));
  pw_a2(i,j)=sum(sum( (cell2mat(Aa(i))>0) != (cell2mat(Aa(j))>0) ));
  pw_a3(i,j)=sum(sum( cell2mat(Aa(i)) != cell2mat(Aa(j)) ));
end;end
pw_a1,pw_a2,pw_a3


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

function dis=distriMat(arr)
  l=length(arr(:));
  n=size(cell2mat(arr(1)),1);
  dis=zeros(n,n,l);
  for i=1:l
    dis(:,:,i)=cell2mat(arr(i));
  end
end

Wdis=distriMat(Warr(:));

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

function plotWeightDis(Wdis,vld_idx)
  subplot(2,2,1);hist(Wdis(:),100);title('Distribution of all weights');ylabel('frequency');
  subplot(2,2,2);plotcdf(Wdis(:),50);
  title('CDF of all weights');ylabel('CDF');
  t=Wdis(vld_idx,vld_idx,:)(:);
  subplot(2,2,3);hist(t,100);title('Distribution of all valid weights');ylabel('frequency');
  subplot(2,2,4);plotcdf(t,50);
  title('CDF of all weights');ylabel('CDF');
end
plotWeightDis(Wdis,cell2mat(vld_idx(5)))




