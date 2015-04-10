function p = predict(W, X)
%m=size(X,1);
%n=size(X,2);
%size(W)==[n n];

p=sigmoid(X*W)>=0.5;

end
