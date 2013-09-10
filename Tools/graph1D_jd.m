function [ax] = graph1D_jd(x,y,logx,logy,xlab,ylab,tit,leg,xlim,ylim,style,marker,color,width,font,ax,red,lspace,bspace,eym,eyp,exm,exp);

if nargin < 22
    exm = NaN;
    exp = NaN;
end
if nargin < 23
   exp = exm;
end
if nargin < 20
    eym = NaN;
    eyp = NaN;
end
if nargin < 21
    eyp = eym;
end
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
    font.fontsize = 20;
    font.fontname = 'Times';%'Courier';
elseif ~isstruct(font),
    font.fontsize = font;
    font.fontname = 'Times';%'Courier';
else
    if ~isfield(font,'fontsize'),
        font.fontsize = 20;
    end
    if ~isfield(font,'fontname'),
        font.fontname = 'Times';%'Courier';
    end
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
if imag(font.fontsize) == 0,
	font.fontsize = font.fontsize+i*font.fontsize;
end
%
hold(ax,'on');
% if logx == 1 & logy ~= 1
%     set(ax,'xscale','log');
%     gcl = semilogx(x,y,'parent',ax);
% elseif logx ~= 1 & logy == 1
%     set(ax,'yscale','log');
%     gcl = semilogy(x,y,'parent',ax);
% elseif logx == 1 & logy == 1
%     set(ax,'xscale','log');
%     set(ax,'yscale','log');
%     gcl = loglog(x,y,'parent',ax);
% else
    if ~all(isnan(eym(:))) || ~all(isnan(eyp(:)))
        gcl = errorbar(x,y,eym,eyp,'parent',ax);
    else        
        gcl = plot(x,y,'parent',ax);
    end
    %
    if ~all(isnan(exm)) || ~all(isnan(exp))
        gcxp = plot([x(:).';x(:).' + exp(:).'],[y(:).';y(:).'],'parent',ax);
        gcxm = plot([x(:).';x(:).' - exm(:).'],[y(:).';y(:).'],'parent',ax);
        set(gcxp,'marker','+','color',color);
        set(gcxm,'marker','+','color',color);
    end
% end
%
hold(ax,'off');
%
if logx == 1,
    set(ax,'xscale','log');
else
    set(ax,'xscale','linear');
end
%
if logy == 1,
    set(ax,'yscale','log');
else
    set(ax,'yscale','linear');
end
%
set(gcl,'linestyle',style);
set(gcl,'marker',marker);
%if ~strcmp(style,'none'),
    set(gcl,'linewidth',real(width));
%else
if imag(width) == 0,
    set(gcl,'markersize',8);
else
    set(gcl,'markersize',imag(width));
end
%end
if ~isnan(color)
    set(gcl,'color',color);
end
%
if ~isnan(xlim)
    set(ax,'xlim',xlim);
end
if ~isnan(ylim)
    if length(ylim) == 1
        ylim_old = get(ax,'ylim');
        if ylim_old(2) > ylim
            set(ax,'ylim',[ylim,ylim_old(2)]);
        else
            set(ax,'ylim',[ylim_old(1),ylim]);
        end            
    else
        set(ax,'ylim',ylim);
    end
end
%
if ~isempty(xlab),
    xl = xlabel(xlab);
    set(xl,'fontsize',real(font.fontsize),'fontname',font.fontname,'parent',ax);
end
if ~isempty(ylab),
    yl = ylabel(ylab);
    set(yl,'fontsize',real(font.fontsize),'fontname',font.fontname,'parent',ax);
end
if ~isempty(tit),
    tl = title(tit);
    set(tl,'fontsize',real(font.fontsize),'fontname',font.fontname,'parent',ax);
end
if iscell(leg) || ~any(isnan(leg)),
    Nleg = length(leg);
    if iscell(leg) && Nleg > 2 && strcmp(leg(Nleg - 1),'Location'),
        lg = legend(ax,leg(1:Nleg - 2),'location',leg{Nleg});
    else
        lg = legend(ax,leg,'location','best');
    end
    set(lg,'fontsize',imag(font.fontsize),'fontname',font.fontname);
end
%
set(ax,'fontsize',real(font.fontsize),'fontname',font.fontname);
%
set(gcf,'PaperPositionMode','auto');
%
[lspace_out,bspace_out,apos_new] = resizejd(ax,red);
if isnan(lspace)
    lspace = lspace_out;
end
if isnan(bspace)
    bspace = bspace_out;
end
%
[lspace_out,bspace_out,apos_new] = resizejd(ax,1,lspace,bspace);
%
box(ax,'on');
grid(ax,'on');