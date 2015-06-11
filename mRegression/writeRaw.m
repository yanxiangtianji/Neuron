function writeRaw(data,fname)
%write data with summary of neuron id and number of spikes
if(iscell(fn)) fn=cell2mat(fn); end;
fout=fopen(fn,'w');
if(fout==-1)
  error(['cannot open file: ',fn]);
end;

n=length(data);
for i=1:n
  t=cell2mat(data(i));
  fprintf(fout,'%d %d\r\n',[i,length(t)]);
  fprintf(fout,' %d',t);
  fprintf(fout,'\r\n');
end
fclose(fin);

end
