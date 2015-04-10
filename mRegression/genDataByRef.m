function [X,y]=genDataByRef(n,seq,cls,ref)
if(iscell(ref)) ref=cell2mat(ref);  end
m=length(seq);
nr=length(ref);
X=zeros(m,n);
y=zeros(m,1);

p=1;
for i=1:nr
  key=ref(i);
  t=zeros(1,n);
  while(p<=m && seq(p)<=key)
    ++t(cls(p));
    X(p,:)=t;
    %y(p)=0;   %y is initialized with 0
    ++p;
  end
  if(p>1)
    y(p-1)=1;
  end
end

%if(p!=m)
%  X=X(1:p-1,:);
%  y=y(1:p-1);
%end

end
