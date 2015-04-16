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
%D=initDelay(n,dMin,dUnit,'pl');
A=initAdjacency(n);
%W=initWeight(n);
lambda=100;

disp('Cue1:');
Acc1=zeros(n_c1,1);
Nworks1=zeros(n_c1,1);
for i=1:n_c1
  %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
  rData=readRaw(cell2mat(fn_c1(i)));   dMin=1; dUnit=1;
  %n=length(rData);
  [~,~,CM]=learnAW(rData,D,lambda,W);
%  showCM(sum(CM));
  acc=(CM(:,1)+CM(:,4))./sum(CM,2);
  Nworks1(i)=sum(acc>=0.6);
  Acc1(i)=mean(acc);
end

disp('Cue2:');
Acc2=zeros(n_c2,1);
Nworks2=zeros(n_c2,1);
for i=1:n_c2
  %rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
  rData=readRaw(cell2mat(fn_c2(i)));   dMin=1; dUnit=1;
  %n=length(rData);
  [~,~,CM]=learnAW(rData,D,lambda,W);
%  showCM(sum(CM));
  acc=(CM(:,1)+CM(:,4))./sum(CM,2);
  Nworks2(i)=sum(acc>=0.6);
  Acc2(i)=mean(acc);
end

save(['full_aw',num2str(step),'.mat'],'Acc1','Nworks1','Acc2','Nworks2');
