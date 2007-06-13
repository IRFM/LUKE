function [equil] = equil_helprof_yp(profparam,equil_in)
%
% Calculate the profile part of the LUKE magnetic equilibrium structure
%
% INPUT:
%   
%   - profparam: input filename 'luke' from HELENA code
%   - equil_in: input magnetic equilibrium calculated by HELENA
%
% OUTPUT:
%
%   - equil: profile part of the magnetic equilibrium LUKE structure
%
% by Y. PEYSSON, CEA-DRFC (yves.peysson@cea.fr) and J. DECKER (joan.decke@cea.fr) 
%
equil.zZi = profparam.Zi;
equil.zmi = profparam.mi;
%
if profparam.gridtype == 1
    x = sqrt(equil_in.psi_apRp/equil_in.psi_apRp(end));
elseif profparam.gridtype == 0,
    x = equil_in.psi_apRp/equil_in.psi_apRp(end);
end
x = x(:)';
%
equil.pTe = (profparam.Te0 - profparam.Tea)*(1 - x.^profparam.eTe1).^profparam.eTe2 + profparam.Tea;%Electron temperature (keV)
equil.pne = (profparam.ne0 - profparam.nea)*(1 - x.^profparam.ene1).^profparam.ene2 + profparam.nea;%Electron density (m-3)
%
pTi = (profparam.Ti0 - profparam.Tia)*(1 - x.^profparam.eTi1).^profparam.eTi2 + profparam.Tia;%Ion temperatures (keV)
pZeff = 0.5*(profparam.Zeffa - profparam.Zeff0)*tanh(profparam.eZeff*(x - profparam.xZeff)) + 0.5*(profparam.Zeffa + profparam.Zeff0);%Effective charge (a.u.)
%
equil.pzTi = repmat(pTi,[length(profparam.Zi),1]);%Same temperature for all ion species
equil.pzni = species_dke_yp(x,pZeff(:)',profparam.Zi,profparam.fi);
  
