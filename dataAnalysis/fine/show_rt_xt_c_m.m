function show_rt_xt_c_m(nid,cid,rt,rtz,rts,rtsz,xPoints)
  subplot(2,2,1);show_rt_xt_c(rt,nid,cid,  xPoints,'rt: ')
  subplot(2,2,2);show_rt_xt_c(rtz,nid,cid, xPoints,'rtz: ')
  subplot(2,2,3);show_rt_xt_c(rts,nid,cid, xPoints,'rts: ')
  subplot(2,2,4);show_rt_xt_c(rtsz,nid,cid,xPoints,'rtsz: ')
end
