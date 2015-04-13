function [varargout]=test(p,y)
%disp(sprintf("nout=%d",nargout))
%nargout=max(1,nargout)
tp=sum(p==1 & y==1);
fp=sum(p==1 & y==0);
fn=sum(p==0 & y==1);
tn=sum(p==0 & y==0);

if(nargout<=1)
  varargout=mat2cell([tp,fn,fp,tn],1,4);
elseif(nargout>=2)
  varargout(1)=num2cell(tp);
  varargout(2)=num2cell(fn);
  if(nargout>=3)
    varargout(3)=num2cell(fp);
    if(nargout==4)
      varargout(4)=num2cell(tn);
    end
  end
end

end
