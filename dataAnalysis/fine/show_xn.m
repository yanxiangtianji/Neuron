function [mr,mc]=show_xn(info,more=0)
  [nNeu,~,nTri]=size(info);
  vld_idx=find(triu(ones(nNeu),1));
  temp=zeros(nNeu*(nNeu-1)/2,nNeu);
  for tid=1:nTri;  temp(:,tid)=info(:,:,tid)(vld_idx);  end;
  mr=mean(temp); mc=mean(temp');
  if(more!=0)
    subplot(2,2,1);h=barh(mr);set(get(h,'Parent'),'xdir','reverse','ydir','reverse');
    ylim([1 length(mr)]);set(gca,'ytick',0:ceil(length(mr)/5):length(mr));
    subplot(2,2,4);bar(mc);xlim([1 length(mc)]);
    set(gca,'xtick',0:ceil(length(mc)/5):length(mc));
    subplot(2,2,2);
  end;
  imagesc(temp');colorbar;caxis([-1 1]);xlabel('neuron-pair');ylabel('trial');
end
