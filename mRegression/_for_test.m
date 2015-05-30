##################
#for test:
function [CMarr]=test_list_AW(fn_list,n_trial,D,A,W)
  CMarr=cell(n_trial,1);
  for i=1:n_trial
    CMarr(i)=testAW(A,W,readRaw(fn_list(i)),D);
  end
end

function acc=cm2acc(CM)
  if(iscell(CM))  CM=cell2mat(CM);  end;
  acc=(CM(:,1)+CM(:,4))./sum(CM,2);
end

function accMat=cm2accMat(CMarr)
  [n,m]=size(CMarr);
  accMat=cell(n,m);
  for i=1:n; for j=1:m;
    accMat(i,j)=cm2acc(CMarr(i,j));
  end;end;
end
