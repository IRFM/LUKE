function [lspace,bspace,fpos_new,apos_new] = resizejd(ax,fac,lspace,bspace)

if nargin < 2
    bspace = NaN;
    lspace = NaN;
    fac = 1;
elseif nargin < 3
    bspace = NaN;
    lspace = NaN;
elseif nargin < 4
    bspace = NaN;
end

set(gcf,'units','normalized')
set(ax,'units','normalized')

fpos = get(gcf,'position');
apos = get(ax,'position');

%fl = fpos(1);
%fb = fpos(2);
%fw = fpos(3);
%fh = fpos(4);

al = apos(1);
ab = apos(2);
aw = apos(3);
ah = apos(4);

%figratio = fh/fw;

%fl_new = 0.1;
%fw_new = 0.9;
%fh_new = figratio*fw_new;
%fb_new = (1 - fh_new)/2;

if length(fac) == 1
    aw_new = fac*aw;
    ah_new = fac*ah;
else
    aw_new = fac(1)*aw;
    ah_new = fac(2)*ah;
end    

if isnan(lspace)
    lspace = al/(1 - aw);
end
if isnan(bspace)
    bspace = ab/(1 - ah);
end

al_new = lspace*(1 - aw_new);
ab_new = bspace*(1 - ah_new);

fpos_new = fpos;%[fl_new,fb_new,fw_new,fh_new];
apos_new = [al_new,ab_new,aw_new,ah_new];
set(gcf,'position',fpos_new);
set(ax,'position',apos_new);
    







