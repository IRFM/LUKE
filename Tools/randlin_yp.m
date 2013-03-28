function [y,y_th,py_th] = randlin_yp(N,h,ybounds,display_mode)
%
% Calculate the random variable with a linear decrease of the p.d.f. (normalized to 1 over the the domain).
%
% Input:
%
%   - N : number of trials [1,1]
%     (default = 100000)
%   - h : ratio between the pdf values at ybounds [1,1]
%     (default = 1)
%   - ybounds : range of the random variable [3,1] or [1,3] for example. If [1,3], f(1)/f(3) = 1/h, and if [3,1], f(1)/f(3) = h. If NaN or empty ybounds = [0,1]
%     (default [0,1])
%   - display_mode : display the numerical and theoretical p.d.f and display the distribution is > 0 and is the number of bin of theÒ histogram (0: no, > 1, yes) [1,1]
%     (default = 0)
%
% Output:
%
%   - y : random variable [N,1]
%   - y_th : theoretical random variable [N,1]
%   - py_th : theoretical p.d.f. normalized to 1 [N,1]
%
%   by Y. Peysson (CEA/DSM/IRFM) (yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM) (joan.decker@cea.fr)
%
if nargin < 1, 
    N = 100000;
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
        mask0 = x2 < (1 - (1-h)*x1);
        %
        x0(mask0) = x1(mask0);
        %
        inan = find(isnan(x) == 1);
        x(inan) = x0;
    end
end
%
if display_mode < 10;
    display_mode = 10;
    warning('display_mode must exceed 10 for a correct histogramm.');
end
%
y = (ybounds(2) - ybounds(1))*x + ybounds(1);
%
y_th = sort((ybounds(2) - ybounds(1))*linspace(0,1,N) + ybounds(1));%increasing order
py_th = (1 - (1 - h)*(y_th - ybounds(1))/(ybounds(2) - ybounds(1)))/abs((ybounds(2) - ybounds(1)))*2/(h+1);%p(y) = p(x)*abs(dx/dy) 
norm_th = trapz(y_th,py_th);
%
if display_mode,
    if N/display_mode > display_mode,%for good statistics, display_mode is the number of bin for the histogram
        [h1,y1] = hist(y,display_mode);
        py = h1*display_mode/N/(max(y1) - min(y1));
        norm = trapz(y1,py);
        close all
        figure(1),plot(y1,py,'b',y_th,py_th,'r')
        axis([min(ybounds(1),ybounds(2)),max(ybounds(1),ybounds(2)),min(py_th),max(py_th)])
        xlabel('y');ylabel('f(y)');
        if ybounds(2) > ybounds(1),
            title(['Linear distribution function between ',num2str(ybounds(1)),' and ',num2str(ybounds(2)),' -> f(',num2str(ybounds(1)),')/f(',num2str(ybounds(2)),') = ',num2str(1/h)])
            legend(['Numerical, norm. = ',num2str(norm)],['Theoretical, norm. = ',num2str(norm_th)],'Location','SouthWest')
        else
            title(['Linear distribution function between ',num2str(ybounds(1)),' and ',num2str(ybounds(2)),' -> f(',num2str(ybounds(1)),')/f(',num2str(ybounds(2)),') = ',num2str(h)])
            legend(['Numerical, norm. = ',num2str(norm)],['Theoretical, norm. = ',num2str(norm_th)],'Location','NorthWest')
        end
    else
        warning('Not enough points for histogram display -> set display_mode to ');
    end
end