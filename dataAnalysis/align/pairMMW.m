function [ws,cr]=pairMMW(d1,d2,compact=false)  %ws and cr are column vectors
%give minimum Window Size for each Coverage Ratio
  %init to row vector & basic check
  ws=cr=[0];
  if(iscell(d1));  d1=cell2mat(d1);  end;
  if(isempty(d1)) return; end;
  if(iscell(d2));  d2=cell2mat(d2);  end;
  if(isempty(d2)) return; end;
  if(isrow(d1)==0) d1=reshape(d1,1,numel(d1));  end;
  if(isrow(d2)==0) d2=reshape(d2,1,numel(d2));  end;
  ld1=length(d1); ld2=length(d2);
  %main:
  cr=(1:ld1)'./ld1;
  %dis=abs(d1-d2');%size=length(d2),length(d1)
  ws=sort(min(abs(d1-d2')))';
  if(isbool(compact))
    if(compact==true)
      [ws,idx]=unique(ws);%idx is the last occurence in ws
      cr=cr(idx);
    end
  elseif(isnumeric(compact) && isvector(compact) && length(compact)>1 ...
      && (sum(compact>=0 & compact<=1)==length(compact)) )
    [ws,cr]=compactWC2quantile(ws,cr,compact);
  else
    error('compact parameter should be a boolean or a vector with values in range [0,1]')
  end
end
