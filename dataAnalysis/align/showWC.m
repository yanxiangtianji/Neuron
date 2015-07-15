function showWC(ws,cr,timeUnit2ms,idx)
  if(length(idx)!=1)
    idx=idx_nd2ser(size(ws),idx);
  end
  plot(cell2mat(ws(idx))/timeUnit2ms,cell2mat(cr(idx)));
end
