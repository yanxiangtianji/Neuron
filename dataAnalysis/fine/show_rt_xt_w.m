function show_rt_xt_w(rate,nid,cid,xPoints,cueBinBeg,cueBinEnd,titlePrefix='')
  nTri=size(cueBinBeg,1);
  rt=cutRateData2Trial(rate,cueBinBeg,cueBinEnd,1:nTri,nid,cid);
  _show_rt_xt_kernel(rt,xPoints);
  title([titlePrefix,'cue-',num2str(cid),',neuron-',num2str(nid)])
end
