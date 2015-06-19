% Marginal entropy (Shannon entropy of X)
function entropy = entropy(X)
%  if(len==0); len=max(X(:))+1; end;
%  count=zeros(len,1);
%  l=length(X(:));
%  for i=1:l
%    ++count(X(i)+1);
% end
  [~,~,j]=unique(X,'rows');
  count=accumarray(j,1);
  entropy=entropy_on_count(count);
end
