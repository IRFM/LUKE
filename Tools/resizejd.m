function [lspace,bspace,apos_new] = resizejd(ax,fac,lspace,bspace)

if nargin < 4
    bspace = NaN;
end
if nargin < 3
    lspace = NaN;
end
if nargin < 2
    fac = 1;
end
%
set(ax,'units','normalized')
apos = get(ax,'position');
%
al = apos(1);
ab = apos(2);
aw = apos(3);
ah = apos(4);
%
if length(fac) == 1
    aw_new = fac*aw;
    ah_new = fac*ah;
else
    aw_new = fac(1)*aw;
    ah_new = fac(2)*ah;
end    
%
if isnan(lspace)
    lspace = al/(1 - aw);
end
if isnan(bspace)
    bspace = ab/(1 - ah);
end
%
al_new = lspace*(1 - aw_new);
ab_new = bspace*(1 - ah_new);
%
apos_new = [al_new,ab_new,aw_new,ah_new];
set(ax,'position',apos_new);
%







