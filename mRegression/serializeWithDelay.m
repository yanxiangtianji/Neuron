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
if(length(t)!=2)
  error(sprintf("Error dimension of D: %d",length(t)));
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

%basic serialize for all class
[time,class]=serialize(rawData);
%remove item of *idx* class, and add delay
[time,class]=modifySequence(time,class,idx,delay);

end


