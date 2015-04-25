#################
#get data

function [Aarr,Warr,CMarr,SCmat]=whole_list_AW(fn_list,n_cue,n,D,Ainit,Winit,lambdaA,lambdaW)
  n_cue=length(fn_list);
  Aarr=cell(n_cue,1);   #Adjacent
  Warr=cell(n_cue,1);   #Weight
  CMarr=cell(n_cue,1);  #Confusion Matrix
  SCmat=zeros(n_cue,n); #Spike Count
  for i=1:n_cue
    %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
    rData=readRaw(cell2mat(fn_list(i)));   %dMin=1; dUnit=1;
    for j=1:n
      SCmat(i,j)=length(cell2mat(rData(j)));
    end
    [A,W,CM]=trainAW(rData,D,lambdaA,lambdaW,Ainit,Winit);
    showCM(sum(CM));
    Aarr(i)=A;
    Warr(i)=W;
    CMarr(i)=CM;
  end
end

idx=randperm(40,20);
n=19;
[Aarr1,Warr1,CMmat1,SCmat1]=whole_list_AW(fn_c1(idx),20,n,D,Ainit,Winit,1,1);
[Aarr2,Warr2,CMmat2,SCmat2]=whole_list_AW(fn_c2(idx),20,n,D,Ainit,Winit,1,1);
[Aarr3,Warr3,CMmat3,SCmat3]=whole_list_AW(fn_r1(idx),20,n,D,Ainit,Winit,1,1);
[Aarr4,Warr4,CMmat4,SCmat4]=whole_list_AW(fn_r2(idx),20,n,D,Ainit,Winit,1,1);

save('from_cue1.mat','idx','D','Ainit','Winit','Aarr1','Warr1','CMarr1','SCmat1')
save('from_cue2.mat','idx','D','Ainit','Winit','Aarr2','Warr2','CMarr2','SCmat2')
save('from_rest1.mat','idx','D','Ainit','Winit','Aarr3','Warr3','CMarr3','SCmat3')
save('from_rest2.mat','idx','D','Ainit','Winit','Aarr4','Warr4','CMarr4','SCmat4')

#################
#Adj and weight

function [avgM,stdM]=statMat(arr)
  l=length(arr);
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

[Aa1,As1]=statMat(Aarr1);   [Aa2,As2]=statMat(Aarr2);
[Aa3,As3]=statMat(Aarr3);   [Aa4,As4]=statMat(Aarr4);
Aa=(Aa1+Aa2+Aa3+Aa4)/4; As=(As1+As2+As3+As4)/4;
[Wa1,Ws1]=statMat(Warr1);   [Wa2,Ws2]=statMat(Warr2);
[Wa3,Ws3]=statMat(Warr3);   [Wa4,Ws4]=statMat(Warr4);
Wa=(Wa1+Wa2+Wa3+Wa4)/4; Ws=(Ws1+Ws2+Ws3+Ws4)/4;

x=[mean(mean(Wa1)),mean(mean(Wa2)),mean(mean(Wa3)),mean(mean(Wa4)),mean(mean(Wa))]
y=[mean(mean(Ws1)),mean(mean(Ws2)),mean(mean(Ws3)),mean(mean(Ws4)),mean(mean(Ws))]
y2=[max(max(Wa1)),max(max(Wa2)),max(max(Wa3)),max(max(Wa4)),max(max(Wa))
min(min(Wa1)),min(min(Wa2)),min(min(Wa3)),min(min(Wa4)),min(min(Wa))]
y3=(y2(1,:)-y2(2,:))
y./x
y./y3*100

save('statA.mat','Aa1','As1','Aa2','As2','Aa3','As3','Aa4','As4','Aa','As')
save('statW.mat','Wa1','Ws1','Wa2','Ws2','Wa3','Ws3','Wa4','Ws4','Wa','Ws')

subplot(2,2,1);imagesc(Aa1);title('Avarge Adj. of cue 1');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,2);imagesc(Aa2);title('Avarge Adj. of cue 2');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,3);imagesc(Aa3);title('Avarge Adj. of rest 1');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,4);imagesc(Aa4);title('Avarge Adj. of rest 2');caxis([0 1]);colorbar;colormap(gray);

subplot(2,2,1);imagesc(Aa);title('Avarge Adj. overall');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,2);imagesc(As);title('STD Adj. overall');caxis([0 1]);colorbar;colormap(gray);


subplot(2,2,1);imagesc(Ws1);title('STD weight of cue 1');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,2);imagesc(Ws2);title('STD weight of cue 2');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,3);imagesc(Ws3);title('STD weight of rest 1');caxis([0 1]);colorbar;colormap(gray);
subplot(2,2,4);imagesc(Ws4);title('STD weight of rest 2');caxis([0 1]);colorbar;colormap(gray);

subplot(2,2,1);imagesc(Wa);title('AVG weight overall');caxis([-1 1]);colorbar;colormap(gray);
subplot(2,2,2);imagesc(Ws);title('STD weight overall');caxis([0 1]);colorbar;colormap(gray);

#pairwise cue difference
m=zeros(4);
w(1)=Wa1;w(2)=Wa2;w(3)=Wa3;w(4)=Wa4;
for i=1:4;for j=1:4;
  if(i==j)continue;end
  m(i,j)=sum(sum(abs(cell2mat(w(i))-cell2mat(w(j)) )));
end;end

##################
#valid:

function [valid_prob,valid_prob_std]=statCMmat(CMarr)
  l=length(CMarr);
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

[valid1,vs1]=statCMmat(CMarr1);   [valid2,vs2]=statCMmat(CMarr2);
[valid3,vs3]=statCMmat(CMarr3);   [valid4,vs4]=statCMmat(CMarr4);
valid=(valid1+valid2+valid3+valid4)/4;
vs=(vs1+vs2+vs3+vs4)/4;
vidx=valid>0.5;

valid_all=[valid1 valid2 valid3 valid4 valid]';
vs_all=[vs1 vs2 vs3 vs4 vs]';
save('valid.mat','valid1','vs1','valid2','vs2','valid3','vs3','valid4','vs4')

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

save('count.mat','Sa1','Ss1','Sa2','Ss2','Sa3','Ss3','Sa3','Ss3')

%subplot(3,1,2);imagesc(Sa_all);title('AVG fraction of spikes');caxis([0 0.25]);colorbar;colormap(gray);
subplot(4,1,3);imagesc(log10(Sa_all));title('Log10 of AVG fraction of spikes');colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
set(gca,'xtick',[1:19])

subplot(4,1,4);imagesc(Ss_all);title('STD fraction of spikes');colorbar;colormap(gray);
set(gca,'yticklabel',['dummy';'cue 1'; 'cue 2'; 'rest 1'; 'rest 2'; 'all'])
set(gca,'xtick',[1:19])
