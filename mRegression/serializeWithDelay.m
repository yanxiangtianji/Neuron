function [time,class]=serializeWithDelay(rawData,idx,D=0)
%rData(idx) is not in returned result

n=length(rawData);
%prepare delay
delay=pickDelayVector(n,D,idx);
delay(idx)=0;

%basic serialize for all class
[time,class]=serialize(rawData);
%remove item of *idx* class, and add delay
[time,class]=modifySequence(time,class,idx,delay);

end


