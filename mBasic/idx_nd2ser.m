function idx=idx_nd2ser(s,ndIdx)
  if(length(ndIdx)>length(s))
    error(sprintf('idx has higher dimension (%d>%d)',length(ndIdx),length(s)))
  elseif(sum(ndIdx>s(1:length(ndIdx)))!=0)
    error('value(s) of some dimension(s) of idx is(are) large than size');
  end
  ndIdx=ndIdx(:)';
  %if length(ndIdx)<length(s), add 1s to the end of idx
  for i=length(ndIdx)+1:length(s);
    ndIdx=[ndIdx(:)',1];
  end;
  s=cumprod(s);
  idx=sum(s(1:end-1).*(ndIdx(2:end)-1))+ndIdx(1);
end
