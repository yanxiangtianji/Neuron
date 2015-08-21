function _show_rt_xt_kernel(rt,xPoints)
  [vecLength,nTri]=size(rt);
  imagesc(rt');colorbar;ylabel('trial');xlabel('time');
  l=length(xPoints);
  set(gca,'xtick',(0:l-1)*vecLength/max(1,l-1));set(gca,'xticklabel',xPoints);
end
