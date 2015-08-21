function show_rt_xt_w_m(nid,cid,rate,ratez,rates,ratesz,xPoints,cueBinBeg,cueBinEnd)
  subplot(2,2,1);show_rt_xt_w(rate,nid,cid,xPoints,cueBinBeg,cueBinEnd,'rt: ')
  subplot(2,2,2);show_rt_xt_w(ratez,nid,cid,xPoints,cueBinBeg,cueBinEnd,'rtz: ')
  subplot(2,2,3);show_rt_xt_w(rates,nid,cid,xPoints,cueBinBeg,cueBinEnd,'rts: ')
  subplot(2,2,4);show_rt_xt_w(ratesz,nid,cid,xPoints,cueBinBeg,cueBinEnd,'rtsz: ')
end
