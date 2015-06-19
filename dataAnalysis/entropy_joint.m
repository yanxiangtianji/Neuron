% Joint entropy for X & Y, they may have different length
function jentropy = entropy_joint(X,Y)
%  Mx=max(X);
%  My=max(Y);
%  count=zeros(Mx+1,My+1);
%  for i = 1:length(X)
%    ++count(X(i)+1,Y(i)+1);
%  end
  lx=length(X(:)); ly=length(Y(:));
  if(lx==ly)
    [~,~,j]=unique([X(:),Y(:)],'rows');
  elseif(lx<ly)
    m=max(X(:))+1;
    [~,~,j]=unique([[X(:);zeros(ly-lx,1)+m], Y(:)],'rows');
  else
    m=max(Y(:))+1;
    [~,~,j]=unique([X(:), [Y(:);zeros(lx-ly,1)+m]],'rows');
  end
  count=accumarray(j,1);
  jentropy=entropy_on_count(count(:));
end

