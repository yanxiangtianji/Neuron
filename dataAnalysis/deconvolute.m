function M_dir=deconvolute(M_org,beta)
%should be: 0<beta<1

n=size(M_org,1)
%scaling:
[U,V]=eig(M_org);
eigen=diag(V);
pmost=max(eigen);
nmost=min(eigen);
if pmost<0
	alpha=-beta/(1+beta)*nmost;
else if nmost>0
	alpha=beta/(1-beta)*pmost;
else
	alpha=min(beta/(1-beta)*pmost,-beta/(1+beta)*nmost);
end
%should be: 0<alpha<1
alpha
%rebuild:
D=V;
for i=1:n
	D(i,i)=eigen(i)/(1/alpha+eigen(i));
end
M_dir=U*D*inv(U);

end