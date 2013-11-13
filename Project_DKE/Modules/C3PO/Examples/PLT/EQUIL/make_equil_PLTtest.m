%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <jodecker@alum.mit.edu> and Y. Peysson <yves.peysson@cea.fr>
%   Created Feb. 17, 2004
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
npsi = 101;% number of points in psi grid
ntheta = 65;% number of points in theta grid
qopt = 1;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), 
%                               (1): linear (psi=rho),
%                               (2):  from qmin and eq
%
% Equilibrium parameters
%
Rp = 1.32;%Plasma major radius on axis (m)
Zp = 0.0; 
ap = 0.303*Rp;%  Inverse aspect ratio
Ip = 0.2;% Signed value of the plasma current (MA) (with R,Z,phi direct)
Bt = 3.1;%  Signed value of the toroidal magnetic field on the magnetic axis (T) (with R,Z,phi direct)
%
Zi = [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
qmin_Rpap = 1*Rp/ap;%  Safety factor q0 at plasma center
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
% Plasma parameters
%
[prho,equil_prof.pTe,equil_prof.pne,equil_prof.pzTi,equil_prof.pzni,equil_prof.zZi,equil_prof.zmi,equil_prof.fi,pkin] = idealprof_yp(Zi,mi,fi,Te0,Tea,eTe,NaN,ne0,nea,ene,NaN,Ti0,Tia,eTi,NaN,Zeff0,Zeffa,eZeff,NaN,npsi);%Profiles
%
%Magnetic equilibrium
%
[ppsin,equil_mag.psi_apRp,equil_mag.theta,equil_mag.ptx,equil_mag.pty,equil_mag.ptBx,equil_mag.ptBy,equil_mag.ptBPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(ap,Rp,Zp,Bt,Ip,qmin_Rpap,eq,qopt,npsi,ntheta);%Cylindrical magnetic equilibrium
%
equil_mag.Rp = Rp;
equil_mag.Zp = Zp;
%
equil = conc_struct_jd(equil_mag,equil_prof);
equil.id = 'PLTtest';% scenario identification (see paper Plasma Phys. Control. Fusion 41 (1999) 1231 - J.A. Heikkinen et al.)
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])
