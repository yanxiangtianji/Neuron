function [ws,cr]=compactWC2quantile(ws,cr,quan)
  if(iscolumn(cr)==0) cr=reshape(cr,1,numel(cr)); end;
  quan=unique(quan(:)');
  [~,idx]=min(abs(quan-cr));
  ws=ws(idx);cr=cr(idx);
end
