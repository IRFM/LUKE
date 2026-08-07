% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function graph_ohm_jd(equil,ohm,axs,font)
%
% This function plots the characteristics of ohmic data
%
if nargin < 4
    font = struct;
end
if nargin < 3 || ~ishandle(axs(1))
    figure
    ax = gca;
else
    ax = axs(1);
end
%
vloop = ohm.epsi*(2*pi*equil.Rp);
%
ylim = [min([vloop(:);0]),max([vloop(:)+eps;0])]*1.2;
% 
graph1D_jd(ohm.rho,vloop,0,0,'r/a','V_{loop} (V)','',NaN,[0,1],ylim,'-','none','r',2,font,ax);
%
if nargin < 3 || ~ishandle(axs(2))
    figure
    ax = gca;
else
    ax = axs(2);
end
%
E_c = Ecritical_jd(equil,ohm.rho);
EoEc = abs(ohm.epsi)./E_c;
% 
graph1D_jd(ohm.rho,EoEc,0,0,'r/a','|E|/E_c','',NaN,[0,1],NaN,'-','none','r',2,font,ax);

