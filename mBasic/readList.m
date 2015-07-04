function rData=readList(flist)
  if(length(flist)==0); return; end;
  t=readRaw(flist(1));
  rData=cell(length(flist),length(t));
  rData(1,:)=t;
  for i=2:length(flist)
    rData(i,:)=readRaw(flist(i));
  end
end
