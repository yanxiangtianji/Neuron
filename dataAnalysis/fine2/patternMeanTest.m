function [pval,pval_min,pval_mean]=patternMeanTest(x,mu,smr)
%return the probility of getting a worst case than x.
%assume noise follows Gaussian(mu,smr*mu)
%smr: sigma-mu ratio

if(!all(size(x)==size(mu)))
  if(isvector(x) && isvector(mu) && numel(x)==numel(mu))
    mu=reshape(mu,size(x));
  else
    error('Unmatched size for X and MU');
  end
end
if(!isscalar(smr))
  error('SMR should be a scalar.')
end
s=mu*smr;
t=2*normcdf(x,mu,s);
idx=(t>1);
t(idx)=2-t(idx);
pval=1-prod(1-t(t!=1));
pval_min=prod(t);
pval_mean=mean(t);

end
