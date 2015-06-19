function result=discretize(value,binSize=1,offset=0,resLength=0)

if(iscell(value)) value=cell2mat(value)(:); end

value=ceil((value-offset)./binSize);
[idx,~,j]=unique(value(:)); %make idx and j to be column vectors
if(resLength!=0 && idx(end)>resLength)
  maxIDX=min(find(idx>resLength))-1;
  idx=idx(range);
else
  maxIDX=length(idx);
end
count=accumarray(j,1);

if(idx(1)==0)
  rng=[2:maxIDX];
else
  rng=[1:maxIDX];
end

result=zeros(resLength,1);
result(idx(rng))=count(rng);

end
