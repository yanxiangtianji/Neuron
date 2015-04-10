function [time,class]=mergeWithDelay(rawData,idx,D)

time=[];
class=[];

n=size(rawData,1);
%prepare
t=sum(size(D)==[n n]);
if(t==2)
  delay=D(:,idx);
elseif(t==1 && isvector(D))
  delay=D;
else
  error("Error dimension of D");
  return
end
delay(idx)=0;

%init:
len=zeros(n,1);
cls=cell(n,1);
for i=1:n
  if(i==idx)
    disp('equal')
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
