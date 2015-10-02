function showDynamicMat(rtm,cid,nRow,nCol,idx,nNeuList, nTick,tckBeg,tckEnd,dashThre=0,sepper)
  len=length(idx);
  for row=1:nRow;for col=1:nCol;
    i=(row-1)*nCol+col;
    if(i>len)  break;  end;
    gnid=idx(i);
    rlnID=mapGNId2Local(gnid,nNeuList);
    subplot(nRow,nCol,i);
    showShape(rtm(:,:,cid),gnid,rlnID,nTick,tckBeg,tckEnd,dashThre,sepper);
  end;end;
end
