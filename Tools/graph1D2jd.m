function [ax] = graph1D2jd(x1,y1,x2,y2,xlab,ylab1,ylab2,tit,xlim,ylim1,ylim2,...
    style1,marker1,color1,width1,style2,marker2,color2,width2,red,lspace,bspace);

if nargin < 23
    bspace = NaN;
end
if nargin < 22
    lspace = NaN;
end
if nargin < 21
    red = 1;
end
if nargin < 20
    ax = gca;
end

ax = plotyy(x1,y1,x2,y2);

line1 = get(ax(1),'children');
line2 = get(ax(2),'children');

set(line1,'linewidth',width1);
set(line2,'linewidth',width1);
set(line1,'linestyle',style1);
set(line2,'linestyle',style2);
set(line1,'marker',marker1);
set(line2,'marker',marker2);


if ~isnan(xlim)
    set(ax(1),'xlim',xlim);
    set(ax(2),'xlim',xlim);
end
if ~isnan(ylim1)
    set(ax(1),'ylim',ylim1);
end
if ~isnan(ylim2)
    set(ax(2),'ylim',ylim2);
end

xl = xlabel(xlab);set(xl,'fontsize',24);


yl1 = get(ax(1),'ylabel');set(yl1,'string',ylab1,'fontsize',24);
yl2 = get(ax(2),'ylabel');set(yl2,'string',ylab2,'fontsize',24);
tl = title(tit);set(tl,'fontsize',24);

if ~isnan(color1)
    set(line1,'color',color1);
    set(ax(1),'ycolor',color1);
    set(yl1,'color',color1);
end
if ~isnan(color2)
    set(line2,'color',color2);
    set(ax(2),'ycolor',color2);
    set(yl2,'color',color2);
end
set(ax(1),'xcolor','k');
set(ax(2),'xcolor','k');

set(ax,'fontsize',24);

set(gcf,'PaperPositionMode','auto');

[lspace_out,bspace_out,fpos_new,apos_new] = resizejd(ax(1),red);
[lspace_out,bspace_out,fpos_new,apos_new] = resizejd(ax(2),red);

if isnan(lspace)
    lspace = lspace_out;
end
if isnan(bspace)
    bspace = bspace_out;
end

[lspace_out,bspace_out,fpos_new,apos_new] = resizejd(ax(1),1,lspace,bspace);
[lspace_out,bspace_out,fpos_new,apos_new] = resizejd(ax(2),1,lspace,bspace);

box on
grid on