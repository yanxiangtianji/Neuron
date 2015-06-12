##################
#for test:
function _for_test()
  assignin('base','cm2acc',@cm2acc);
  assignin('base','cm2accMat',@cm2accMat);
end

%basic reusable functions:
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

%batch functions:
function [CMarr]=test_list_AW(fn_list,n_trial,D,A,W)
  CMarr=cell(n_trial,1);
  for i=1:n_trial
    CMarr(i)=testAW(A,W,readRaw(fn_list(i)),D);
  end
end

%roc curve
function [auroc,roc]=calROC(CM,draw=0)
  if(iscell(CM)) CM=cell2mat(CM(:));  end;
  roc=zeros(size(CM,1),2);  %fpRate, tpRate
  roc(:,1)=CM(:,3)./(CM(:,3)+CM(:,4));  %fpRate
  roc(:,2)=CM(:,1)./(CM(:,1)+CM(:,2));  %tpRate
  idx=union(find(isnan(roc(:,1))),find(isnan(roc(:,2))));%remove NaN entries
  roc(idx,:)=[];
  roc=[0,0;sortrows(roc);1,1];
  if(draw)
    plot(roc(:,1),roc(:,2),[0,1],[0,1]);xlabel('FPR');ylabel('TPR');
  end
  n=size(roc,1);
  auroc=0;
  for i=2:n
    auroc+=(roc(i,1)-roc(i-1,1))*(roc(i,2)+roc(i-1,2))/2;
  end
end

