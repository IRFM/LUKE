function graph_ohm_jd(equil,ohm,ax,font)
%
% This function plots the characteristics of ohmic data
%
if nargin < 4,
    font = struct;
end
if nargin < 3 || ~isscalar(ax) || ~ishandle(ax),
    figure
    ax = gca;
end
%
vloop = ohm.epsi*(2*pi*equil.Rp);
%
ylim = [min([vloop(:);0]),max([vloop(:)+eps;0])]*1.2;
% 
graph1D_jd(ohm.rho,vloop,0,0,'r/a','V_{loop} (V)','',NaN,[0,1],ylim,'-','none','r',2,font,ax);