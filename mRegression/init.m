function [D,A,W]=init(n,dUnit,dMean,dMin)
  D=initDelay(n,'pl',dUnit,dMean,dMin);
  A=initAdjacency(n);
  W=initWeight(n);
end
