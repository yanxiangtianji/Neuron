function [ridNlnid]=mapGNId2Local(gnid,nNeuList)
%given Global Neuron id, and number of neurons for each rat
%return Rat id and Local Neuron id
n=numel(gnid);
rId=zeros(n,1);
lnId=zeros(n,1);
for i=1:n
  [rId(i),lnId(i)]=mapOne(gnid(i),nNeuList);
end
ridNlnid=[rId,lnId];

end

function [rId,lnId]=mapOne(gnid,nNeuList)
  rId=1;
  lnId=0;
  while(gnid>nNeuList(rId))
    gnid-=nNeuList(rId);
    rId+=1;
  end
  lnId=gnid;
end
