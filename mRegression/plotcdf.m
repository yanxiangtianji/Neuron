function plotcdf(x,nsep=20)

[_h,_x]=hist(x(:),nsep);
plot(_x,cumsum(_h)/sum(_h),'o-');
ylim([0,1]);grid;

end
