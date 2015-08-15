function writeCue(cue,fn)

if(iscell(fn)) fn=cell2mat(fn); end;
[fout,msg]=fopen(fn,'w');
if(fout<0)
  error(msg);
end;

n=length(cue);
for i=1:n
  t=cue(i,:);
  fprintf(fout,' %d',t);
  fprintf(fout,'\r\n');
end
fclose(fout);

end
