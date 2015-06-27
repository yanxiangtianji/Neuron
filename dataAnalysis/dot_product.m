function dp=dot_product(X,Y)
  dp=sum(xor(X(:),Y(:)))/length(X(:));
  %in octave xor: 1,2,3,... are treated the same as 1.
end
