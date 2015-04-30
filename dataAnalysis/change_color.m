res=function change_color(org_path,dst_path,org_mapping,dst_mapping)

p=imread(path);
n=size(p,1);
m=size(p,2);
l=length(org_mapping);
if l!=length(dst_mapping)
	display('Two color systems do not match in length!')
	return
end

pm=bitshift(uint32(p(:,:,1)),24)+bitshift(uint32(p(:,:,2)),16)+uint32(p(:,:,1));
om=bitshift(uint32(org_mapping(:,1)),24)+bitshift(uint32(org_mapping(:,2)),16)+uint32(org_mapping(:,1));

res=p;

for i=1:n, for j=1:m
	for k=1:l
		if pm(i,j)==om(k)
			res(i,j,:)=dst_mapping(k);
			i,j
			break
		end
	end
end,end

imwrite(res,dst_path);

end