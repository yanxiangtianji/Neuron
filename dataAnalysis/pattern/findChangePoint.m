function chp=findChangePoint(vec,startIdx,thres,granu=1)
%TODO: add threshold based on std of referenced range
  if(!isvector(vec))
    error('VEC should be a vector');
  end
  bl=mean(vec(1:startIdx-1));
  
  thres=bl*thres;
  
  nBin=floor(length(vec)/granu);
  if(!iscolumn(vec))  vec=vec(:); end
  vec=mean( reshape(vec(1:granu*nBin),granu,nBin),1 );
  
  startIdx=floor((startIdx-1)/granu)+1;
  chp=startIdx-1+min(find( abs(vec(startIdx:end)-bl) >thres));
  
  chp=chp*granu;
  if(isempty(chp))
    chp=NaN;
    return;
  end
  
  if(granu!=1)
    chp=chp-1+min(find( abs(vec(max(startIdx,chp):chp+granu-1)-bl) >thres));
  end
  
end
