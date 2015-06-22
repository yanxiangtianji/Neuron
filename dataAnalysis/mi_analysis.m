###################
#cross NEUORN mutual information on identical period

%load data
addpath('../mRegression/')
basicParameters
rData=readRaw([fn_prefix,'all.txt']);
rmpath('../mRegression/')

maxTime=0;
for i=1:length(rData);
  maxTime=max(maxTime,cell2mat(rData(i))(end));
end

window_size=10.^[1:9]*timeUnit2ms;
window_size=[10:10:50, 100:50:300, 400:100:1000, 2000:1000:10000]*timeUnit2ms;
mi=zeros(n,n,length(window_size));
for i=1:length(window_size);
  tic;
  ws=window_size(i);
  vecLength=ceil(maxTime/ws);
  data=zeros(vecLength,n);
  for j=1:n;
    data(:,j)=discretize(cell2mat(rData(j)),ws,0,vecLength);
  end;
  mi(:,:,i)=mutual_info_all(data);
  toc;
end;

save('xneu.mat','window_size','mi');

i=6;j=14;
plot(window_size/timeUnit2ms,mi(i,j,:)(:));xlabel('windows size(ms)');ylabel('mutual information');
title(['MI between ',num2str(i),' and ',num2str(j)]);

hold on
for i=1:19;for j=i+1:19;plot(window_size/timeUnit2ms,mi(i,j,:)(:));end;end;
hold off

idx=find(mi(:,:,1));
mi2=zeros(length(window_size),length(idx));
for i=1:length(idx);
  ii=mod(idx(i)-1,n)+1;
  jj=ceil(idx(i)/n);
  mi2(:,i)=mi(ii,jj,:)(:);
end;
plot(log10(window_size/timeUnit2ms),mi2)


###################
#cross TRIAL mutual information on identical neuron

addpath('../mRegression/')
basicParameters
function rData=_readList(flist,n,fn_prefix)
  rData=cell(length(flist),n);
  for i=1:length(flist)
    rData(i,:)=readRaw([fn_prefix,cell2mat(flist(i))]);
  end
end
rData_c1=_readList(fn_c1,n,fn_prefix);
rData_c2=_readList(fn_c2,n,fn_prefix);
rData_r1=_readList(fn_r1,n,fn_prefix);
rData_r2=_readList(fn_r2,n,fn_prefix);
rmpath('../mRegression/')

function maxTime=findMaxTime(rDataList,n)
  maxTime=0;
  for i=1:length(rDataList);for j=1:n;
    maxTime=max(maxTime,cell2mat(rDataList(i,j))(end));
  end;end;
end

window_size=10.^[1:9]*timeUnit2ms;
window_size=[10:10:50, 100:50:300, 400:100:1000, 2000:1000:10000]*timeUnit2ms;

function mi=calMI_xt_one(rDataList,idx,maxTime,ws)
  l=length(rDataList);
  vecLength=ceil(maxTime/ws);
  data=zeros(vecLength,l);
  for i=1:l;
    data(:,i)=discretize(cell2mat(rDataList(i,idx)),ws,0,vecLength);
  end;
  mi=mutual_info_all(data);
end
function mi=calMI_xt(rDataList,n,window_size)
  maxTime=findMaxTime(rDataList,n);
  mi=cell(n,length(window_size));
  for i=length(window_size)
    tic;
    for idx=1:n
      mi(idx,i)=calMIOne_xt(rDataList,idx,maxTime,window_size(i));
    end
    toc;
  end
end

%type: mi=cell(n,length(window_size)); mi(1)=zeros(length(rDataList));
mi_c1=rDataList(rData_c1,window_size);
mi_c2=rDataList(rData_c2,window_size);
mi_r1=rDataList(rData_r1,window_size);
mi_r2=rDataList(rData_r2,window_size);

save('Xtrial.mat','window_size','mi_c1','mi_c2','mi_r1','mi_r2');

###################
#cross CUE mutual information on identical neuron

%load data part is the same as cross TRIAL part

function mi=calMIOne_xc(rDataList1,rDataList2,idx,maxTime,ws)
%mean MI for all trial pairs
  vecLength=ceil(maxTime/ws);
  l1=length(rDataList1); l2=length(rDataList2);
  data1=zeros(vecLength,length(rDataList1));
  for i=1:l1;
    data1(:,i)=discretize(cell2mat(rDataList1(i,idx)),ws,0,vecLength);    
  end;
  mi=0;
  for i=1:l2;
    data2=discretize(cell2mat(rDataList2(i,idx)),ws,0,vecLength);    
    for j=1:l1;
      mi+=mutual_info(data2,data1(:,j));
    end
  end;
  mi/=l1*l2;
end

maxTime=zeros(4,1);
maxTime(1)=findMaxTime(rData_c1);
maxTime(2)=findMaxTime(rData_c2);
maxTime(3)=findMaxTime(rData_r1);
maxTime(4)=findMaxTime(rData_r2);

mi=cell(n,length(window_size));
for i=1:length(window_size);
  ws=window_size(i);
  for idx=1:n;
   t=zeros(4,4);
   t(1,2)=calMIOne_xc(rData_c1,rData_c2,idx,max(maxTime([1,2]),ws);
   t(1,3)=calMIOne_xc(rData_c1,rData_c2,idx,max(maxTime([1,3]),ws);
   t(1,4)=calMIOne_xc(rData_c1,rData_c2,idx,max(maxTime([1,4]),ws);
   t(2,3)=calMIOne_xc(rData_c1,rData_c2,idx,max(maxTime([2,3]),ws);
   t(2,4)=calMIOne_xc(rData_c1,rData_c2,idx,max(maxTime([2,4]),ws);
   t(3,4)=calMIOne_xc(rData_c1,rData_c2,idx,max(maxTime([3,4]),ws);
   mi(idx,i)=t;
  end;
end;


