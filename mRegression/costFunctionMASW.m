function [J, grad] = costFunctionMASW(X, y, len, adjs, weight, lambdaA, lambdaW)
%cost function for multi A sigle W case
nw=length(weight);
if(iscell(len)) len=cell2mat(len);  end
nGroup=length(len);
if(length(adjs(:))/nw!=nGroup)
  error(['Number of element in *adjs* (',num2str(length(adjs(:))),...
    ') does not match length of *len*(',num2str(length(nGroup(:))),')']);
  return;
end
adjs=reshape(adjs,nw,nGroup);

J = 0;
grad = zeros((nGroup+1)*nw,1);
if(length(y)==0)  return;end

sa=sigmoid(adjs);
ea=exp(-adjs.^2/2);

len=[0; cumsum(len)(:)];
gw=zeros(nw,1);
for i=1:nGroup
  mt=len(i+1)-len(i);
  Xt=X(len(i)+1:len(i+1),:);
  yt=y(len(i)+1:len(i+1));
  sat=sa(:,i);
  eat=ea(:,i);
  ht=sigmoid(Xt*(sat.*weight));
  
  %cost
  J+=sum(-yt.*log(ht)-(1-yt).*log(1-ht))/mt;
  J+=lambdaW*sum(weight.^2)/2/mt;
  J+=lambdaA*sum(eat)/mt;
  %grad
  temp=Xt'*(ht-yt).*sat/mt;
  %grad-adj
  grad((i-1)*nw+1:i*nw)=temp.*(1-sat) + lambdaA/mt*adjs(:,i).*eat;
  %grad-weight
  gw+=temp + lambdaW/mt*weight;
end
grad(nGroup*nw+1:end)=gw/nGroup;

end
