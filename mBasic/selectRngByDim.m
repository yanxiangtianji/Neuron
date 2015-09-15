function y=selectRngByDim(x,rng,dim=1)
%return matrix whose DIM dimension only have the entries within RNG (other 
% dimensions are not affected.)
%e.g. t=reshape(1:24,3,4,2)
% selectRngByDim(t,2:3,2)
% ans(:,:,1) =[ 4  7;  5  8; 6  9]
% ans(:,:,2) =[16 19; 17 20;18 21]
 
  sz=size(x);
  n=ndims(x);
  pBef=prod(sz(1:dim-1));
  pAt=pBef*sz(dim);
  pAft=prod(sz(dim+1:end));
  
  if(length(rng)==rng(end)-rng(1))
    id1=(1+pBef*rng(1)-pBef):pBef*rng(end);
  else
    id0=1:pBef;
    id1=id0'+pBef*(rng(:)-1)';  id1=id1(:)';
  end
  idx=id1'+pAt*(0:pAft-1);
  sz(dim)=length(rng);
  y=reshape(x(idx),sz);
end
