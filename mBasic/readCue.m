function data=readCue(fn)
data=[];

if(iscell(fn)) fn=cell2mat(fn); end;
[fin,msg]=fopen(fn,'r');
if(fin<0)
  error(msg);
end;

t=fscanf(fin,'%f',4);
while(!feof(fin))
  data=[data;t'];
  t=fscanf(fin,'%f',4);
end
fclose(fin);

end
