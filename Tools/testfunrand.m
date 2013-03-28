function [fx,normfx] = testfunrand(h,x_range,x,testmode)
%
% Test function for script randreject_yp. Calculate the random variable with a linear decrease of the p.d.f. normalized to 1 on the x_range domain
% fx(x_range(1))/fx(x_range(2)) = h
%
% Input:
%
%   - h : ratio between the pdf values at x_range [1,1]
%     (default = 1)
%   - x_range : range of the random variable [3,1] or [1,3] for example. If [1,3], f(1)/f(3) = 1/h, and if [3,1], f(1)/f(3) = h.
%
% Output:
%
%   - fx : p.d.f. of the random variable x [N,1]
%   - normfx :  numerical norm of the p.d.f fx [1,1]
%
% by J. Decker (CEA-IRFM) <joan.decker@cea.fr> and Y.Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
if nargin < 3,
    error('Wrong number of input arguments in testfunrand.m');
end
%   
fx = 2*(1 - (1 - h{1})*(x - x_range(1))/(x_range(2) - x_range(1)))/abs(x_range(2) - x_range(1))/(h{1}+1);
%
% Test that fx is normalized to one in the interval defined by x_range
%
if nargin > 3,
    if testmode,
        x = linspace(x_range(1),x_range(2),10000);
        fx = 2*(1 - (1 - h{1})*(x - x_range(1))/(x_range(2) - x_range(1)))/abs(x_range(2) - x_range(1))/(h{1}+1);
        normfx = trapz(x,fx);
    end
else
    normfx = NaN;
end
