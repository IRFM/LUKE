function [iy,y,ym,ys,yr,iyr] = statanalysis_yp(yin,yt)
%
% This function calculates the mean value, the standard deviation, and the
% relative accuracy of the mean value. The function should exhibit a
% stationnary region (plateau)
%
%   INPUT :
%
%       - y: noisy signal [1,m]
%       - yt: minimum relative accuracy of the mean value [1,1]
%
%   OUTPUT :
%
%       - iy: valid index [1,p]
%       - y: noisy signal [1,p]
%       - ym: mean value [1,1]
%       - ys: standard deviation [1,1]
%       - yr: relative accuracy of the mean value [1,1]
%       - iyr: rejected index [1,p]
%
% by Y. Peysson DRFC-CEA <yves.peysson@cea.fr> and J. Decker DRFC-CEA <joan.decker@cea.fr> 
%
if nargin == 1,
    yt = 0.01;
end
%
y0 = yin;
y = yin;
yr = Inf;
iyr = [];
%
if yt > 0,
    while abs(yr) > abs(yt)
        ym = mean(y);
        ys = std(y);
        %
        yr1 = yr;
        yr = ys/ym/sqrt(length(y));
        yr2 = yr;
        %
        x = find(abs(y - ym) <= abs(ys));
        %
        y = y(x);
        if yr1 == yr2,break;end
    end
    %
    for i = 1:length(y),
        iy(i) = find(y0 == y(i));
    end
    %
    j = 1;
    for i = 1:length(y0),
        if isempty(find(iy == i)),
            iyr(j) = i;
            j = j + 1;
        end
    end
else
    y = yin;
    ym = mean(y);
    ys = std(y);
    yr = ys/ym/sqrt(length(y));
    iy = [1:length(y)];
    iyr = [];
end
%

