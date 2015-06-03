#################
#statistics functions (distri. & stat.):

function basicStatFuns()
  assignin('base','distriVec',@distriVec);
  assignin('base','statVec',@statVec);
  assignin('base','distriMat',@distriMat);
  assignin('base','statMat',@statMat);
end

#for vector
function dis=distriVec(arr)
  l=length(arr(:));
  n=size(cell2mat(arr(1)),1);
  disAcc=zeros(n,l);
  for i=1:l
    dis(:,i)=cell2mat(arr(i));
  end
end

function [avgV,stdV]=statVec(dis)
  avgV=mean(dis,2);
  stdV=std(dis,1,2);
end

#for matrix
function dis=distriMat(arr)
  l=length(arr(:));
  n=size(cell2mat(arr(1)),1);
  dis=zeros(n,n,l);
  for i=1:l
    dis(:,:,i)=cell2mat(arr(i));
  end
end

function [avgM,stdM]=statMat(arr)
  l=length(arr(:));
  t=cell2mat(arr(1));
  sum1=t;
  sum2=t.^2;
  for i=2:l
    t=cell2mat(arr(i));
    sum1+=t;
    sum2+=t.^2;
  end
  avgM=sum1/l;
  stdM=sqrt(max(0,sum2/l-avgM.^2));    %handle float error
end


