fn_spike='../data/real/all.txt';
fn_processed='../data/real/st/all.txt';
fn_processed='../data/real/st/cue1_0.txt';

%rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
rData=readRaw(fn_processed);   dMin=1; dUnit=1;
n=length(rData);

disp('Initial:');

W=rand(n,n);
D=initDelay(n,dMin,dUnit,'pl');
lambda=100;
for i=1:n
  disp(sprintf('Working idx=%d',i));
  [seq,cls]=mergeWithDelay(rData,i,D);
  [X,y]=genDataByRef(n,seq,cls,rData(i));
  [W(:,i),J]=trainW(i,X,y,W(:,i),lambda);
  %disp(sprintf('Minimal error=%f',J));
  testW(W(:,i),X,y);
  %m=mean(y==predict(W(:,i),X));  disp(sprintf('  accurancy=%f',m));
end

