#cross neuron mutual information of different window size

addpath('../mRegression/')
basicParameters
rData=readRaw([fn_prefix,'all.txt']);
rmpath('../mRegression/')

maxTime=0;
for i=1:n
  maxTime=max(maxTime,cell2mat(rData(i))(end));
end

window_size=10.^[1:9]*timeUnit2ms;
window_size=[10:10:50, 100:50:300, 400:100:1000, 2000:1000:10000]*timeUnit2ms;
mi=zeros(n,n,length(window_size));
for i=1:length(window_size);
  tic;
  ws=window_size(i);
  resLenght=ceil(maxTime/ws);
  data=zeros(resLenght,n);
  for j=1:n;
    data(:,j)=discretize(cell2mat(rData(j)),ws,0,resLenght);
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


