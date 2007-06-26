function [ax] = graph2D_jd(x,y,Z,xlab,ylab,tit,xlim,ylim,fill,max,cont,lab,style,color,width,siz,red,Z_0)

if nargin < 18
    Z_0 = NaN;
end
if nargin < 17
    red = 1;
end
if nargin < 16
    siz = 20;
end
if nargin < 15
    width = 0.5;
end
if nargin < 14
    color = NaN;
end
if nargin < 13
    style = NaN;
end
if nargin < 12
    lab = 0;
end
if nargin < 11
    cont = NaN;
end
if nargin < 10
    max = NaN;
end
if nargin < 9
    fill = 0;
end
if nargin < 8
    ylim = NaN;
end
if nargin < 7
    xlim = NaN;
end
if nargin < 6
    tit = '';
end
if nargin < 5
    ylab = '';
end
if nargin < 4
    xlab = '';
end
if nargin < 3
    Z = y;
    y = 1:size(Z,2);
end
if nargin < 2
    Z = x;
    x = 1:size(Z,1);
    y = 1:size(Z,2);
end
if nargin == 0
    error('no argument')
end
%
%x = x(:);
%y = y(:);
%
if ~isnan(max)
    if isnan(Z_0)
        Z_0 = Z((length(x)+1)/2,1);
    end
    Z = Z + eps*(Z==0);
    lnZ = log(Z/Z_0);
    Z = sqrt(max^2*lnZ.^2 - 2*lnZ);
end
%
hold on
if ~isnan(color)
    if fill == 0
        if ~isnan(cont)
            [C,H] = contour(x,y,Z',cont,color);
        else
            [C,H] = contour(x,y,Z',color);
        end 
    else
        if ~isnan(cont)
            [C,H] = contourf(x,y,Z',cont,color);
        else
            [C,H] = contourf(x,y,Z',color);
        end 
    end
else
    if fill == 0
        if ~isnan(cont)
            [C,H] = contour(x,y,Z',cont);
        else
            [C,H] = contour(x,y,Z');
        end 
    else
        if ~isnan(cont)
            [C,H] = contourf(x,y,Z',cont);
        else
            [C,H] = contourf(x,y,Z');
        end 
    end
end    
hold off
%
set(H,'linewidth',width);
if ~isnan(style)
    set(H,'linestyle',style);
end
%
if lab ~= 0
    clabel(C,H,'manual');%,'fontsize',14
end
if ~isnan(xlim)
    set(gca,'xlim',xlim);
end
if ~isnan(ylim)
    set(gca,'ylim',ylim);
end
%
if ~isempty(xlab),
    xl = xlabel(xlab);set(xl,'fontsize',siz);
end
if ~isempty(ylab),
    yl = ylabel(ylab);set(yl,'fontsize',siz);
end
if ~isempty(tit),
    tl = title(tit);set(tl,'fontsize',siz);
end
%
set(gca,'fontsize',siz);
%
ax = gca;
%
[lspace,bspace,apos_new] = resizejd(gca,red);
%
box on