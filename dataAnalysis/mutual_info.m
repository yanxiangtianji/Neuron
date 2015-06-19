% Mutual information between X & Y
function m = mutual_info(X,Y)
  m = entropy(X) + entropy(Y) - entropy_joint(X,Y);
end

