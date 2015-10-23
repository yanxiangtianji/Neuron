function showEventInterval(entDiff,names,timeUnit2ms)
  colormap(summer);
  [nTri,nType,nRat]=size(entDiff);%nType=nPha-1
  if(nRat==1); nRow=nCol=1;
  elseif(nRat==2); nRow=2; nCol=1;
  elseif(nRat<=4); nRow=nCol=2;
  elseif(nRat<=6); nRow=3; nCol=2;
  elseif(nRat<=9); nRow=nCol=3;
  elseif(nRat<=12);  nRow=4; nCol=3;
  else; nRow=nCol=ceil(sqrt(nRat));
  end
  for i=1:nRat
    subplot(3,2,i);[y,x]=hist(entDiff(:,:,i)/1000/timeUnit2ms,25);bar(x,y/nTri);
    grid on;legend(names);legend('boxoff')
    xm=xlim()(2);if(xm<=4) np=1+2*xm; elseif(xm<=10) np=1+xm; else np=11; end
    set(gca,'xtick',linspace(0,xm,np));
    title(['Rat: ',num2str(i)]);xlabel('delay (s)');ylabel('freq.');
  end
end
