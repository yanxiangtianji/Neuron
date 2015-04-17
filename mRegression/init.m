function [D,A,W]=init(n,dMin,dUnit)
  D=initDelay(n,dMin,dUnit,'pl');
  A=initAdjacency(n);
  W=initWeight(n);
end
