function [ax] = graph1D_jd(x,y,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width,siz,ax,red,lspace,bspace);

if nargin < 17
    bspace = NaN;
end
if nargin < 16
    lspace = NaN;
end
if nargin < 15
    red = 1;
end
if nargin < 14
    ax = gca;
end
if nargin < 13
    siz = 14;
end
if nargin < 12
    width = 0.5;
end
if nargin < 11
    color = NaN;
end
if nargin < 10
    marker = 'none';
end
if nargin < 9
    style = '-';
end
if nargin < 8
    ylim = NaN;
end
if nargin < 7
    xlim = NaN;
end
if nargin < 6
    leg = NaN;
end
if nargin < 5
    tit = '';
end
if nargin < 4
    ylab = '';
end
if nargin < 3
    xlab = '';
end
if nargin < 2
    y = x(:);
    x = 1:length(y);
end
if nargin == 0
    error('no argument')
end

gcl = line(x,y,'parent',ax);

set(gcl,'linewidth',width);
set(gcl,'linestyle',style);
set(gcl,'marker',marker);
if ~isnan(color)
    set(gcl,'color',color);
end

if ~isnan(xlim)
    set(gca,'xlim',xlim);
end
if ~isnan(ylim)
    if length(ylim) == 1
        ylim_old = get(gca,'ylim');
        if ylim_old(2) > ylim
            set(gca,'ylim',[ylim,ylim_old(2)]);
        else
            set(gca,'ylim',[ylim_old(1),ylim]);
        end            
    else
        set(gca,'ylim',ylim);
    end
end

xl = xlabel(xlab);set(xl,'fontsize',14);
yl = ylabel(ylab);set(yl,'fontsize',14);
tl = title(tit);set(tl,'fontsize',14);
if ~isnan(leg)
    lg = legend(leg);
    set(lg,'fontsize',14);
end

set(gca,'fontsize',14);

ax = gca;

set(gcf,'PaperPositionMode','auto');

[lspace_out,bspace_out,fpos_new,apos_new] = resizejd(gca,red);
if isnan(lspace)
    lspace = lspace_out;
end
if isnan(bspace)
    bspace = bspace_out;
end

[lspace_out,bspace_out,fpos_new,apos_new] = resizejd(gca,1,lspace,bspace);

box on
grid on