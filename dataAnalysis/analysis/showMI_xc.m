function showMI_xc(type,mi,xPoints,nid,nCue)
  [nNeu,l]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoints and mi');  end;
  idx=[]; ticks=num2str([]);
  for i=1:nCue;for j=i+1:nCue;
    idx=[idx; i+nCue*(j-1)];
    ticks=[ticks; sprintf('%d-%d',i,j)];
  end;end;
  sort(idx);
  data=zeros(length(idx),l);
  for j=1:l;  data(:,j)=cell2mat(mi(nid,j))(idx); end;
  plot(xPoints,data);title(['N',num2str(nid),' X-cue ',type]);%ylabel(type);%legend(ticks)
end
