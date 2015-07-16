function showMI_xt_sample(type,mi,xPoints,cue_name,cue_trials,neuidx)
%figure for MI of one trial pairs on one cue
%cue_trials(1)->cueID, cue_trials(2)->trialFrom, cue_trials(3)->trialTo
  [nNeu,l,nCue]=size(mi);
  if(l!=length(xPoints)) error('Unmatched xPoints and mi');  end;
  if(length(cue_trials)<3)  error('Wrong coordinate size'); end;
  %make sure trial_id_source is small that trial_id_target (mi is symmetric)
  cue_trials([2,3])=sort(cue_trials([2,3]));
  if(length(neuidx)==1 && neuidx<=0) neuidx=1:nNeu; end;  %initialize neuidx if it is illegal
  cue_id=cue_trials(1);tid_s=cue_trials(2);tid_t=cue_trials(3);
  mi3=zeros(nNeu,length(xPoints));
  for i=1:nNeu;for j=1:l;
    mi3(i,j)=(cell2mat(mi(i,j,cue_id)))(tid_s,tid_t);
  end;end;
  mi3=max(mi3,0);
  global type;
  plot(xPoints,mi3(neuidx,:));ylabel(type);
  title([cell2mat(cue_name(cue_id)),': trial ',num2str(tid_s),'-',num2str(tid_t),' ',type,' on all neurons']);
  switch (type)
    case {'DP','PC'}
      ylim([0,1]);
    case 'MI'
      ylim([0,inf]);
  end
  %legend(num2str((1:nNeu)(neuidx)'));%legend(num2str((1:nNeu)(neuidx)'));
end
