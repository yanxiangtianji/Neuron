function [mat_nd,scale_f]=myNDCore(mat,beta=0.95,alpha=1)

%--------------------------------------------------------------------------
% ND.m: network deconvolution
%--------------------------------------------------------------------------
%
% DESCRIPTION:
%
% USAGE:
%    mat_nd = ND(mat,beta,alpha)
%
% INPUT ARGUMENTS:
% mat           Input matrix, if it is a square matrix, the program assumes
%               it is a relevance matrix where mat(i,j) represents the similarity content
%               between nodes i and j. Elements of matrix should be
%               non-negative.

% beta          Scaling parameter, the program maps the largest absolute eigenvalue
%               of the direct dependency matrix to beta. It should be
%               between 0 and 1.
% alpha         fraction of edges of the observed dependency matrix to be kept in
%               deconvolution process. It should be between 0 and 1. (1 for keeping all)
%
% OUTPUT ARGUMENTS:

% mat_nd        Output deconvolved matrix (direct dependency matrix). Its components
%               represent direct edge weights of observed interactions.
% scale_f       scaling factor to make the input matrix deconvolutable, and it is also
%               factor to scale the output mat_nd back to domain specific matrix.
%               i.e. mat_nd*scale_f will convolute as mat.
 
 
% To apply ND on regulatory networks, follow steps explained in Supplementary notes
% 1.4.1 and 2.1 and 2.3 of the paper.


% LICENSE: MIT-KELLIS LAB


% AUTHORS:
%    Algorithm was programmed by Soheil Feizi.
%    Paper authors are S. Feizi, D. Marbach,  M. M茅dard and M. Kellis
%
% REFERENCES:
%   For more details, see the following paper:
%    Network Deconvolution as a General Method to Distinguish
%    Direct Dependencies over Networks
%    By: Soheil Feizi, Daniel Marbach,  Muriel M茅dard and Manolis Kellis
%    Nature Biotechnology
%

% MODIFIED:
%    Tian Zhou

%***********************************
% processing the input matrix
% diagonal values are filtered

n = size(mat,1);

if alpha!=0
	y=quantile(mat(:),1-alpha);
	mat=mat.*(mat>=y);
end

%***********************************
% eigen decomposition
%disp('decomposition and deconvolution...')
[U,D] = eig(mat);

lam_n=abs(min(min(diag(D)),0));
lam_p=abs(max(max(diag(D)),0));

m1=lam_p*(1-beta)/beta;
m2=lam_n*(1+beta)/beta;

scale_f=max(m1,m2);

%network deconvolution
for i = 1:n
    D(i,i) = (D(i,i))/(scale_f+D(i,i));
end
mat_nd = U*D*inv(U);

