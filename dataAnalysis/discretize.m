function result=discretize(value,binSize=1,offset=0,resLength=0,type='count')
%type can be either 'count' or 'binary'

if(iscell(value)) value=cell2mat(value)(:); end
value=ceil((value-offset)./binSize);


if(strcmp(type,'count')==1)
  [idx,~,j]=unique(value(:)); %make idx and j to be column vectors
  count=accumarray(j,1);
  if(resLength==0)  resLength=length(idx);  end;
  result=zeros(resLength,1);
  if(length(idx)==0)  return; end;

  if(idx(1)>0 && idx(end)<=resLength)
    result(idx)=count;  %to speed up
  else
    rng=_pick_rng(idx,resLength);
    result(idx(rng))=count(rng);
  end
else
  [idx]=unique(value(:));
  if(resLength==0)  resLength=length(idx);  end;
  result=zeros(resLength,1);
  if(length(idx)==0)  return; end;

  result(_pick_rng(idx,resLength))=1;
end

end

%helper function
function rng=_pick_rng(idx,resLength)
  if(length(idx)==0)
    rng=[0:0];
  else
    rng=[_pick_min(idx,resLength):_pick_max(idx,resLength)];
  end
end

function idxMin=_pick_min(idx,resLength)
  %assume idx is not empty
  idxMin=1;
  if(idx(1)==0)
    idxMin=2;
  elseif(idx(1)<0)
    t=min(resLength,-idx(1));
    idxMin=max(find(idx(1:t)<1))+1;
  end
end

function idxMax=_pick_max(idx,resLength)
  l=length(idx);
  idxMax=l;
  if(resLength!=0 && idx(end)>resLength)
    t=min(l,idx(end)-resLength);
    idxMax=l-t+min(find(idx(end-t+1:end)>resLength))-1;
  end
end

