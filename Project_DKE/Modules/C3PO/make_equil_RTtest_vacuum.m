%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
clear all
%
equil.id = 'RTtest_vacuum';% scenario identification (for diagnostic purposes)
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
qmin = 1;%  Safety factor q0 at plasma center
eq = 2;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
%
prho = linspace(0,1,npsi);%Uniform rho grid
equil.theta = linspace(0,2*pi,ntheta);% Uniform theta grid
%
% Plasma parameters
%
equil.zZi = [];%[1,ni]
equil.zmi = [];%[1,ni]
equil.fi = [];%[1,3]
equil.pTe = [];% Electron temperature (keV)
equil.pne = [];% Electron density (m-3)
equil.pzTi = [];% Same temperature for all ion species
equil.pzni = [];
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
    equil.psi = [0,ap*Rp*integral_dke_jd(pdprho,spBpp,1)'];
elseif qopt == 1 % analytical thus more accurate 
    equil.psi = ap*Rp*Bpa*prho;
    pBpp(1) = Bpa;
else % analytical thus more accurate 
    equil.psi = ap*Rp*Bpa*prho.^2/2;
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
equil.xypsi = Rp*Bpa*(xyx.^2 + xyy.^2)/2/ap;
equil.pF = Bt*Rp*ones(1,npsi);
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])