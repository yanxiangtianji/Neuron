function [mr,mc]=show_xt(info,more=0)
  %of one cue
  [nTri,~,nNeu]=size(info);
  vld_idx=find(triu(ones(nTri),1));
  temp=zeros(nTri*(nTri-1)/2,nNeu);
  for nid=1:nNeu;  temp(:,nid)=info(:,:,nid)(vld_idx);  end;
  mr=mean(temp); mc=mean(temp');
  if(more!=0)
    subplot(2,2,1);h=barh(mr);set(get(h,'Parent'),'xdir','reverse','ydir','reverse');
    ylim([1 length(mr)]);set(gca,'ytick',0:ceil(length(mr)/5):length(mr));
    subplot(2,2,4);bar(mc);xlim([1 length(mc)]);
    set(gca,'xtick',0:ceil(length(mc)/5):length(mc));
    subplot(2,2,2);
  end;
  imagesc(temp');colorbar;caxis([-1 1]);xlabel('trial-pair');ylabel('neuron');
end
