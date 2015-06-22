fn_spike='../data/real/st/all.txt';
fn_processed='../data/real/st/all.txt';
fn_processed='../data/real/st/cue1_0.txt';

disp('Initial:');

basicParameters()

%dUnit=0.0001;  dMean=0.001; dMin=0;  %for readRawSpike
dUnit=1;  dMean=10; dMin=0;    %readRaw
[D,Ainit,Winit]=init(nNeu,dUnit,dMean,dMin);
lambdaA=1;
lambdaW=1;

function [accMat]=whole_cue_W(fn_list,nNeu,D,Winit,lambda)
  n_cue=length(fn_list);
  accMat=zeros(n_cue,nNeu);  %overall accuarncy of all neuron
  for i=1:n_cue
    %rData=readRawSpike(fn_spike);
    rData=readRaw(cell2mat(fn_list(i)));
    %nNeu=length(rData);
    [~,CM]=trainW(rData,D,lambdaW,Winit);
  %  showCM(sum(CM));
    acc=(CM(:,1)+CM(:,4))./sum(CM,2);
    accMat(i,:)=acc';
  end
end

function [accMat]=whole_cue_AW(fn_list,nNeu,D,Ainit,Winit,lambdaA,lambdaW)
  n_cue=length(fn_list);
  accMat=zeros(n_cue,nNeu);  %overall accuarncy of all neuron
  for i=1:n_cue
    %rData=readRawSpike(fn_spike);
    rData=readRaw(cell2mat(fn_list(i)));
    %nNeu=length(rData);
    [~,~,CM]=trainAW(rData,D,lambdaA,lambdaW,Ainit,Winit);
  %  showCM(sum(CM));
    acc=(CM(:,1)+CM(:,4))./sum(CM,2);
    accMat(i,:)=acc';
  end
end

disp('W Cue1:');
%stat1w=whole_cue_W(fn_c1,nNeu,D,W,lambda);
disp('W Cue2:');
stat2w=whole_cue_W(fn_c2,nNeu,D,Winit,lambdaW);
%save(['full_w',num2str(step),'.mat'],'stat1w','stat2w');

disp('AW Cue1:');
%stat1aw=whole_cue_AW(fn_c1,nNeu,D,A,W,lambda);
disp('AW Cue2:');
stat2aw=whole_cue_AW(fn_c2,nNeu,D,Ainit,Winit,lambdaA,lambdaW);
%save(['full_aw',num2str(step),'.mat'],'stat1aw','stat2aw');

save(['cmp',num2str(step),'.mat'],'stat2w','stat2aw');

[Aarr,W,CMarr]=goTogether(fnlist,19,D,fRep,0.01,1,1,Ainit,Winit);
save('dataTGH.mat','D','fRep','Ainit','Winit','alpha','lambdaA','lambdaW','Aarr','W','CMarr')
