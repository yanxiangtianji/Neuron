function data=labelData2ArrayData(varargin,numClass=0)

if(length(varargin)==1)
  t=cell2mat(varargin);
  if(length(size(t))!=2 || size(t,2)!=2)
    error('Wrong size of input data');
  end
  val=t(:,1);lbl=t(:,2);
elseif(length(varargin)==2)
  val=cell2mat(varargin(1))(:);
  lbl=cell2mat(varargin(2))(:);
  if(sum(size(val)==size(lbl))!=2)
    error('Wrong size of input data');
  end
else
  error('Wrong number of input arguments');
end

if(numClass==0)
  numClass=max(lbl);
end

data=cell(numClass,1);
t=lbl==1:numClass;
for i=1:numClass
  data(i)=val(find(t(:,i)));
end


end
