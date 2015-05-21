function [time,neuron]=serializeWithModify(rawData,idx,D=0)
%rData(idx) is not in returned result

n=length(rawData);
%prepare delay
delay=pickDelayVector(n,D,idx);
delay(idx)=0;

%basic serialize for all neuron
[time,neuron]=serialize(rawData);
%remove item of *idx* neuron, and add delay
[time,neuron]=modifySequence(time,neuron,idx,delay);

end


