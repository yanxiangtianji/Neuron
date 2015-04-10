function [data,count]=readRaw(fn)
data=cell();
count=1;

fin=fopen(fn,'r');
t=fscanf(fin,'%d',2);
while(size(t,1)!=0)
  id=t(1)+1;
  num=t(2);
  data(id)=fscanf(fin,'%d',num)';
  count+=1;
  t=fscanf(fin,'%d',2);
end
fclose(fin);
count-=1;

end

%cell2mat(c(1))