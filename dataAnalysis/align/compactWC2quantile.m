function [ws,cr]=compactWC2quantile(ws,cr,quan,mode='near')
  %mode can be 'near' or 'linear'
  %'near':  select neareast cr for each quan
  %'linear':  linear interpolatie cr and ws to exactly meet the input quan
  if(iscell(ws))  ws=cell2mat(ws);  end;
  if(iscell(cr))  cr=cell2mat(cr);  end;
  if(iscolumn(cr)==0) cr=reshape(cr,numel(cr),1); end;
  quan=unique(quan(:)');
  if(strcmp(mode,'near'))
    [~,idx]=min(abs(quan-cr));%bsxfun(@minus,quan,cr)
    ws=ws(idx);cr=cr(idx);
  elseif(strcmp(mode,'linear'))
    [~,idx]=min(abs(quan-cr));
    t=cr(idx)'-quan;
    idx2=idx+(t>0)-(t<0);
    idx2=min(max(idx2,1),length(cr));
    ws=(ws(idx)+ws(idx2))/2;cr=cr(idx);
  end
end
