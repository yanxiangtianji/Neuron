function [overallAcc,nValid,avgValidAcc,avgNonValidAcc]=descAccMat(accMat,thr=0.5)
%accMat:    one trail for each row, same neuron on the same column
%thr:   threshold for determining valid

n=size(accMat,2);
overallAcc=mean(accMat,2);
t=accMat>=thr;
nValid=sum(t,2);
avgValidAcc=sum(accMat.*t,2)./nValid;
avgNonValidAcc=sum(accMat.*(1-t),2)./(n-nValid);

end
