function maxTime=findMaxTime(rDataList)
  maxTime=0;
  [l1,l2]=size(rDataList);
  for i=1:l1;for j=1:l2;
    if(isempty(t=cell2mat(rDataList(i,j)))==0)
      maxTime=max(maxTime,t(end));
    end;
  end;end;
end
