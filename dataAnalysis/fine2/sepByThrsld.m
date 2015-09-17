function sepIds=sepByThrsld(values,thresholds)
%return number of values that are smaller than the thresholds
  if(!iscolumn(values)); values=values(:);end
  if(!isrow(thresholds)); thresholds=thresholds(:)';end
  sepIds=sum(values<thresholds);
end
