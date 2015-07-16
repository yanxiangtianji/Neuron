function showMI_xt_neuron(type,mi,xPoints,cue_name,nid,cid,mode='bunch',mode_arg=299)
  %mode can be 'bunch' or 'error-bar'
  [nNeu,l,nCue]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoints and mi');  end;
  nTri=length(cell2mat(mi(1)));
  idx=find(triu(ones(nTri),1)); %length(idx)=nTri*(nTri-1)/2;
  mi4=zeros(length(idx),length(xPoints));
  for wid=1:l;
    mi4(:,wid)=cell2mat(mi(nid,wid,cid))(idx);
  end;
  mi4=max(mi4,0);
  if(strcmp(mode,'bunch'))
    if(mode_arg<=0 || mode_arg>=length(idx))
      plot(xPoints,mi4,xPoints,mean(mi4,1),'linewidth',4);
    else
      idx=randi(length(idx),mode_arg,1);
      plot(xPoints,mi4(idx,:),xPoints,mean(mi4,1),'linewidth',4,'g');
    end
  else %error-bar
    m=mean(mi4);s=std(mi4);
    errorbar(xPoints,m,min(s,m),s);
  end
  switch(type)
    case {'DP','PC'}
      ylim([0,1]);
    case 'MI'
      ylim([0,inf]);
  end
  ylabel(type);
  %title([cell2mat(cue_name(cid)),': Neuron ',num2str(nid),' ',type,' on all trial pairs']);
  title([cell2mat(cue_name(cid)),': Neuron ',num2str(nid),' ',type]);
end
