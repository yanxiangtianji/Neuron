function data=pickDataByTime(rData,s_time,e_time)
n=length(rData(:));
data=cell(size(rData));

for i=1:n
  m=cell2mat(rData(i));
  data(i)=m(m>=s_time & m<e_time);
end

end
