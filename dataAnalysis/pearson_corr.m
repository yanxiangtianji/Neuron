function pc=pearson_corr(X,Y)
  if(length(X)!=length(Y)) error('X and Y must have the same number of elements'); end
  s1=std(X);s2=std(Y);
  if(isempty(X) || isempty(Y) || s1==0 || s2==0)
    pc=0;
  else
    pc=cov(X,Y)/s1/s2;
  end
end
