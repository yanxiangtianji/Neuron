function show_single(rng,info,x,e,type='DP')
  plot(rng,info,'-*',[x x+e],0,'rh','linewidth',5);set(gca,'xtick',0:0.1:1);grid;
  xValues=[x x+e x+e x];yValues=[0 0 1 1];
  if(strcmp(type,'DP'))
    line([0 0.5],[0 1],'linestyle','--','color','r');
    patch([0 e e],[0 0 e*2],'g');
    i=1;while(x/i>=e) patch(xValues/i,min(1,yValues*2.*xValues/i),'y'); ++i; end;
  else  %MI
    line([0 0.5],[0 1],'linestyle','--','color','r');
    patch([0 e e],[0 0 e*2],'g');
    i=1;while(x/i>=e) patch(xValues/i,yValues,'y'); ++i; end;
  end
  xlabel('window size');ylabel(type);
end
