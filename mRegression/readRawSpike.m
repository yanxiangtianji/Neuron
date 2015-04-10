function [data,count]=readRawSpike(fn)
data=cell();
count=1;

fin=fopen(fn,'r');
line=fgetl(fin);
while(ischar(line))
  data(count)=str2num(line);
  count+=1;
  line=fgetl(fin);
end
fclose(fin);
count-=1;

end

%cell2mat(c(1))