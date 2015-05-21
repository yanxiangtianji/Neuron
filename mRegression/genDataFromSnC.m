function [X,y]=genDataFromSnC(n,seq0,cls0,D,idx,fRep=0)
%get data from raw sequence/class pair vector

%prepare delay
delay=pickDelayVector(n,D,idx);
delay(idx)=0;
%get data and reference sequence for *idx* from raw sequence
[seq,cls,ref]=modifySequence(seq0,cls0,idx,delay);
%generate data
%ref=seq0(find(cls0==refIdx));
[X,y]=genDataByRef(n,seq,cls,ref,fRep);
end
