function graph_transp_jd(equil,transpfaste,axs,font)
%
% This function plots the characteristics of transpfaste data
%
if nargin < 4,
    font = struct;
end
if nargin < 3 || any(~ishandle(axs)),
    figure
    axs(1) = gca;
    figure
    axs(2) = gca;
end
%
xrho = equil.ptx(:,1)/equil.ptx(end,1);
%
xDr = transpfaste.Dr0*(1 + transpfaste.pDr*xrho.^2);
xVr = transpfaste.Vr0*(1 + transpfaste.pVr*xrho.^2);
%
ylim1 = [min([xDr(:);0]),max([xDr(:)+eps;0])]*1.2;
ylim2 = [min([xVr(:);0]),max([xVr(:)+eps;0])]*1.2;
% 
graph1D_jd(xrho,xDr,0,0,'r/a','D_r (m^2/s)','',NaN,[0,1],ylim1,'-','none','r',2,font,axs(1));
graph1D_jd(xrho,xVr,0,0,'r/a','V_r (m/s)','',NaN,[0,1],ylim2,'-','none','r',2,font,axs(2));
