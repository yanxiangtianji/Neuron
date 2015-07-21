function showSC_xc_errorbar(nid,sc_m,sc_s,cue_name,stdScale,binSizeInMS)
  [resLength,~,nCue]=size(sc_m);
  for i=1:nCue;
    %errorbar
    subplot(nCue,1,i);errorbar(1:resLength,sc_m(:,nid,i),sc_s(:,nid,i)*stdScale);
    %global mean
    line([0,resLength],mean(sc_m(:,nid,i)),'color','r');
    %decorate
    xlim([0 resLength]);ylabel({cell2mat(cue_name(i)),'spk/s'});
    if(i==1)
      title(['N',num2str(nid),' : ',num2str(binSizeInMS),'ms']);
    end;
  end;
end
