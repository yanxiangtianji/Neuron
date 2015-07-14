function [ws,cr]=compactWC2quantile(ws,cr,quan,mode='near')
  %mode can be 'near' or 'linear'
  %'near':  select neareast cr for each quan
  %'linear':  linear interpolatie cr and ws to exactly meet the input quan
  if(iscell(ws))  ws=cell2mat(ws);  end;
  if(iscell(cr))  cr=cell2mat(cr);  end;
  quan=unique(quan(:)');  %row vector
  if(strcmp(mode,'near'))
    [~,idx]=min(abs(quan-cr(:)));%bsxfun(@minus,quan,cr)
    ws=ws(idx);cr=cr(idx);
  elseif(strcmp(mode,'linear'))
    [~,idx]=min(abs(quan-cr(:)),[],1);
    idx=idx';%ensure ws(idx) is a column vector, when ws is a scalar
    t=(quan-cr(idx)(:)')';%column vector
    idx2=idx+(t>0)-(t<0);
    idx2=min(max(idx2,1),length(ws));
    if(iscolumn(ws)==0)  ws=ws(:);  end;
    if(iscolumn(cr)==0)  cr=cr(:);  end;
    x=(ws(idx2)-ws(idx))./(cr(idx2)-cr(idx)).*t;
    ws=ws(idx);ws(find(isnan(x)==0))+=x(find(isnan(x)==0));
    cr=cr(idx);
  end
end
