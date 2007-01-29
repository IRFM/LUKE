%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <joan.decker@cea.fr> and Y. Peysson <yves.peysson@cea.fr>
%  
%
clear all
%
equil.id = 'JETliketest';% scenario identification (see paper Plasma Phys. Control. Fusion 41 (1999) 1231 - J.A. Heikkinen et al.)
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
npsi = 101;% number of points in psi grid
ntheta = 65;% number of points in theta grid
%
% Equilibrium parameters
%
Rp = 3.05;%  Plasma major radius on axis (m)
ap = 0.95;%  Plasma minor radius on axis (m)
Zp = 0.0;
Ip = 3.5;% Signed value of the plasma current (MA) (with R,Z,phi direct)
Bt = 3.2;%  Signed value of the toroidal magnetic field on the magnetic axis (T) (with R,Z,phi direct)
%
Zi = [1,1,1];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = [1,2,3];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = [1,0,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
Te0 = 6.0;%  Core electron temperature (keV)
Tea = 0.1;%  Edge electron temperature (keV)
eTe = 1.5;%  Exponent for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^2)^eTe + Tea)
%
ne0 = 5.0e19;%  Core electron density (m-3)
nea = 0.01e19;%  Edge electron density (m-3)
ene = 1.0;%  Exponent for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^2)^ene + nea)
%
Ti0 = Te0;%  Core ion temperature (keV)
Tia = Tea;%  Edge ion temperature (keV)
eTi = eTe;%  Exponent for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^2)^eTi + Tia)
%
Zeff0 = 1;%  Core effective charge (a.u.)
Zeffa = 1;%  Edge effective charge (a.u.)
eZeff = 0;%  Exponent for the effective charge (Zeff(r) = (Zeff0-Zeffa)*(1-(r/a)^2)^eZeff + Zeffa)
%
equil.zZi = Zi;%[1,ni]
equil.zmi = mi;%[1,ni]
equil.fi = fi;%[1,3]
%
prho = linspace(0,1,npsi);%Uniform rho grid
equil.theta = linspace(0,2*pi,ntheta);% Uniform theta grid
%
% Plasma parameters
%
equil.pTe = (Te0 - Tea)*(1 - prho.^2).^eTe + Tea;% Electron temperature (keV)
equil.pne = (ne0 - nea)*(1 - prho.^2).^ene + nea;% Electron density (m-3)
pTi = (Ti0 - Tia)*(1 - prho.^2).^eTi + Tia;% Ion temperatures (keV)
%
pZeff = (Zeff0 - Zeffa)*(1 - prho.^2).^eZeff + Zeffa;% Effective charge (a.u.)
%
% Ion parameters
%
nz = length(equil.zZi);
equil.pzTi = repmat(pTi,[nz,1]);% Same temperature for all ion species
equil.pzni = species_dke_yp(equil.pne,pZeff,equil.zZi,fi);
%
ep = ap/Rp;%  Inverse aspect ratio
%
%Magnetic equilibrium
%
Bpa = (4*pi*1e-7)*Ip*1e6/(2*pi*ap);% Poloidal Field at the edge, Ampere's theorem (circular plasma cross-section)
%
%Note: The following calculations are valid only for a circular concentric equilibrium. 
%Moreover, in the following expressions, term of order (ap/Rp)^2 or higher are neglected.
%
Xrho = repmat(prho',[1,ntheta]);
Xtheta = repmat(equil.theta,[npsi,1]);
%
equil.ptx = ap*Xrho.*cos(Xtheta);
equil.pty = ap*Xrho.*sin(Xtheta);
%
pBpp = Bpa*(1 - (1 - prho.^2).^2)./prho;
pBpp(1) = 0;
%
equil.psi_apRp = ap^2*Bpa*prho.^2.*(1-prho.^2/4);
%
XBpp = repmat(pBpp',[1,ntheta]);
equil.ptBx = -XBpp.*sin(Xtheta)*Rp./(equil.ptx + Rp);
equil.ptBy = XBpp.*cos(Xtheta)*Rp./(equil.ptx + Rp);
equil.ptBPHI = Bt*Rp./(equil.ptx + Rp);
%
equil.Rp = Rp;
equil.Zp = Zp;
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])