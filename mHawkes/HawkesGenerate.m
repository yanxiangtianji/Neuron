function data=HawkesGenerate(n,timeEnd,bkgRate,interRate,delayF)
%generate univariate/multivariate Hawkes Process
%n:         number of nodes
%timeEnd:   data range [0, timeEnd]
%bkgRate:   vector of background rate (\lambda in Poisson process)
%           Or scalar for univariate
%interRate: square matrix of interactive rate (delata \lambda in Prossion process)
%           Or scalar for univariate
%delayF:    square matrix of interactive delay factor (\lambda in exponential delay function)
%           Or scalar for univariate

%Homogeneous Poisson process (with rate lam):
%0, addible.
%i.e. PP(lam)=PP(lam1)+PP(lam2), when lam=lam1+lam2
%1, Delta count in period lasting t follows Poisson distribution P(lam*t)
%i.e. P(N(s+t)-N(s)==k) = exp(-lam*t) * (lam*t)^k / k!
%2, Arrival interval follows exponential distribution Exp(lam)
%i.e. f(t) = lam*exp(-lam*t)
%3, Arrival time of n-th event follows Gammar distribution Gammar(n,lam)
%i.e. f_Tn(t)=lam*exp(-lam*t) * (lam*t)^(n-1) / (n-1)! , t>=0; 0, t<0
%3.1 joint PDF of t1,t2,...,tn
% f(t1,t2,...,tn)=lam^n * exp(-lam*tn) , t1<t2<...<tn<t; 0, otherwise
%3.2 joint PDF of t1,t2,...,tn , given N(t)=n
% f(t1,t2,...,tn|N(t)=n)=n! / t^n , t1<t2<...<tn<t; 0, otherwise

%Non-Homogeneous Poisson Process (with rate lam(t))
%def. A(t)=\inf_0^t (lam(t)) dt
%1, Delta Count ~ P(A(s+t)-A(s))
%i.e. P(N(s+t)-N(s)==k) = exp(-(A(s+t)-A(s))) * (A(s+t)-A(s))^k / k!
%2, Arrival interval started at s ~ Gammar(1,A(s+t)-A(t))
%i.e. f(t;s) = (lam(s+t)-lam(s))*exp(-(A(s+t)-A(s)))
%3, Arrival time ~ Gammar(n,A(t))
%i.e. f_Tn(t) = lam(t)*exp(-A(t)) * (A(t))^(n-1) / (n-1)! , t>=0; 0, t<0


%check:
if(!(isscalar(n) && isindex(n)))
  error(['Invaild number of nodes (positive integeger required, but "',...
    num2str(timeEnd),'" is input).']);
elseif(!(isscalar(timeEnd) && timeEnd>0))
  error(['Invaild end time (positive scalar required, but "',...
    num2str(timeEnd),'" is input).']);
elseif(!(isscalar(bkgRate)&&bkgRate>=0 || length(bkgRate)==n&&sum(bkgRate>=0)==n))
  error(['Invaild background rate (positive scalar/vector(length=n) required).']);
elseif(!(isscalar(interRate)&&interRate>=0 ||
    ismatrix(interRate)&&sum(size(interRate)==[n,n])==2&&sum(interRate(:)>=0)==n*n))
  error(['Invaild interactive rate. (positive scalar/square matrix(length=n) required']);
elseif(!(isscalar(delayF)&&delayF>=0 ||
    ismatrix(delayF)&&sum(size(delayF)==[n,n])==2&&sum(delayF(:)>=0)==n*n))
  error(['Invaild delay factor. (positive scalar/square matrix(length=n) required']);
end

%init
data=cell(n,1);
if(isscalar(bkgRate))
  bkgRate=zeros(n,1)+bkgRate;
end
if(isscalar(interRate))
  interRate=zeros(n)+interRate;
end
if(isscalar(delayF))
  delayF=zeros(n)+delayF;
end
avgN=timeEnd.*bkgRate;
rate=bkgRate;

%bfs generation:
que=zeros(0,2); %time, node
closed=zeros(0,2);
len=avgN;
%idx=zeros(n,1)+1;
for i=1:n
  t0=0;
  t=[];
  while(t0<timeEnd)
    t=[t; t0+cumsum(drawInterval(rate(i),len))];
    t0=t(end);
    len=min(8,len/2);
  end
  t=t(find(t<=TimeEnd));
  que=[que; [t zeros(length(t),1)+i]];
end



%format for output
t=closed(:,2)==1:n;
for i=1:n
  data(i)=closed(1,find(t(:,i)));
end

end; %main function

%helper functions:
function time=drawInterval(lambda,num=1)
  time=exprnd(lambda,num,1);
end

