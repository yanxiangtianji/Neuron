function tbl=calNeuGroupTbl(nRat,idx,sepper,nNeuList)
  nSep=length(sepper)+2;
  tbl=cell(nRat,nSep);
  neuSum=[0;cumsum(nNeuList)(:)];
  sepper=[0;sepper(:);length(idx)];
  for i=1:nRat
    t=(neuSum(i)+1):neuSum(i+1);
    for j=1:nSep-1;%e.g. 1:negative, 2:nothing, 3:positive
      tbl(i,j)=intersect(t,idx(sepper(j)+1:sepper(j+1)));
    end
  end
end
