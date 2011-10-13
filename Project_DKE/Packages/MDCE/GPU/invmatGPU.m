function [Y] = invmatGPU(A,X) 
%
% For direct matrix inversion by GPU
%
%   INPUTS:
%
%       - A: full matrix [n,m]
%       - X: full vector [n,1]
%
%   OUTPUTS:
%   
%       - Y: full vector [1,m]
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA-IRFM) and Joan Decker <joan.decker@cea.fr> (CEA-IRFM)
%	
Y = A\X;
        