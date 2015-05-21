function delay=pickDelayVector(n,D=0,idx=0)
%When *D* is a vector, it is directly used.
%When *D* is a matrix, its *idx*-th column is chosen. (*idx* neednot be valid in other cases)
%When *D* is a scalar, it is extended into a vector of identical number. (Default with no delay)

t=size(D);
if(length(t)!=2)    %high demension
  error(sprintf("Too high dimension of D: %d.",length(t)));
  return;
elseif(sum(t==[1,1])==2)    %scalar
  delay=zeros(n,1)+D;
else
  t=sum(t==[n n]);
  if(t==2)  %matrix (right size)
    if(!isindex(idx))
      error(sprintf("Input Delay is a valid matrix, \
but no valid index is inputted (default=0, current=%s).",num2str(idx)));
      return
    end
    delay=D(:,idx);
  elseif(t==1 && isvector(D))   %vector (right size)
    delay=D;
  else  %wrong size
    error(sprintf("Error size of matrix D unmatched: %d, %d.",size(D)));
    return
  end
end

end
