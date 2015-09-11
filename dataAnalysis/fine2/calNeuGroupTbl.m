function tbl=calNeuGroupTbl(nRat,sep,idx,neuAgg)
  tbl=cell(nRat,3);
  for i=1:nRat
    t=(neuAgg(i)+1):neuAgg(i+1);
    for j=1:length(sep)-1;%e.g. 1:negative, 2:nothing, 3:positive
      tbl(i,j)=intersect(t,idx(sep(j)+1:sep(j+1)));
    end
  end
end
