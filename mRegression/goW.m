fn_spike='../data/real/all.txt';
fn_processed='../data/real/st/all.txt';
fn_processed='../data/real/st/cue1_0.txt';

%rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
rData=readRaw(fn_processed);   dMin=1; dUnit=1;
n=length(rData);

disp('Initial:');

W=rand(n,n);
%Ainit=20*rand(n,n)-10;
%A=zeros(n);
D=initDelay(n,dMin,dUnit,'pl');
CM=zeros(n,1);
lambda=100;
for i=1:n
  disp(sprintf('Working idx=%d',i));
  [seq,cls]=mergeWithDelay(rData,i,D);
  [X,y]=genDataByRef(n,seq,cls,rData(i));
  [W(:,i),J]=trainW(i,X,y,W(:,i),lambda);
%  [A(:,i),W(:,i),J]=trainAW(i,X,y,Ainit(:,i),W(:,i),lambda);
  disp(sprintf('Minimal error=%f',J));
  CM(i)=testW(W(:,i),X,y);
%  CM(i)=testAW(A(:,i),W(:,i),X,y);
  disp(sprintf('  accurancy=%f',mean(y==predictW(W(:,i),X))));
end

