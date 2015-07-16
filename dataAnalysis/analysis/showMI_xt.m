function showMI_xt(type,mi,xPoints,cue_name,xlbl)
%figure for mean MI over all trial-pairs of same cue
  [nNeu,l,nCue]=size(mi);
  if(length(mi)!=0) nTri=length(cell2mat(mi(1))); else return; end;%nTri
  if(length(xPoints)!=l)  error('Unmatched xPoints and mi');  end;
  if(length(cue_name)!=nCue)  error('Unmatched cue_name length and mi');  end;
  mi2=zeros(size(mi));
  for i=1:prod(size(mi)); mi2(i)=sum(sum(cell2mat(mi(i)))); end;
  mi2/=(nTri-1)*nTri/2;
  for cue_id=1:nCue;
    subplot(2,2,cue_id);plot(xPoints,mi2(:,:,cue_id));
    xlabel(xlbl);ylabel(['mean ',type,' on trial-pairs']);
    title([cell2mat(cue_name(cue_id)),': X-trial ',type,' on all neurons']);
    %legend(num2str((1:nNeu)'));
  end;
end
