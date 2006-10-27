function [ax] = graph1D_jd(x,y,logx,logy,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width,siz,ax,red,lspace,bspace,eym,eyp);

if nargin < 19
    bspace = NaN;
end
if nargin < 18
    lspace = NaN;
end
if nargin < 17
    red = 1;
end
if nargin < 16
    ax = gca;
end
if nargin < 15
    siz = 20;
end
if nargin < 14
    width = 0.5;
end
if nargin < 13
    color = NaN;
end
if nargin < 12
    marker = 'none';
end
if nargin < 11
    style = '-';
end
if nargin < 10
    ylim = NaN;
end
if nargin < 9
    xlim = NaN;
end
if nargin < 8
    leg = NaN;
end
if nargin < 7
    tit = '';
end
if nargin < 6
    ylab = '';
end
if nargin < 5
    xlab = '';
end
if nargin < 4
    logy = 0;
end
if nargin < 3
    logx = 0;
end
if nargin < 2
    y = x(:);
    x = 1:length(y);
end
if nargin == 0
    error('no argument')
end
%
hold on
if logx == 1 & logy ~= 1
    set(ax,'xscale','log');
    gcl = semilogx(x,y,'parent',ax);
elseif logx ~= 1 & logy == 1
    set(ax,'yscale','log');
    gcl = semilogy(x,y,'parent',ax);
elseif logx == 1 & logy == 1
    set(ax,'xscale','log');
    set(ax,'yscale','log');
    gcl = loglog(x,y,'parent',ax);
else
    if nargin >= 20,
     gcl = errorbar(x,y,eym,eyp,'parent',ax);
    else
        gcl = plot(x,y,'parent',ax);
    end

end
hold off
%
set(gcl,'linewidth',width);
set(gcl,'linestyle',style);
set(gcl,'marker',marker);
if ~isnan(color)
    set(gcl,'color',color);
end
%
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
%
if ~isempty(xlab),xl = xlabel(xlab);set(xl,'fontsize',siz);end
if ~isempty(ylab),yl = ylabel(ylab);set(yl,'fontsize',siz);end
if ~isempty(tit),tl = title(tit);set(tl,'fontsize',siz);end
if ~isnan(leg)
    lg = legend(leg);
    set(lg,'fontsize',siz);
end
%
set(gca,'fontsize',siz);
%
ax = gca;
%
set(gcf,'PaperPositionMode','auto');
%
[lspace_out,bspace_out,apos_new] = resizejd(gca,red);
if isnan(lspace)
    lspace = lspace_out;
end
if isnan(bspace)
    bspace = bspace_out;
end

[lspace_out,bspace_out,apos_new] = resizejd(gca,1,lspace,bspace);

box on
grid on