function [profile] = make_helprof_yp(profparam)
%
% Create input file and run HELENA magnetic equilibrium solver C3PO/LUKE
%
% INPUT:
%   
%   - profparam: profiles input structure
%
% OUTPUT:
%
%   - profile: pressure and current profile structure for HELENA
%
% by Y. PEYSSON, CEA-DRFC (yves.peysson@cea.fr) and J. DECKER (joan.decke@cea.fr) 
%
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum,alpha,kB] = pc_dke_yp;
%
profile.npts = profparam.nr;
x = linspace(0,1,profile.npts);%Radial grid (may be psi or sqrt(psi)~rho)
dx = x(2) - x(1);
%
pTe = (profparam.Te0 - profparam.Tea)*(1 - x.^profparam.eTe1).^profparam.eTe2 + profparam.Tea;%Electron temperature (keV)
pne = (profparam.ne0 - profparam.nea)*(1 - x.^profparam.ene1).^profparam.ene2 + profparam.nea;%Electron density (m-3)
pTi = (profparam.Ti0 - profparam.Tia)*(1 - x.^profparam.eTi1).^profparam.eTi2 + profparam.Tia;%Ion temperatures (keV)
%
pZeff = 0.5*(profparam.Zeffa - profparam.Zeff0)*tanh(profparam.eZeff*(x - profparam.xZeff)) + 0.5*(profparam.Zeffa + profparam.Zeff0);%Effective charge (a.u.)
%
% Ion parameters
%
pzTi = repmat(pTi,[length(profparam.Zi),1]);%Same temperature for all ion species
pzni = species_dke_yp(x,pZeff,profparam.Zi,profparam.fi);
%
profile.gradxp = (pTe.*pne + sum(pzni.*pzTi))*1000*1.16e4*kB;%plasma pressure profile (Pa)
profile.current = (profparam.j0 - profparam.ja)*(1 - x.^2).^profparam.ej + profparam.ja;%current density profile (m-3)
%
if profparam.gridtype == 1,%sqrt(psi) grid
    profile.ipai = 11;
    profile.icur = 11;
else,%psi grid
    profile.ipai = 7;
    profile.icur = 2;
end


