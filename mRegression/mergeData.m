function data=mergeData(varargin)
%Just concatenate several data piece as row-expansion.
%varargin is a row vector, varargin(:) converts it into a column vector

data=cell2mat(varargin(:));

end
