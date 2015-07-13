function showWC(ws,cr,timeUnit2ms,idx)
  if(length(idx)>ndims(ws))
    error(sprintf('idx is higher dimension than ws (%d>%d)',length(idx),ndims(ws)))
  else if(length(idx)!=1)
    idx=idx(:)';
    %if length(idx)<ndims(ws), add 1s to the end of idx
    for i=length(idx)+1:ndims(ws);
      idx=[idx(:)',1];
    end;
    s=size(ws);s=cumprod(s);
    idx=sum(s(1:end-1).*(idx(2:end)-1))+idx(1);
  end
  plot(cell2mat(ws(idx))/timeUnit2ms,cell2mat(cr(idx)));
end
