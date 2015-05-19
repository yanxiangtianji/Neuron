function [time,class]=serializeWithDelay(rawData,idx,D=0)
%rData(idx) is not in returned result
%D is delay. When D is a vector, it is directly used.
%   When D is a matrix, its idx-th column is chosen.
%   When D is a scalar, it is extended into a vector of identical number. (Default with no delay)

time=[];
class=[];

n=length(rawData);
%prepare delay
t=size(D);
if(t!=2)
  error(sprintf("Error dimension of D: %d",t));
  return;
elseif(sum(t==[1,1])==2)
  delay=zeros(n,1)+D;
else
  t=sum(t==[n n]);
  if(t==2)
    delay=D(:,idx);
  elseif(t==1 && isvector(D))
    delay=D;
  else
    error(sprintf("Error size of matrix D unmatched: %d, %d",size(D)));
    return
  end
end
delay(idx)=0;

%init:
len=zeros(n,1);
cls=cell(n,1);
for i=1:n
  if(i==idx)
    rawData(i)=cell(1);
    %rawData(i)=[] will delete i-th item and move the rest backward
    continue;
  end
  v=cell2mat(rawData(i))+delay(i);
  l=length(v);
  len(i)=l;
  cls(i)=zeros(1,l)+i;
end

%merge:
inc=1;
while(inc<n)
  for i=1:inc*2:n-inc
    %disp([num2str(i) " : " num2str(i+inc)])
    [rawData(i),cls(i)]=_merge2(rawData(i),cls(i),rawData(i+inc),cls(i+inc));
  end
  inc*=2;
end

time=cell2mat(rawData(1));
class=cell2mat(cls(1));

end

%helper function
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


