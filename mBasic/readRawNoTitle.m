function [data,count]=readRawNoTitle(fn)
%read data with no summarry (spikes of same neuron is on the same line)
data=cell();
count=0;

if(iscell(fn))  fn=cell2mat(fn);  end;
[fin,msg]=fopen(fn,'r');
if(fin<0)
  error(msg);
end;

line=fgetl(fin);
while(ischar(line))
  data(++count)=str2num(line);
  line=fgetl(fin);
end
fclose(fin);

end

