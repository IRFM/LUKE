function plot_spectrum_from_launch_jd(launch,xlim,p_opt)
%
if nargin < 3,
    p_opt = -1;
end
if nargin < 2,
    xlim = NaN;
end
%
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
figure(1),clf
%
graph1D_jd(x,xf,0,0,'n_{||}','dP/dn_{||} (MW)','',NaN,xlim,NaN,'-','none','r',2,20+14i,gca,0.9,0.7,0.7);
graph1D_jd([0,0],get(gca,'ylim'),0,0,'','','',NaN,xlim,NaN,'-','none','k',2,20+14i);
set(gca,'xtick',[-16:2:16])
%
print_jd(p_opt,['Fig_',launch.id,'_spectrum'],NaN,1);
