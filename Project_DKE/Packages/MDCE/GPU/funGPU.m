function [Y,Z,T] = funGPU(X,a,b,c,d) 
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
%       - T: processed structure T.y = Y and T.z = Z [structure]
%
% by Yves Peysson <yves.peysson@cea.fr> (CEA-IRFM) and Joan Decker <joan.decker@cea.fr> (CEA-IRFM)
%	
if nargin == 3,
    [Y,Z] = funGPU1(X,a,b);
elseif nargin == 4,%matrix product with cell (imaginary or real)
    if ~isempty(c) && iscell(c),
        [Y,Z] = funGPU1(X,a,b,c); 
    else
        [Y,Z] = funGPU1(X,a,b);    
    end
elseif nargin == 5,%matrix product with structure (imaginary or real)
    if ~isempty(c) && iscell(c) && isstruct(d),
        %
        [Y,Z] = funGPU1(X,a,b,c);       
        %
        fn = fieldnames(d);
        for id = 1:size(d),
            for ifn = 1:length(fn),
                if ~isempty(d(id).(fn{ifn})),
                    Z = d(id).(fn{ifn}).*Z^2;
                end
            end
        end
    else
        [Y,Z] = funGPU1(X,a,b);
    end
end
%
T.y = Y;
T.z = Z;
%
end
%
function [Y,Z] = funGPU1(X,a,b,c)
    %
    if nargin == 4,
        if imag(a)==0 && imag(b)==0,%matrix dot-product
            Y = c{1}*a - c{2}*3*b + c{3}*X.*(1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X./9)./8))./7))./6))./5))./4))./3))./2)) + sin(X.^3);
            Z = X.^2;
        else,%matrix product
            Y = c{1}*a - c{2}*3*b + c{3}*X*(1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X/9)/8))/7))/6))/5))/4))/3))/2)) + sin(X^3);
            Z = X^2;
        end
    else
    	if imag(a)==0 && imag(b)==0,%matrix dot-product
            Y = a - 3*b + X.*(1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X./9)./8))./7))./6))./5))./4))./3))./2)) + sin(X.^3);
            Z = X.^2;
        else,%matrix product
            Y = a - 3*b + X*(1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X*((1 + X/9)/8))/7))/6))/5))/4))/3))/2)) + sin(X^3);
            Z = X^2;
        end
    end
end
