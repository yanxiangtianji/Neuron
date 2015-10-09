function showMatWithSepper(rtm,sepper,crng='auto',withCountTick=false)
  %mat=rtm;mat(:,sepper(sepper>0))=NaN;
  if(!iscolumn(sepper)) sepper=sepper(:); end;
  if(sepper(1)!=0)  sepper=[0;sepper]; end;
  if(sepper(end)!=size(rtm,2))  sepper=[sepper;size(rtm,2)]; end;
  nRat=length(sepper)-1;
  newSepper=sepper+(0:nRat)';

  mat=zeros(size(rtm,1),size(rtm,2)+length(sepper)-2);
  for i=1:length(sepper)-1
    if(i!=1)
      mat(:,newSepper(i))=NaN;
    end
    mat(:,newSepper(i)+1:newSepper(i+1)-1)=rtm(:,sepper(i)+1:sepper(i+1));
  end
  imagesc(mat');colorbar;caxis(crng);
  xlabel('time');ylabel('neuron')

  t=[(newSepper(1:end-1)+newSepper(2:end))/2];
  if(withCountTick) t=[t;newSepper(2:end-1)-1]; end
  set(gca,'ytick',t);
  t=[num2cell(strcat('R-',num2str([1:nRat]','%-d')),2)];
  if(withCountTick) t=[t;num2cell(num2str(sepper(2:end-1)),2)]; end
  set(gca,'yticklabel',t);
end
