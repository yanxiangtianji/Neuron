function cnt=getGpCount(gpTable)
  cnt=zeros(size(gpTable));
  n=numel(gpTable);
  for i=1:n
    cnt(i)=length(cell2mat(gpTable(i)));
  end
end
