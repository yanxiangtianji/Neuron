function pc=pearson_corr(X,Y)
  if(!any(X) || !any(Y))
    pc=0;
  else
    pc=corr(X,Y);
  end
end
