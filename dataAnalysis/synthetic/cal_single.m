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
