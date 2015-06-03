function [X,y]=genDataFromRaw(rData,D,idx,fRep=0)
n=length(rData);
[seq,cls]=serializeWithModify(rData,idx,D);
[X,y]=genDataByRef(n,seq,cls,rData(idx),fRep);
end
