function [varargout]=modifyTrainResult(varargin)
  if(nargin==1)
    W=cell2mat(varargin);
    n=length(W);
    varargout=mat2cell(modifyWeight(W),n,n);
  elseif(nargin==2)
    varargout=cell(2,1);
    varargout(1)=modifyAdjacency(cell2mat(varargin(1)));
    varargout(2)=modifyWeight(cell2mat(varargin(2)));
  end
end

function W=modifyWeight(W)
  n=length(W);
  for i=1:n
    W(i,i)=0;
  end
end

function A=modifyAdjacency(A)
  n=length(A);
  A=A>0;
  for i=1:n
    A(i,i)=0;
  end
end
