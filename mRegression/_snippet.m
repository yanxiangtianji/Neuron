#################
#get data

function [Aarr,Warr,CMarr,SCarr]=whole_list_AW(fn_list,n_trial,n,D,Ainit,Winit,lambdaA,lambdaW)
  n_cue=length(fn_list);
  Aarr=cell(1,n_trial);   #Adjacent (n*n)
  Warr=cell(1,n_trial);   #Weight (n*n)
  CMarr=cell(1,n_trial);  #Confusion Matrix (n*4)
  SCarr=cell(1,n_trial); #Spike Count (n)
  for i=1:n_trial
    %disp(fn_list(i))
    %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
    rData=readRaw(cell2mat(fn_list(i)));   %dMin=1; dUnit=1;
    %rData=pickDataByTime(rData,30000,60000);
    sc=zeros(n,1);
    for j=1:n
      sc(j)=length(cell2mat(rData(j)));
    end
    SCarr(i)=sc;
    [A,W,CM]=trainAW(rData,D,lambdaA,lambdaW,Ainit,Winit);
    Aarr(i)=A;
    Warr(i)=W;
    CMarr(i)=CM;
  end
end

m=20;
n=19;

%idx=randperm(40,m);
%[Aarr1,Warr1,CMarr1,SCmat1]=whole_list_AW(fn_c1(idx),m,n,D,Ainit,Winit,1,1);
%[Aarr2,Warr2,CMarr2,SCmat2]=whole_list_AW(fn_c2(idx),m,n,D,Ainit,Winit,1,1);
%[Aarr3,Warr3,CMarr3,SCmat3]=whole_list_AW(fn_r1(idx),m,n,D,Ainit,Winit,1,1);
%[Aarr4,Warr4,CMarr4,SCmat4]=whole_list_AW(fn_r2(idx),m,n,D,Ainit,Winit,1,1);

m=40;
Aarr=cell(4,m);Warr=cell(4,m);CMarr=cell(4,m);SCarr=cell(4,m);
fnlist=cell(4,m);
fnlist(1,:)=fn_c1(1:m);fnlist(2,:)=fn_c2(1:m);fnlist(3,:)=fn_r1(1:m);fnlist(4,:)=fn_r2(1:m);
for i=1:4
  tic;[Aarr(i,:),Warr(i,:),CMarr(i,:),SCarr(i,:)]=whole_list_AW(fnlist(i,:),m,n,D,Ainit,Winit,1,1);toc;
end
save('from_data.mat','D','Ainit','Winit','Aarr','Warr','CMarr','SCarr')

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


Aa=cell(4,1); As=cell(4,1);
for i=1:4;  [Aa(i),As(i)]=statMat(Aarr(i,:));   end
[Aat,Ast]=statMat(Aarr(:));
Wa=cell(4,1); Ws=cell(4,1);
for i=1:4;  [Wa(i),Ws(i)]=statMat(Warr(i,:));   end
[Wat,Wst]=statMat(Warr(:));
save('statAW.mat','Aa','As','Aat','Ast','Wa','Ws','Wat','Wst')

for i=1:4;
  temp=cell2mat(Aa(i));
  subplot(2,2,i);imagesc(temp);title(['AVG adjacency of cue ',num2str(i)]);caxis([0 1]);colorbar;colormap(gray);
end
for i=1:4;
  temp=cell2mat(As(i));
  subplot(2,2,i);imagesc(temp);title(['STD adjacency of cue ',num2str(i)]);caxis([0 1]);colorbar;colormap(gray);
end
subplot(2,2,1);imagesc(Aat);title('AVG adjacency overall');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,2);imagesc(Ast);title('STD adjacency overall');caxis([0 1]);colorbar;colormap(gray);

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
temp=Wat.*(Aat>0);
subplot(2,2,1);imagesc(temp);title('valid AVG weight overall');caxis([-1 1]);colorbar;colormap(gray);
temp=Wst.*(Aat>0);
subplot(2,2,2);imagesc(temp);title('valid STD weight overall');caxis([0 1]);colorbar;colormap(gray);

#weight statistics:
x=zeros(1,4); x2=zeros(2,4); %averaged weight 
y=zeros(1,4); y2=zeros(2,4); %stardard derivation of weight
for i=1:4
  temp=cell2mat(Wa(i));
  x(i)=mean(mean(temp));
  x2(:,i)=[max(max(temp)); min(min(temp))];
  temp=cell2mat(Ws(i));
  y(i)=mean(mean(temp));
  y2(:,i)=[max(max(temp)); min(min(temp))];
end
x   %avg weight on different cues
y   %std weight on different cues
(y-y2(2,:))./(y2(1,:)-y2(2,:))*100  %normalized std weight


