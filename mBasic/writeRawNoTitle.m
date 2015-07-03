function writeRawNoTitle(data,fn)
%write data with no summarry (spikes of same neuron is on the same line)
if(iscell(fn)) fn=cell2mat(fn); end;
[fout,msg]=fopen(fn,'w');
if(fout<0)
  error(msg);
end;

n=length(data);
for i=1:n
  fprintf(fout,' %d',cell2mat(data(i)));
  fprintf(fout,'\r\n');
end
fclose(fin);

end
