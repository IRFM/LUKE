function [Y,Z,T,W] = funGPU(X,a,b,c,d) 
%
% For testing the GPU capabilities on Matlab with testGPU.m script
% Y = exp(X) [by the Horner's rule]  + sinc(X^2)
% Z is based on matrix product for testing the effect of network between cores on GPU calculations
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
%       - W: processed cell W{Y}, W{Z} [table of cells]
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
W{1} = Y;
W{2} = Z;
%
end
%
function [Y,Z] = funGPU1(X,a,b,c)
    %
    Y = 1 + X.*(1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X.*((1 + X./9)./8))./7))./6))./5))./4))./3))./2)) + sinc(X.^2);%matrix dot-product (Horner's rule to compute y = exp(x) + sinc(x^2))
    %
    if imag(a)~=0 || imag(b)~=0,
        Z = a - 3*b + Y*(1 + Y*((1 + Y*((1 + Y*((1 + Y*((1 + Y*((1 + Y*((1 + Y*((1 + Y/9)/8))/7))/6))/5))/4))/3))/2));%for testing matrix product that uses heavily network between cores
    else
        Z = '';
    end
    %
    if nargin == 4,
        Z = c{1}.*Y - c{2}.*Y.^2 + c{3}.*Y.^3;
    end
end
