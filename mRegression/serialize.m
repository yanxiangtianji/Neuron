function [value,class]=serialize(rawData)
%input parameter *rawData* is a cell vector. Each cell, represents a class, is a row vector.
%return one row vector of sorted values,
%   together with non-negative number indicating each one's original class.

if(nargout<2)   %special case for returning values only
  if(size(rawData,1)==1)    %row vector
    value=sort(cell2mat(rawData));
  else  %colomn vector
    value=sort(cell2mat(rawData'));
  end
  return;
end

n=length(rawData);

value=[];
class=[];
len=zeros(1,n);
%simple serialize with out sort and class, store length for each class
t=0;
for i=1:n
  v=cell2mat(rawData(i));
  if(size(v,1)!=1)  %make sure v is a row vector
    v=v';
  end;
  len(i)=length(v);
  value=[value,v];
  t+=len(i);
end

%sort
[value,class]=sort(value);
%class
t=0;
for i=1:n
  class(find(class>t & class<=t+len(i) ))=i;
  t+=len(i);
end

return;

%depreciatied method(Divide and Conquer of merge2):
len=zeros(n,1);
cls=cell(n,1);
for i=1:n
  l=length(cell2mat(rawData(i)));
  len(i)=l;
  cls(i)=zeros(1,l)+i;
end

[value,class]=mergeDnC(n,rawData,cls);

end

%helper functions:
function [value,class]=mergeDnC(n,rawData,cls)
  inc=1;
  while(inc<n)
    for i=1:inc*2:n-inc
      %disp([num2str(i) " : " num2str(i+inc)])
      [rawData(i),cls(i)]=_merge2(rawData(i),cls(i),rawData(i+inc),cls(i+inc));
    end
    inc*=2;
  end

  value=cell2mat(rawData(1))';
  class=cell2mat(cls(1))';
end

function [vec,cls]=_merge2(vec1,cls1,vec2,cls2)
  if(iscell(vec1))    vec1=cell2mat(vec1);    end
  if(iscell(cls1))    cls1=cell2mat(cls1);    end
  if(iscell(vec2))    vec2=cell2mat(vec2);    end
  if(iscell(cls2))    cls2=cell2mat(cls2);    end

  n=length(vec1);
  m=length(vec2);
  vec=zeros(1,n+m);
  cls=zeros(1,n+m);

  i=1;j=1;p=1;
  while(i<=n && j<=m)
    if(vec1(i)<=vec2(j))
      vec(p)=vec1(i);
      cls(p)=cls1(i);
      ++i;
    else
      vec(p)=vec2(j);
      cls(p)=cls2(j);
      ++j;
    end
    ++p;
  end

  if(i<=n)
    vec(p:end)=vec1(i:end);
    cls(p:end)=cls1(i:end);
  end
  if(j<=m)
    vec(p:end)=vec2(j:end);
    cls(p:end)=cls2(j:end);
  end
  
end


