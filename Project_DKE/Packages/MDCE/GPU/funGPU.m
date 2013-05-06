function [Y,Z] = funGPU(X,a,b,c,d) 
%
% For testing the GPU capabilities on Matlab with testGPU.m
%
%   INPUTS:
%
%       - X: any tensor [n,m,p,....]
%       - a: scalar or tensor [n,m,p,....]
%       - b: scalar or tensor [n,m,p,....]
%       - c: parameters in cell format [1,3]
%       - d: parameters in structure format [1,3]
%
%   OUTPUTS:
%   
%       - Y: processed tensor [n,m,p,....]
%       - Z: processed tensor [n,m,p,....]
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA-IRFM) and Joan Decker <joan.decker@cea.fr> (CEA-IRFM)
%	
if nargin == 3,%matrix dot-product
    Y = a - 3*b + X.*(1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X./9)./8))./7))./6))./5))./4))./3))./2)) + sin(X.^3);
    Z = X.^2;
elseif nargin == 4,%matrix product with cell (imaginary or real)
    if ~isempty(c) && iscell(c),
        Y = c{1}*a - c{2}*3*b + c{3}*X*(1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X/9)/8))/7))/6))/5))/4))/3))/2)) + sin(X^3);
        Z = X^2;
    end
elseif nargin == 5,%matrix product with structure (imaginary or real)
    if ~isempty(c) && iscell(c) && isstruct(d),
        Y = c{1}*a - c{2}*3*b + c{3}*X*(1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X/9)/8))/7))/6))/5))/4))/3))/2)) + sin(X^3);
        %
        Z = X^2;
        %
        fn = fieldnames(d);
        for id = 1:size(d),
            for ifn = 1:length(fn),
                if ~isempty(d(id).(fn{ifn})),
                    Z = d(id).(fn{ifn}).*Z^2;
                end
            end
        end
    end
end
