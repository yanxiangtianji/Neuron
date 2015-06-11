function writeRawNoTitle(data,fname)
%write data with no summarry (spikes of same neuron is on the same line)
if(iscell(fn)) fn=cell2mat(fn); end;
fout=fopen(fn,'w');
if(fout==-1)
  error(['cannot open file: ',fn]);
end;

n=length(data);
for i=1:n
  fprintf(fout,' %d',cell2mat(data(i)));
  fprintf(fout,'\r\n');
end
fclose(fin);

end
