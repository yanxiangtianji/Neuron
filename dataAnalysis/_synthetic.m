#################
#single spike trend
function info=cal_single(l,e,x,rng,type='DP')
  info=zeros(length(rng),1);
  if(strcmp(type,'DP'))
    for i=1:length(rng);w=rng(i);nBin=ceil(l/w);
      info(i)=dot_product(discretize(x,w,0,nBin,'binary'),discretize(x+e,w,0,nBin,'binary'));
    end;
  else  %MI
    for i=1:length(rng);w=rng(i);nBin=ceil(l/w);
      info(i)=mutual_info(discretize(x,w,0,nBin,'count'),discretize(x+e,w,0,nBin,'count'));
    end;
 end
end
function show_single(rng,info,x,e,type='DP')
  plot(rng,info,'-*',[x x+e],0,'rh');set(gca,'xtick',0:0.1:1);grid;
  xValues=[x x+e x+e x];yValues=[0 0 1 1];
  if(strcmp(type,'DP'))
    line([0 0.5],[0 1],'linestyle','--','color','r');
    patch([0 e e],[0 0 e*2],'g');
    i=1;while(x/i>=e) patch(xValues/i,min(1,yValues*2.*xValues/i),'y'); ++i; end;
  else  %MI
    line([0 0.5],[0 1],'linestyle','--','color','r');
    patch([0 e e],[0 0 e*2],'g');
    i=1;while(x/i>=e) patch(xValues/i,yValues,'y'); ++i; end;
  end
end

rng=[0.01,0.025:0.025:1];
type='DP';
type='MI';

l=1;e=0.1;
x=rand()*(l-e);
dp=cal_single(l,e,x,rng,type);show_single(rng,dp,x,e,type);

#################
#multiple spike trend
function dp=cal_multiple(L,n,r,window_size,nSample=100,type='DP')
  dp=zeros(length(window_size),1);
  for i=1:nSample;
    x=randi(L,n,1); %uniform
    x=cumsum(exprnd(L/n,n,1));x=find(x<=L);%poisson process
    rnd=unifrnd(-r,r,n,1);%uniform
%    rnd=normrnd(0,r/3,n,1);%normal
    y=max(0,x+rnd);
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
dp=cal_multiple(5000,100,50,window_size,10);plot(log10(window_size),dp);

window_size=unique(round(10.^(0:0.2:4)));
type='DP';
type='MI';

%trend on radius
radius=[10:10:150];
dp=zeros(length(window_size),length(radius));
for i=1:length(radius);
  dp(:,i)=cal_multiple(5000,500,radius(i),window_size,10,type);
end
plot(log10(window_size),dp);xlabel('log10(WS)');
ylabel(type);legend(num2str(radius'));title([type,' on various radius']);
plot(window_size(1:14),dp(1:14,:));xlabel('WS');

%trend on spike rate
rate=[.05:.05:.5];
rate=[0.001*2.^(1:7)]
L=5000;
dp2=zeros(length(window_size),length(rate));
for i=1:length(rate);
  dp2(:,i)=cal_multiple(L,round(L*rate(i)),50,window_size,10);
end
plot(log10(window_size),dp2);xlabel('log10(WS)');
ylabel(type);legend(num2str(rate'));title([type,' on various rate']);
plot(window_size(1:14),dp2(1:14,:));xlabel('WS');
