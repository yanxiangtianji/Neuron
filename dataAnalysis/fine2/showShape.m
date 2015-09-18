function showShape(rtm,nid,rlnId, nTick,tickBeg,tickEnd, dashThre=0,meanSepper)
  _color='krgbmc';
  nBin=size(rtm,1);
  
  cid=mod(rlnId(1),length(_color));
  if(cid==0) cid=length(_color); end
  
  dash='';
  if(mean(rtm(:,nid))<dashThre) dash='--'; end
  
  plot(rtm(:,nid),[_color(cid),dash]);
  
  if(exist('meanSepper','var'))
    meanSepper=[0;meanSepper(:);nBin];
    m=zeros(size(rtm,1),1);
    for i=1:length(meanSepper)-1;
      rng=meanSepper(i)+1:meanSepper(i+1); m(rng)=mean(rtm(rng,nid));
    end
    c=_color(cid);
    if(c!='k');  c='k';
    else; c='r';  end;
    hold on;
    plot(m,[c,'--']);
    hold off;
  end
  
  setTimeX(nBin,nTick,tickBeg,tickEnd)
  title(sprintf('N%d (R%d-N%d)',nid,rlnId(1),rlnId(2)))
end
