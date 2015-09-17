function tbl=calNeuGroupTbl(nNeuList,idx,sepper)
  nRat=length(nNeuList);
  nSep=length(sepper)+1;
  tbl=cell(nRat,nSep);
  nNeuSum=[0;cumsum(nNeuList)(:)];
  sepper=[0;sepper(:);length(idx)];
  for i=1:nRat
    t=(nNeuSum(i)+1):nNeuSum(i+1);
    for j=1:nSep;%e.g. 1:negative, 2:nothing, 3:positive
      tbl(i,j)=intersect(t,idx(sepper(j)+1:sepper(j+1)));
    end
  end
end
