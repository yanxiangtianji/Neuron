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
