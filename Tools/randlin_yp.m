function [y,py] = randlin_yp(N,h,ybounds,display_mode)
%
% Calculate the random variable with a linear decrease of the p.d.f.normalized to 1 at lower bound of the domain.
%
% Input:
%
%   - N : number of trials [1,1]
%     (default = 1)
%   - h : value of the pdf ranging from 1 (uniform p.d.f.) to 0 (upper value of the domain) [1,1]
%     (default = 1)
%   - ybounds : range of the random variable [2,1] or [&,2]. If NaN or empty ybounds = [0,1]
%     (default [0,1])
%   - display_mode : display the numerical and theoretical p.d.f, (0: no, 1, yes) [1,1]
%     (default = 0)
%
% Output:
%
%   - y : random variable [N,1]
%   - py : theoretical p.d.f. normalized to 1 [N,1]
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
if nargin < 1, 
    N = 1;
    h = 1;
    ybounds = [0,1];
    display_mode = 0;
elseif nargin < 2, 
    h = 1;
    ybounds = [0,1];
    display_mode = 0;    
elseif nargin < 3,
    ybounds = [0,1];
    display_mode = 0;
elseif nargin < 4,
    display_mode = 0;
end
%
if isnan(ybounds) | isempty(ybounds), 
    ybounds = [0,1];
end
%
if h == 1,%uniform distribution with p(0) = 1 and p(1) = 1
    x = rand(N,1);
elseif h == 0,%linear decreasing distribution with p(0) = 1 and p(1) = 0
    x1 = rand(N,1);
    x2 = rand(N,1);
    %
    x = abs(x2-x1);
else,%linear decreasing distribution with p(0) = 1 and p(1) = h (rejection technique)
    %
    x = NaN(N,1);
    %
    while isnan(sum(x)),
        x1 = rand(sum(isnan(x)),1);
        x2 = rand(sum(isnan(x)),1);
        x0 = NaN(sum(isnan(x)),1);
        %
        mask0 = x2 < 1 - (1-h)*x1;
        %
        x0(mask0) = x1(mask0);
        %
        inan = find(isnan(x) == 1);
        x(inan) = x0;
    end
end
%
y = (ybounds(2)-ybounds(1))*x + ybounds(1);
py = -((1-h)*y - ybounds(2) + h*ybounds(1))/(ybounds(2)-ybounds(1));
%
if display_mode,
    if N/100 > 100,%for good statistics
        [h1,z1] = hist(y,100);
        close all
        plot(z1,h1/max(h1),'r',y,py,'b')
        axis([ybounds(1),ybounds(2),0,1])
    else
        warning('Not enough points for histogram display');
    end
end