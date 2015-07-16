function result=discretize_step(value,binSize=1,offset=0,stepPerBin=1,resLength=0,type='count')
%type can be 'count' or 'binary'
%result is a column vector
  if(length(stepPerBin)!=1 || isindex(stepPerBin)==0)
    error('stepPerBin should be an integeer');
  end;
  if(stepPerBin==1) result=discretize(value,binSize,offset,resLength,type);return; end;
  oneLength=ceil(resLength/stepPerBin);
  temp=zeros(stepPerBin,oneLength);
  for i=1:stepPerBin;
    temp(i,:)=discretize(value,binSize,offset+binSize/stepPerBin*(i-1),oneLength,type);
  end;
  result=temp(1:resLength)';
end
