function plotcdf(x,nsep=20,tit='',xlbl='',ylbl='',xrng='auto')

[_h,_x]=hist(x(:),nsep);
plot(_x,cumsum(_h)/sum(_h),'o-');title(tit);
xlabel(xlbl);ylabel(ylbl);ylim([0,1]);xlim(xrng);grid;

end
