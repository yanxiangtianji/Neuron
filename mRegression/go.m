fn_spike='../data/all.txt';
fn_processed='../data/all.txt';

rData=readRawSpike(fn_spike);   dMin=0.0001;    dUnit=0.0001;
%rData=readRaw(fn_processed);   dMin=1; dUnit=1;
n=length(rData);

W=rand(n,n);
D=initDelay(n,dMin,dUnit,'pl');
for idx=1:n
  [seq,cls]=mergeWithDelay(rData,idx,D);
  [X,y]=genData(n,seq,cls,rData(idx));
  [W(:,i),D(:,i)]=train(n,X,y,W(:,i),D(:,i));
end

