function z=baselineZscore(x,rngBL,dim=1)
  y=selectRngByDim(x,rngBL,dim);
  mu = mean (y, dim);
  %sigma = std (x, 0, dim);
  sigma = std (y, 0, dim);
  s = sigma;
  s(s==0) = 1;
  z = bsxfun (@rdivide, bsxfun (@minus, x, mu), s);
end
