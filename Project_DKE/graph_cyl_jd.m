function [ax] = graph_cyl_jd(pn,mhu,Z,tit,xlim,ylim,max,cont,style,color,width,red,Z_0,cond)

if nargin < 14
    cond = NaN;
end
if nargin < 13
    Z_0 = NaN;
end
if nargin < 12
    red = 1;
end
if nargin < 11
    width = 0.5;
end
if nargin < 10
    color = NaN;
end
if nargin < 9
    style = NaN;
end
if nargin < 8
    cont = NaN;
end
if nargin < 7
    max = NaN;
end
if nargin < 6
    ylim = NaN;
end
if nargin < 5
    xlim = NaN;
end
if nargin < 4
    tit = '';
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
sfac = 10;
xlab = 'p_{//}/p_{Te}';
ylab = 'p_{\perp}/p_{Te}';
%
if ~isnan(max)%if max = betath, a Maxwellian distribution with temperature betath will have uniformly spaced contours
    if isnan(Z_0)
        Z_0 = max(max(Z));
    end
    Z = Z + eps*(Z==0);
    lnZ = log(Z/Z_0);
    Z = sqrt(max^2*lnZ.^2 - 2*lnZ);
end
%
[pn_c,mhu_c,col_c] = contlimit_jd(pn,mhu,Z,cont,cond,sfac);
%
nc = length(pn_c);
for ic = 1:nc
     ppar_c = pn_c{ic}.*mhu_c{ic};
     pperp_c = pn_c{ic}.*sqrt(1-mhu_c{ic}.^2);
     if isnan(color)
         col = col_c{ic};
     else
         col = color;
     end
%
     line(ppar_c,pperp_c,'color',col,'linewidth',width,'linestyle',style);
end
%
if ~isnan(xlim)
    set(gca,'xlim',xlim);
end
if ~isnan(ylim)
    set(gca,'ylim',ylim);
end
%
xl = xlabel(xlab);set(xl,'fontsize',20);
yl = ylabel(ylab);set(yl,'fontsize',20);
tl = title(tit);set(tl,'fontsize',20);
%
set(gca,'fontsize',20);
%
ax = gca;
%
[lspace,bspace,apos_new] = resizejd(gca,red);
%
box on

