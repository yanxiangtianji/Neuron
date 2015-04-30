function S=graph_silence(G,iter=0)

n=size(G,1);
if n!=size(G,2)
	display('G is not a squire matrix!')
	return
end

iG=inv(G);
I=eye(n);
Gm=G-I;
S=Gm;
S=(Gm+S*G.*I)*iG;

end

function d=D(n,a,b)
	d=zeros(n);
	for i=1:n
		d(i,i)=a(i,:)*b(:,i);
	end
end