#pairwise cue difference/similarity
pw_a=zeros(4);
for i=1:4;for j=1:4;
  if(i==j)continue;end
  pw_a(i,j)=sum(sum( (cell2mat(Aa(i))==1) != (cell2mat(Aa(j))==1) ));
  %pw_a(i,j)=sum(sum( (cell2mat(Aa(i)>0) != (cell2mat(Aa(j))>0) ));
  %pw_a(i,j)=sum(sum( cell2mat(Aa(i)) != cell2mat(Aa(j)) ));
end;end

pw_w=zeros(4);
for i=1:4;for j=1:4;
  if(i==j)continue;end
  pw_w(i,j)=sum(sum(abs( cell2mat(Wa(i)) - cell2mat(Wa(j)) )));
end;end

#distribution of weight

function dis=distriMat(arr)
  l=length(arr(:));
  n=size(cell2mat(arr(1)),1);
  dis=zeros(n,n,l);
  for i=1:l
    dis(:,:,i)=cell2mat(arr(i));
  end
end

Wdis=distriMat(Warr'(:));

dis_idx1=randperm(19,9); dis_idx2=randperm(19,9);
cue_id=1;
for i=1:9;
  subplot(3,3,i);hist(Wdis(dis_idx1(i),dis_idx2(i),(cue_id-1)*40+1:cue_id*40));
  title(['W distrib. ',num2str(dis_idx1(i)),'-',num2str(dis_idx2(i)), ...
    ', A=',num2str(cell2mat(Aa(cue_id))(dis_idx1(i),dis_idx2(i)))]);
end


##################
#valid:

function [valid_prob,valid_prob_std]=statCMmat(CMarr)
  l=length(CMarr(:));
  x=cell2mat(CMarr(1));
  t=(x(:,1)+x(:,4))./sum(x,2)>0.5;
  sum1=t;
  sum2=t.^2;
  for i=2:l
    x=cell2mat(CMarr(i));
    t=(x(:,1)+x(:,4))./sum(x,2)>0.5;
    sum1+=t;
    sum2+=t.^2;
  end
  valid_prob=sum1/l;
  valid_prob_std=sqrt(max(0,sum2/l-valid_prob.^2)); %handle float error
end

%[valid1,vs1]=statCMmat(CMarr1);   [valid2,vs2]=statCMmat(CMarr2);
%[valid3,vs3]=statCMmat(CMarr3);   [valid4,vs4]=statCMmat(CMarr4);
%valid=(valid1+valid2+valid3+valid4)/4;
%vs=(vs1+vs2+vs3+vs4)/4;
%vidx=valid>0.5;
%
%valid_all=[valid1 valid2 valid3 valid4 valid]';
%vs_all=[vs1 vs2 vs3 vs4 vs]';
%save('valid.mat','valid1','vs1','valid2','vs2','valid3','vs3','valid4','vs4')

Va=cell(4,1); Vs=cell(4,1);
for i=1:4;  [Va(i),Vs(i)]=statCMmat(CMarr(i,:));    end
[Vat,Vst]=statCMmat(CM(:));
save('valid.mat',Va,Vs,Vat,Vst)

subplot(4,1,1);imagesc(valid_all);title('Prob.(AVG) of a neuron being valid');caxis([0 1]);colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
set(gca,'xtick',[1:19])
subplot(4,1,2);imagesc(vs_all);title('STD of a neuron being valid');caxis([0 1]);colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
set(gca,'xtick',[1:19])

#valid Weight
Wav1=Wa1(vidx,vidx);Wav2=Wa2(vidx,vidx);Wav3=Wa3(vidx,vidx);Wav4=Wa4(vidx,vidx);
Wav=Wa(vidx,vidx);
Wsv1=Ws1(vidx,vidx);Wsv2=Ws2(vidx,vidx);Wsv3=Ws3(vidx,vidx);Wsv4=Ws4(vidx,vidx);
Wsv=Ws(vidx,vidx);
x=[mean(mean(Wav1)),mean(mean(Wav2)),mean(mean(Wav3)),mean(mean(Wav4)),mean(mean(Wav))]
y=[mean(mean(Wsv1)),mean(mean(Wsv2)),mean(mean(Wsv3)),mean(mean(Wsv4)),mean(mean(Wsv))]
y2=[max(max(Wav1)),max(max(Wav2)),max(max(Wav3)),max(max(Wav4)),max(max(Wav));
min(min(Wav1)),min(min(Wav2)),min(min(Wav3)),min(min(Wav4)),min(min(Wav))]
y3=(y2(1,:)-y2(2,:))
y./x
y./y3*100

#################
#num of spike:

function [avgV,stdV]=statVec(mat)
  mat=bsxfun(@rdivide,mat,sum(mat,2));
  l=size(mat,1);
  avgV=mean(mat);
  stdV=sqrt(var(mat)*(l-1)/l);
end

[Sa1,Ss1]=statVec(SCmat1);  [Sa2,Ss2]=statVec(SCmat2);
[Sa3,Ss3]=statVec(SCmat3);  [Sa4,Ss4]=statVec(SCmat4);
Sa=(Sa1+Sa2+Sa3+Sa4)/4;
Ss=(Ss1+Ss2+Ss3+Ss4)/4;

Sa_all=[Sa1; Sa2; Sa3; Sa4; Sa];
Ss_all=[Ss1; Ss2; Ss3; Ss4; Ss];

save('count.mat','Sa1','Ss1','Sa2','Ss2','Sa3','Ss3','Sa3','Ss3','Sa4','Ss4')

%subplot(3,1,2);imagesc(Sa_all);title('AVG fraction of spikes');caxis([0 0.25]);colorbar;colormap(gray);
subplot(4,1,3);imagesc(log10(Sa_all));title('Log10 of AVG fraction of spikes');colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
set(gca,'xtick',[1:19])

subplot(4,1,4);imagesc(Ss_all);title('STD fraction of spikes');colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
set(gca,'xtick',[1:19])
