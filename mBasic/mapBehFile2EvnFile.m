function map=mapBehFile2EvnFile(fnl_b,fnl_e)
map=zeros(size(fnl_b));
for i=1:numel(fnl_b)
  fn=cell2mat(fnl_b(i));
  b=max(index(fn,'/'),index(fn,'\'))+1;
  e=index(fn,'-beh')-1;
  mat=strfind(fnl_e,fn(b:e));
  for j=1:numel(fnl_e)
    if(!isempty(cell2mat(mat(j))))
      map(i)=j;break;
    end
  end
end

end
