function res=pick(mat,i,j)

l=length(mat);
res=zeros(1,l);
for k=1:l
	res(k)=cell2mat(mat(k))(i,j);
end

end