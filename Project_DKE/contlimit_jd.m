function [x1c,x2c,col] = contlimit_jd(x1d,x2d,fd,cont,cond,sfac);
%
% This function gives the contour parametrization (x1c,x2c) calculated from
% the 2D data (x1d,x2d,fd) and contour number (or levels) cont, plotting
% the contours only in the 2D zone defined by cond(x1,x2)
%
% if cont
%
% by J. Decker (jodecker@alum.mit.edu) 10/11/04
%
if nargin < 6
    sfac = 1;
end
if nargin < 5
    cond = NaN;
end
if nargin < 4 | isempty(cont) | isnan(cont)
    cont = 10;
end
%
cont = cont(:);
%
fmin = min(min(fd));
fmax = max(max(fd));
%
if length(cont) < 2 & cont ~= 0 & cont == round(cont),%number of contour is given
    df = (fmax - fmin)/(abs(cont) + 1);
    if fmin*fmax >= 0
        cont = fmin:df:fmax;
    elseif cont < 0 
        cont = sort([-df/2:-df:fmin,df/2:df:fmax]);
    else
        cont = sort([0:-df:fmin,df:df:fmax]);
    end
else
    fmin = min(cont);
    fmax = max(cont);
end
%
C = contourc(x1d,x2d,fd,cont);
%
cmap = colormap;
clen = size(colormap,1);
%
lnum = 0;
col = {};
x1c = {};
x2c = {};
while ~isempty(C)
    lnum = lnum + 1;
    tlen = size(C,2);
    lev = C(1,1);
    len = C(2,1);
    line_1 = C(1,2:1+len);
    line_2 = C(2,2:1+len);
    %
    igrid = linspace(0,1,len);
    sgrid = linspace(0,1,(len-1)*sfac+1);
    line_1 = interp1(igrid,line_1,sgrid,'spline');
    line_2 = interp1(igrid,line_2,sgrid,'spline');
    %
    if ischar(cond)
        eval(['mask = ',cond,'(line_1,line_2);']);
    elseif length(cond) == 4
        mask = line_1 >= cond(1) & line_1 <= cond(2) & line_2 >= cond(3) & line_2 <= cond(4);
    else
        mask = 1:len;
    end
    col{lnum} = cmap(1+round(((lev-fmin)/(fmax-fmin))*(clen-1)),:);
    x1c{lnum} = line_1(mask);
    x2c{lnum} = line_2(mask);
    C = C(:,len+2:tlen);
end







