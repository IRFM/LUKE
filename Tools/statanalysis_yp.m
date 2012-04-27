function [iy,y,ym,ys,yr,iyr] = statanalysis_yp(yin,yt,display_mode)
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
%       - iyr: rejected index [1,m-p]
%
% by Y. Peysson DRFC-CEA <yves.peysson@cea.fr> and J. Decker DRFC-CEA <joan.decker@cea.fr> 
%
if nargin < 3,
    display_mode = 0;% default value, no display
end
%
if nargin < 2,
    yt = NaN;% default value, two times the standard deviation
end
%
nyin = length(yin);
y = yin;
ny = nyin;
%
ymask = true(1,ny);% mask of valid indices
%
ym = mean(y);
ys = std(y);
yd = ny*ys/ym;
yr = Inf;
%
while ny > 1,%abs(yr) > abs(yt),%
    %
    iyc = find(abs(y - ym) == max(abs(y - ym)),1,'first');% find value furthest from average
    %
    y(iyc) = [];
    %
    ymc = mean(y);
    ysc = std(y);
    ydc = ny*ysc/ymc;
    %
    yr = abs(yd - ydc);
    %
    if isnan(yt),
        yrmax = 3*ys/ym;
    else
        yrmax = yt;
    end
    %
    if yr <= yrmax,
        break
    end
    %
    % take away rejected index
    %
    yind = find(ymask);
    ymask(yind(iyc)) = false;
    ny = ny - 1;
    %
    ym = ymc;
    ys = ysc;
    yd = ny*ys/ym;
    %
end
%
iy = find(ymask);
iyr = find(~ymask);
y = yin(ymask);
%
if display_mode >= 2,
    %
    figure(1),clf
    %
    graph1D_jd(1:nyin,yin/ym,0,0,'n','y/ym','',NaN,[0,nyin+1],NaN,'-','+','r',2,20+14i,gca,0.9,0.7,0.7);
    graph1D_jd(iy,y/ym,0,0,'','','',NaN,[0,nyin+1],NaN,'none','o','b',2,20+14i);
    %
    graph1D_jd([0,nyin+1],[1+yrmax,1+yrmax],0,0,'','','',NaN,[0,nyin+1],NaN,'--','none','k',2,20+14i);
    graph1D_jd([0,nyin+1],[1-yrmax,1-yrmax],0,0,'','','',NaN,[0,nyin+1],NaN,'--','none','k',2,20+14i);
    %
    graph1D_jd([0,nyin+1],[1+ys/ym,1+ys/ym],0,0,'','','',NaN,[0,nyin+1],NaN,'--','none','g',2,20+14i);
    graph1D_jd([0,nyin+1],[1-ys/ym,1-ys/ym],0,0,'','','',NaN,[0,nyin+1],NaN,'--','none','g',2,20+14i);
    %
end
    
   
