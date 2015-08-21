function show_rt_xt_c(rt,nid,cid,xPoints,titlePrefix='')
  _show_rt_xt_kernel(rt(:,:,nid,cid),xPoints);
  title([titlePrefix,'cue-',num2str(cid),',neuron-',num2str(nid)])
end
