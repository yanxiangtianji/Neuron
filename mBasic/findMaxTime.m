function maxTime=findMaxTime(rDataList)
  maxTime=0;
  l=length(rDataList(:));
  for i=1:l;
    if(isempty(t=cell2mat(rDataList(i)))==0)
      maxTime=max(maxTime,t(end));
    end;
  end;
end
