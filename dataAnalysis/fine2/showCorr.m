function showCorr(cor,nids)
  imagesc(cor);colorbar;caxis([-1 1]);
  if(nargin<2)  return;  end;
  set(gca,'xtick',1:length(nids));set(gca,'ytick',1:length(nids));
  set(gca,'xticklabel',num2str(nids(:)));set(gca,'yticklabel',num2str(nids(:)));
end
