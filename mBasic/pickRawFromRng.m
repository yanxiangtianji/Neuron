function res=pickRawFromRng(data,start_t,end_t,isNormalize=false)
  off=0;
  if(isNormalize) off=start_t; end;
  res=cell(size(data));
  for i=1:numel(data)
    t=cell2mat(data(i));
    res(i)=t(find(t>start_t & t<=end_t))-off;
  end
end
