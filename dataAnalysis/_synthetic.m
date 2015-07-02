function dp=fun(n,L,r,window_size,nSample=100,type='DP')
  dp=zeros(length(window_size),1);
  for i=1:nSample;
    x=randi(L,n,1);
    y=max(0,x+randi(2*r+1,n,1)-r-1);
    for wid=1:length(window_size);
      ws=window_size(wid);
      if(strcmp(type,'DP'))
        dx=discretize(x,ws,0,ceil(L/ws),'binary');
        dy=discretize(y,ws,0,ceil(L/ws),'binary');
        dp(wid)+=dot_product(dx,dy);
      else; %MI
        dx=discretize(x,ws,0,ceil(L/ws),'count');
        dy=discretize(y,ws,0,ceil(L/ws),'count');
        dp(wid)+=mutual_info(dx,dy);
      end
    end
  end;
  dp/=nSample;
end;
dp=fun(100,5000,50,window_size,10);plot(log10(window_size),dp);

window_size=unique(round(10.^(0:0.2:4)));
type='DP';
type='MI';

%trend on radius
radius=[10:10:150];
dp=zeros(length(window_size),length(radius));
for i=1:length(radius);
  dp(:,i)=fun(500,5000,radius(i),window_size,10,type);
end
plot(log10(window_size),dp);xlabel('log10(WS)');
ylabel(type);legend(num2str(radius'));title([type,' on various radius']);
plot(window_size(1:14),dp(1:14,:));xlabel('WS');

%trend on spike rate
rate=[.05:.05:.5];
rate=[.01 .05 .1:.1:.5];
dp2=zeros(length(window_size),length(rate));
for i=1:length(rate);
  dp2(:,i)=fun(round(500*rate(i)),5000,50,window_size,10);
end
plot(log10(window_size),dp2);xlabel('log10(WS)');
ylabel(type);legend(num2str(rate'));title([type,' on various rate']);
plot(window_size(1:14),dp2(1:14,:));xlabel('WS');
