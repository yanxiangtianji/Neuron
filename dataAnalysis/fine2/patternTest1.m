function pval=patternTest1(x,sepPer,smr)
%Pattern: different normal levels + overshot

mrest=mean(x(1:sepPer(1)));
movst=x(sepPer(1)+1:sepPer(2));
mcond=mean(x(sepPer(2):end));
m=zeros(size(x));
m(1:sepPer(1))=mrest;
m(sepPer(1)+1:sepPer(2))=movst;
m(sepPer(2):end)=mcond;

[pval,pval_min,pval_mean]=patternMeanTest(x,m,smr);

%phase difference: P(mrest>movst)
p2=1;


end
