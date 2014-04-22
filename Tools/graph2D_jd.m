function [ax] = graph2D_jd(x,y,Z,xlab,ylab,tit,xlim,ylim,fill,maxw,cont,lab,style,color,width,font,red,Z_0,ax)

if nargin < 19
    ax = gca;
end
if nargin < 18
    Z_0 = NaN;
end
if nargin < 17
    red = 1;
end
if nargin < 16
    font.fontsize = 20+14i;
    font.fontname = 'Times';%'Courier';
elseif ~isstruct(font),
    fontsize = font;
    font = struct;
    font.fontsize = fontsize;
    font.fontname = 'Times';%'Courier';
else
    if ~isfield(font,'fontsize'),
        font.fontsize = 20+14i;
    end
    if ~isfield(font,'fontname'),
        font.fontname = 'Times';%'Courier';
    end
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
    maxw = NaN;
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
if ~isnan(maxw)
    if isnan(Z_0)
        Z_0 = Z((length(x)+1)/2,1);
    end
    Z = Z + eps*(Z==0);
    lnZ = log(Z/Z_0);
    Z = sqrt(maxw^2*lnZ.^2 - 2*lnZ);
end
%
%hold on
if ~isnan(color)
    if fill == 0
        if ~isnan(cont)
            [C,H] = contour(ax,x,y,Z',cont,color);
        else
            [C,H] = contour(ax,x,y,Z',color);
        end 
    else
        if ~isnan(cont)
            [C,H] = contourf(ax,x,y,Z',cont,color);
        else
            [C,H] = contourf(ax,x,y,Z',color);
        end 
    end
else
    if fill == 0
        if ~isnan(cont)
            [C,H] = contour(ax,x,y,Z',cont);
        else
            [C,H] = contour(ax,x,y,Z');
        end 
    else
        if ~isnan(cont)
            [C,H] = contourf(ax,x,y,Z',cont);
        else
            [C,H] = contourf(ax,x,y,Z');
        end 
    end
end    
%
if any(isnan(color)) && ~any(isnan(cont)) && length(cont) > 1,
    caxis(ax,[min(cont),max(cont)]);
end
%hold off
%
set(H,'linewidth',width);
if ~isnan(style)
    set(H,'linestyle',style);
end
%
if lab ~= 0
    clabel(C,H,'manual','fontsize',font.fontsize,'fontname',font.fontname);%,'fontsize',14
end
if ~isnan(xlim)
    set(ax,'xlim',xlim);
end
if ~isnan(ylim)
    set(ax,'ylim',ylim);
end
%
if ~isempty(xlab),
    xl = xlabel(ax,xlab);set(xl,'fontsize',font.fontsize,'fontname',font.fontname);
end
if ~isempty(ylab),
    yl = ylabel(ax,ylab);set(yl,'fontsize',font.fontsize,'fontname',font.fontname);
end
if ~isempty(tit),
    tl = title(ax,tit);set(tl,'fontsize',font.fontsize,'fontname',font.fontname);
end
%
set(ax,'fontsize',font.fontsize,'fontname',font.fontname);
%
[lspace,bspace,apos_new] = resizejd(ax,red);
%
box on