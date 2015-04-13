function [varargout]=test(p,y)

tp=sum(p==1 & y==1);
fp=sum(p==1 & y==0);
fn=sum(p==0 & y==1);
tn=sum(p==0 & y==0);

if(nargout==1)
  varargout=mat2cell([tp,fp,fn,tn],1,4);
else
  varargout(1)=num2cell(tp);
  varargout(2)=num2cell(fp);
  varargout(3)=num2cell(fn);
  varargout(4)=num2cell(tn);
end

end