function [r,c]=idx_ser22d(nr,idx)
  %serialized 2D index to two 2D index
  r=mod((idx-1),nr)+1;
  c=fix((idx-1)/nr)+1;
end
