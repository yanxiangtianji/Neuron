function writeRaw(data,fn)
%write data with summary of neuron id and number of spikes
if(iscell(fn)) fn=cell2mat(fn); end;
[fout,msg]=fopen(fn,'w');
if(fout<0)
  error(msg);
end;

n=length(data);
for i=1:n
  t=cell2mat(data(i));
  fprintf(fout,'%d %d\r\n',[i-1,length(t)]);
  fprintf(fout,' %d',t);
  fprintf(fout,'\r\n');
end
fclose(fout);

end
