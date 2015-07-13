function ndIdx=idx_ser2nd(s,idx)
  %serialized nD index to a nD index
  ndIdx=zeros(1,length(s));
  --idx;
  for i=1:length(s)
    ndIdx(i)=mod(idx,s(i))+1;
    idx=fix(idx/s(i));
  end;
end
