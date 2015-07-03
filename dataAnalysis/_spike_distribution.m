
addpath('../mBasic/')

function data=loadNeuronData(fnlist,fun)
  nTri=length(fnlist);
  if(nTri==0) return; end;
  data=readRaw(fnlist(1))(:);
  nNeu=length(data);
  t=cell(nNeu,nTri);
  t(:,1)=data;
  if(nargin<2)%default: no pre-process
    for i=2:nTri;  t(:,i)=readRaw(fnlist(i))(:);  end;
  else
    for i=2:nTri;  t(:,i)=fun(readRaw(fnlist(i))(:));  end;
  end
  for i=1:nNeu;
    data(i)=cell2mat(t(i,:));
  end
end;
function info=diffFun(data)
  nNeu=numel(data);
  info=cell(size(data));
  for i=1:nNeu;
    t=cell2mat(data(i));
    if(length(t)>=2) info(i)=t(2:end)-t(1:end-1); end;
  end
end

%
data=loadNeuronData(fn_c1,@diffFun);
hist(cell2mat(data(1)),100);
