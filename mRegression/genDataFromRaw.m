function [X,y]=genDataFromRaw(rData,D,idx)
n=length(rData);
[seq,cls]=mergeWithDelay(rData,idx,D);
[X,y]=genDataByRef(n,seq,cls,rData(idx));
end
