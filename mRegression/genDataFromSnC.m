function genDataFromSnC(seq0,cls0,D,idx,ref,fRep=0)


n=length(D);
[seq,cls]=modifySequence(seq0,cls0,idx,D);
[X,y]=genDataByRef(n,seq,cls,ref,fRep);
end
