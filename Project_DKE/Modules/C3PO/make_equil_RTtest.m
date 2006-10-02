%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
clear all
%
equil.id = 'RTtest';% scenario identification
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
npsi = 101;% number of points in psi grid
ntheta = 65;% number of points in theta grid
qopt = 2;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), 
%                               (1): linear (psi=rho),
%                               (2):  from qmin and eq
%
% Equilibrium parameters
%
cyl = 1;
Rp = 3.0*cyl;%  Plasma major radius on axis (m)
Zp = 0.0;
ep = 0.3/cyl;%  Inverse aspect ratio
Ip = 1;% Signed value of the plasma current (MA) (with R,Z,phi direct)
Bt = 3.0;%  Signed value of the toroidal magnetic field on the magnetic axis (T) (with R,Z,phi direct)
%
Zi = [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
qmin = 1;%  Safety factor q0 at plasma center
eq = 2;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
%
Te0 = 4.0;%  Core electron temperature (keV)
Tea = Te0/10;%  Edge electron temperature (keV)
eTe = 1.0;%  Exponent for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^2)^eTe + Tea)
%
ne0 = 3.0e19;%  Core electron density (m-3)
nea = 1e-10;%  Edge electron density (m-3)
ene = 1.0;%  Exponent for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^2)^ene + nea)
%
Ti0 = Te0;%  Core ion temperature (keV)
Tia = Ti0/10;%  Edge ion temperature (keV)
eTi = 1.0;%  Exponent for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^2)^eTi + Tia)
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
ap = ep*Rp;
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
equil.R = Rp + ap*Xrho.*cos(Xtheta);
equil.Z = Zp + ap*Xrho.*sin(Xtheta);
%
qmax = ep*cyl*abs(Bt/Bpa);%Cylindrical safety factor at the plasma edge
%
if qopt == 2,
    pq = (qmax - qmin)*prho.^eq + qmin;% Current profile defined by qmin and eq (q profile is taken independent of the cylindrical limit)
%
elseif qopt == 1 
    pq = qmax*prho;% Current profile defined with linear q (psin = rho)
    pq(1) = eps;
else
    pq = qmax*ones(1,npsi);% Current profile defined with constant q (uniform current density)
end
pBpp = sign(Bpa)*prho*ep*cyl*abs(Bt)./pq;
%
if qopt == 2,
    spBpp = triu(repmat((pBpp(1:npsi-1) + pBpp(2:npsi))'/2,[1,npsi-1]));
    pdprho = diff(prho);
    equil.ppsi = [0,ap*Rp*integral_dke_jd(pdprho,spBpp,1)'];
elseif qopt == 1 % analytical thus more accurate 
    equil.ppsi = ap*Rp*Bpa*prho;
    pBpp(1) = Bpa;
else % analytical thus more accurate 
    equil.ppsi = ap*Rp*Bpa*prho.^2/2;
end
%
XBpp = repmat(pBpp',[1,ntheta]);
equil.BR = -XBpp.*sin(Xtheta)*Rp./equil.R;
equil.BZ = XBpp.*cos(Xtheta)*Rp./equil.R;
equil.BPHI = Bt*Rp./equil.R;
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])