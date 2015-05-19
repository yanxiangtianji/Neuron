fn_spike='../data/real/st/all.txt';
fn_processed='../data/real/st/all.txt';
fn_processed='../data/real/st/cue1_0.txt';

disp('Initial:');

n_c1=54;    n_c2=52;
fn_c1=cell(n_c1,1);   fn_c2=cell(n_c2,1);
fn_r1=cell(n_c1,1);   fn_r2=cell(n_c2,1);
fn_prefix='../data/real/st/';   %fn_prefix='../data/real/st3-6/';
for i=1:n_c1    fn_c1(i)=[fn_prefix,'cue1_',num2str(i-1),'.txt']; end
for i=1:n_c2    fn_c2(i)=[fn_prefix,'cue2_',num2str(i-1),'.txt']; end
for i=1:n_c1    fn_r1(i)=[fn_prefix,'rest1_',num2str(i-1),'.txt'];    end
for i=1:n_c2    fn_r2(i)=[fn_prefix,'rest2_',num2str(i-1),'.txt'];    end

n=19;

%dMin=0.0001;    dUnit=0.0001;  %for readRawSpike
dMin=1; dUnit=1;    %readRaw
[D,Ainit,Winit]=init(n,dMin,dUnit);
lambdaA=1;
lambdaW=1;

function [accMat]=whole_cue_W(fn_list,n,D,Winit,lambda)
  n_cue=length(fn_list);
  accMat=zeros(n_cue,n);  %overall accuarncy of all neuron
  for i=1:n_cue
    %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
    rData=readRaw(cell2mat(fn_list(i)));   dMin=1; dUnit=1;
    %n=length(rData);
    [~,CM]=trainW(rData,D,lambdaW,Winit);
  %  showCM(sum(CM));
    acc=(CM(:,1)+CM(:,4))./sum(CM,2);
    accMat(i,:)=acc';
  end
end

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

disp('W Cue1:');
%stat1w=whole_cue_W(fn_c1,n,D,W,lambda);
disp('W Cue2:');
stat2w=whole_cue_W(fn_c2,n,D,Winit,lambdaW);
%save(['full_w',num2str(step),'.mat'],'stat1w','stat2w');

disp('AW Cue1:');
%stat1aw=whole_cue_AW(fn_c1,n,D,A,W,lambda);
disp('AW Cue2:');
stat2aw=whole_cue_AW(fn_c2,n,D,Ainit,Winit,lambdaA,lambdaW);
%save(['full_aw',num2str(step),'.mat'],'stat1aw','stat2aw');

save(['cmp',num2str(step),'.mat'],'stat2w','stat2aw');
