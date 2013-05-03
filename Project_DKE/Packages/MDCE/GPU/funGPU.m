function [Y,Z] = funGPU(X,a,b) 
%
% For testing the GPU capabilities on Matlab with testGPU.m
%
%   INPUTS:
%
%       - X: any tensor [n,m,p,....]
%       - a: scalar or tensor [n,m,p,....]
%       - b: scalar or tensor [n,m,p,....]
%
%   OUTPUTS:
%   
%       - Y: processed tensor [n,m,p,....]
%       - Z: processed tensor [n,m,p,....]
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA-IRFM) and Joan Decker <joan.decker@cea.fr> (CEA-IRFM)
%	
Y = a - 3*b + X.*(1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X./9)./8))./7))./6))./5))./4))./3))./2)) + sin(X.^3);
Z = X.^2;        