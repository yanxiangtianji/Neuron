function fnlist=makeFileList(nTri,varargin)
  nCue=length(varargin);
  fnlist=cell(nTri,nCue);
  for i=1:nCue;
    fnlist(:,i)=cell2mat(varargin(i))(1:nTri);
  end;
end
