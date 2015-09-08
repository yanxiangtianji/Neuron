function info=genRestTrials(posStart,posRng,triLength)

if(isempty(idx=find(posRng<triLength))==false)
  posStart(idx)=[];
  posRng(idx)=[];
  if(isvector(triLength) && length(triLength)>1)
    triLength(idx)=[];
  end
end

nTri=numel(posStart);
info=zeros(nTri,2);
info(:,1)=posStart+posRng-triLength/2;
info(:,2)=info(:,1)+triLength;

end