addpath([pwd,'./synthetic/'])

#################
#single spike trend

%function info=cal_single(l,e,x,rng,type='DP')
%function show_single(rng,info,x,e,type='DP')

rng=[0.01,0.025:0.025:1];
type='DP';
type='MI';

l=1;e=0.1;
x=rand()*(l-e);
dp=cal_single(l,e,x,rng,type);show_single(rng,dp,x,e,type);

#################
#multiple spike trend

%init
addpath([pwd,'/../mBasic/'])
data=cell(nTri,nNeu,nCue);
data=readList(fn_c1);

window_size=unique(round(10.^(0:0.2:4)));

%function dp=cal_multiple(L,n,r,window_size,nSample=100,type='DP')
%function dp=cal_multiple_real(x,L,r,window_size,nSample=100,type='DP')

%dp=cal_multiple(5000,100,50,window_size,10);plot(log10(window_size),dp);
type='DP';
type='MI';

%trend on radius
radius=[10:10:150];
%%synthesis x
dp=zeros(length(window_size),length(radius));
for i=1:length(radius);
  dp(:,i)=cal_multiple(5000,500,radius(i),window_size,10,type);
end
%%real x
window_size=round(10.^[1:0.2:4]);
tid=1;nid=11;cid=1;
dp=zeros(length(window_size),length(radius));
for tid=1:nTri;
  x=cell2mat(data(nid,tid,cid));
  for i=1:length(radius);
    dp(:,i)+=cal_multiple_real(x,10000*timeUnit2ms,radius(i)*timeUnit2ms,window_size*timeUnit2ms,10,type);
  end
end
dp/=nTri;
%%plot
plot(log10(window_size),dp);xlabel('log10(WS)');ylabel(type);
legend(num2str(radius'));title([type,' on various radius']);

plot(window_size(1:14),dp(1:14,:));xlabel('WS');

%trend on spike rate
rate=[.05:.05:.5];
rate=[0.001*2.^(1:7)]
L=5000;
dp2=zeros(length(window_size),length(rate));
for i=1:length(rate);
  dp2(:,i)=cal_multiple(L,round(L*rate(i)),50,window_size,10);
end
%%plot
plot(log10(window_size),dp2);xlabel('log10(WS)');ylabel(type);
legend(num2str(rate'));title([type,' on various rate']);

plot(window_size(1:14),dp2(1:14,:));xlabel('WS');
