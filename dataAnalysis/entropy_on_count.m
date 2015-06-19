% calculate entropy by count information
% require: count in a nonzero vector.
function ent=entropy_on_count(count)
% optimization: sum(pi*log2(pi))=sum(ci/s*log2(ci/s))=sum(ci*log2(ci))/s-log2(s)
%  count=count(find(count!=0)); %avoid log2(0)
  s=sum(count);
  ent=-sum(count.*log2(count))/s+log2(s);
end
