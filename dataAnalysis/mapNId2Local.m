function [rId,lnId]=mapNId2Local(gnid,nNeuList)
%given Global Neuron id, and number of neurons for each rat
%return Rat id and Local Neuron id
rId=1;
lnId=0;
while(gnid>nNeuList(rId))
  gnid-=nNeuList(rId);
  rId+=1;
end
lnId=gnid;

end
