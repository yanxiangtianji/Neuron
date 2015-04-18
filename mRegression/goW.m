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
[D,~,W]=init(n,dMin,dUnit);
lambda=1;

function [stat]=whole_cue_W(fn_list,n,D,Winit,lambda)
  n_cue=length(fn_list);
  stat=zeros(n_cue,n);  %overall accuarncy of all neuron
  for i=1:n_cue
    %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
    rData=readRaw(cell2mat(fn_list(i)));   dMin=1; dUnit=1;
    %n=length(rData);
    [~,CM]=trainW(rData,D,lambda,Winit);
  %  showCM(sum(CM));
    acc=(CM(:,1)+CM(:,4))./sum(CM,2);
    stat(i,:)=acc';
  end
end

function [overallAcc,nValid,normalizedAcc]=desc_stat(stat,thr)
  n=size(stat,2);
  overallAcc=mean(stat,2);
  nValid=sum(stat>=thr,2);
  normalizedAcc=overallAcc./nValid*n;
end

disp('Cue1:');
stat1=whole_cue_W(fn_c1,n,D,W,lambda);

disp('Cue2:');
stat2=whole_cue_W(fn_c2,n,D,W,lambda);

save(['full_w',num2str(step),'.mat'],'stat1','stat2');
