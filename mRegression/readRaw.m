function [data,count]=readRaw(fn)
%read data with summary of neuron id and number of spikes
data=cell();
count=0;

if(iscell(fn)) fn=cell2mat(fn); end;
[fin,msg]=fopen(fn,'r');
if(fin<0)
  error(msg);
end;

t=fscanf(fin,'%d',2);
while(size(t,1)!=0)
  id=t(1)+1;
  num=t(2);
  data(id)=fscanf(fin,'%d',num)';
  ++count;
  t=fscanf(fin,'%d',2);
end
fclose(fin);

end
