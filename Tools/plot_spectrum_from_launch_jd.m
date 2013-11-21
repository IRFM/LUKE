function plot_spectrum_from_launch_jd(launch,xlim,p_opt,select)
%
if nargin < 4,
    select = struct;
end
%
if nargin < 3,
    p_opt = -1;
end
%
if nargin < 2,
    xlim = NaN;
end
%
if isfield(select,'style'),
    style = select.style;
else
    style = struct;
end
%
yN = launch.bNpar0;
ydN = launch.bdNpar0;
yP = launch.bPlhtot/1e6;
%
ny = length(yN);
%
dx = min(ydN)/10;
x = (min(yN) - 4*max(ydN)):dx:(max(yN) + 4*max(ydN));
nx = length(x);
%
xyN = repmat(yN,[nx,1]);
xyP = repmat(yP,[nx,1]);
xydN = repmat(ydN,[nx,1]);
xy = repmat(x.',[1,ny]);
%
xyf = xyP.*exp(-(xy - xyN).^2./xydN.^2)./sqrt(pi)./xydN;
xf = sum(xyf,2);
%
if isfield(select,'axs'),
    ax = select.axs(1);
    set(ax,'Visible','on');
    red = 1;
    lspace = NaN;
    bspace = NaN;
else
    fig1 = figure('Name','Gaussian fit vs. ALOHA');
    ax = gca;
    red = 0.9;
    lspace = 0.7;
    bspace = 0.5;
end
%
graph1D_jd(x,xf,0,0,'n_{||}','dP/dn_{||} (MW)','',NaN,xlim,NaN,'-','none','r',2,style,ax,red,lspace,bspace);
graph1D_jd([0,0],get(gca,'ylim'),0,0,'','','',NaN,xlim,NaN,'-','none','k',2,style,ax);
set(gca,'xtick',[-16:2:16])
%
print_jd(p_opt,['Fig_',launch.id,'_spectrum'],NaN,1);
