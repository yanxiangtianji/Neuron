function mat=al2mat(fn)

fin=fopen(fn,'r');
n=uint32(fscanf(fin,'%d',1));
mat=double(zeros(n,n));
for i=1:n
	id=uint32(fscanf(fin,'%d',1))+1;
	m=uint32(fscanf(fin,'%d',1));
	t=uint32(fscanf(fin,'%d',m))+1;
	mat(id,t)=1;
end
fclose(fin);

end
