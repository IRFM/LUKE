%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
clear all
%
equil.id = 'PLTtest';% scenario identification
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
Rp = 1.32*cyl;%  Plasma major radius on axis (m)
Zp = 0.0;
ep = 0.303/cyl;%  Inverse aspect ratio
Ip = 0.2;% Signed value of the plasma current (MA) (with R,Z,phi direct)
Bt = 3.1;%  Signed value of the toroidal magnetic field on the magnetic axis (T) (with R,Z,phi direct)
%
Zi = [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
qmin = 1;%  Safety factor q0 at plasma center
eq = 2;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
%
Te0 = 1.5;%  Core electron temperature (keV)
Tea = 0.03;%  Edge electron temperature (keV)
eTe = 3.99;%  Exponent for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^2)^eTe + Tea)
%
ne0 = 0.5625e19;%  Core electron density (m-3)
nea = 0.5625e18;%  Edge electron density (m-3)
ene = -0.571;%  Exponent for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^2)^ene + nea)
%
Ti0 = 0.5;%  Core ion temperature (keV)
Tia = 0.03;%  Edge ion temperature (keV)
eTi = 2.90;%  Exponent for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^2)^eTi + Tia)
%
Zeff0 = 4;%  Core effective charge (a.u.)
Zeffa = 4;%  Edge effective charge (a.u.)
eZeff = 0;%  Exponent for the effective charge (Zeff(r) = (Zeff0-Zeffa)*(1-(r/a)^2)^eZeff + Zeffa)
%
equil.zZi = Zi;%[1,ni]
equil.zmi = mi;%[1,ni]
equil.fi = fi;%[1,3]
%
prho = linspace(0,1,npsi);%Uniform rho grid
equil.theta = linspace(0,2*pi,ntheta);% Uniform theta grid
%
% Plasma parameters (Bonoli's paper notation, IEEE Transactions on plasma
% science Vol. PS-12, No 2, june 1984, p100
%
equil.pTe = (Te0 - Tea)*(exp(-eTe*prho.^2) - exp(-eTe))/(1 - exp(-eTe)) + Tea;% Electron temperature (keV)
equil.pne = (ne0 - nea)*(exp(ene) - exp(ene*prho.^2))/(exp(ene) - 1) + nea;% Electron density (m-3)
pTi = (Ti0 - Tia)*(exp(-eTi*prho.^2) - exp(-eTi))/(1 - exp(-eTi)) + Tia;% Ion temperatures (keV)
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
equil.ptx = ap*Xrho.*cos(Xtheta);
equil.pty = ap*Xrho.*sin(Xtheta);
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
    equil.psi_apRp = [0,ap^2*integral_dke_jd(pdprho,spBpp,1)'];%psi_apRp = psi(toroidal usual)*ap/Rp for the cylindrical limit
elseif qopt == 1 % analytical thus more accurate 
    equil.psi_apRp = ap^2*Bpa*prho;%psi_apRp = psi(toroidal usual)*ap/Rp for the cylindrical limit
    pBpp(1) = Bpa;
else % analytical thus more accurate 
    equil.psi_apRp = ap^2*Bpa*prho.^2/2;%psi_apRp = psi(toroidal usual)*ap/Rp for the cylindrical limit
end
%
XBpp = repmat(pBpp',[1,ntheta]);
equil.ptBx = -XBpp.*sin(Xtheta)*Rp./(equil.ptx + Rp);
equil.ptBy = XBpp.*cos(Xtheta)*Rp./(equil.ptx + Rp);
equil.ptBPHI = Bt*Rp./(equil.ptx + Rp);
%
equil.Rp = Rp;
equil.Zp = Zp;
%
equil.x = linspace(-ap,ap,2*npsi-1);
equil.y = linspace(-ap,ap,2*npsi-1);
xyx = equil.x(:)*ones(1,2*npsi-1);
xyy = ones(2*npsi-1,1)*equil.y;
equil.xypsi_apRp = Bpa*(xyx.^2 + xyy.^2)/2;%psi_apRp = psi(toroidal usual)*ap/Rp for the cylindrical limit
equil.pF = Bt*Rp*ones(1,npsi);
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])