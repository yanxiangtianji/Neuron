fn_spike='../data/real/all.txt';
fn_processed='../data/real/st/all.txt';
fn_processed='../data/real/st/cue1_0.txt';

disp('Initial:');

n_c1=54;    n_c2=52;
fn_c1=cell(n_c1);   fn_c2=cell(n_c2);
for i=1:n_c1
  fn_c1(i)=['../data/real/st/cue1_',num2str(i-1),'.txt'];
end
for i=1:n_c2
  fn_c2(i)=['../data/real/st/cue2_',num2str(i-1),'.txt'];
end
n=19;

%dMin=0.0001;    dUnit=0.0001;  %for readRawSpike
dMin=1; dUnit=1;    %readRaw
%[D,~,W]=init(n,dMin,dUnit);
lambdaA=1;
lambdaW=1;

function [accMat]=whole_cue_AW(fn_list,n,D,Ainit,Winit,lambdaA,lambdaW)
  n_cue=length(fn_list);
  accMat=zeros(n_cue,n);  %overall accuarncy of all neuron
  for i=1:n_cue
    %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
    rData=readRaw(cell2mat(fn_list(i)));   dMin=1; dUnit=1;
    %n=length(rData);
    [~,~,CM]=trainAW(rData,D,lambdaA,lambdaW,Ainit,Winit);
  %  showCM(sum(CM));
    acc=(CM(:,1)+CM(:,4))./sum(CM,2);
    accMat(i,:)=acc';
  end
end

disp('Cue1:');
stat1=whole_cue_AW(fn_c1,n,D,W,lambdaA,lambdaW);

disp('Cue2:');
stat2=whole_cue_AW(fn_c2,n,D,W,lambdaA,lambdaW);

save(['full_aw',num2str(step),'.mat'],'stat1','stat2');
