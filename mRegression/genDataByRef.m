function [X,y]=genDataByRef(n,seq,cls,ref,fRep=0)
%require: *ref* is not in *seq*

if(iscell(ref)) ref=cell2mat(ref);  end
m=length(seq);
nr=length(ref);
if(fRep==0)
  [X,y]=genDataByRef_count(m,n,nr,seq,cls,ref);
else
  [X,y]=genDataByRef_repolarize(m,n,nr,seq,cls,ref,fRep);
end

end

%for special case (repolarization factor is 0)
function [X,y]=genDataByRef_count(m,n,nr,seq,cls,ref)
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

%generalized case 
function [X,y]=genDataByRef_repolarize(m,n,nr,seq,cls,ref,fRep)
if(fRep<0)  fRep=-fRep; end;
X=zeros(m,n);
y=zeros(m,1);

p=1;
lastTime=seq(p);
for i=1:nr
  key=ref(i);
  t=zeros(1,n);
  while(p<=m && seq(p)<=key)
    %class=cls(p);
    %deltaTime=seq(p)-lastTime(class);
    %t(class)=t(class)*exp(-fRep*deltaTime)+1;
    t*=exp(-fRep*(seq(p)-lastTime));
    ++t(cls(p));
    X(p,:)=t;
    %y(p)=0;   %y is initialized with 0
    lastTime=seq(p);
    ++p;
  end
  if(p>1)
    X(p-1)*=exp(-fRep*(key-lastTime));
    y(p-1)=1;
  end
end

end
