%
%   This script generates the data file of an ideal circular equilibrium based on
%   equilibrium profile parameters
%
%   By J. Decker <DRFC/DSM/IRFM, joan.decker@cea.fr> and Y. Peysson <DRFC/DSM/IRFM, yves.peysson@cea.fr>
%
clear all
%
id = 'TScirc_peak';% scenario identification
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
npsi = 101;% number of points in psi grid
ntheta = 65;% number of points in theta grid
qopt = 0;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), (1): from qmin and eq 
%
% Equilibrium parameters
%
ap = 0.7;%  Plasma minor radius on LFS midplane (m)
Rp = 2.4;%  Plasma major radius on axis (m)
Zp = 0;%  Global plasma vertical shift (m)
Ip = 1.0;% Signed value of the plasma current (MA) (with R,Z,phi direct)
Bt = 3.6;%  Signed value of the toroidal magnetic field on the magnetic axis (T) (with R,Z,phi direct)
%
Zi = [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi = [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi = [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
qmin = NaN;%  Safety factor q0 at plasma center
eq = NaN;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
%
beta0 = 0.1;% 
%
Te0 = beta0^2*mc2;%  Core electron temperature (keV)
Tea = 0.01*Te0;%  Edge electron temperature (keV)
eTe = 3;%  Exponent for Te profile (Te(r) = (Te0-Tea)*(1-(r/a)^2)^eTe + Tea)
%
ne0 = 2.0e19;%  Core electron density (m-3)
nea = 0.01*ne0;%  Edge electron density (m-3)
ene = 1;%  Exponent for ne profile (ne(r) = (ne0-nea)*(1-(r/a)^2)^ene + nea)
%
Ti0 = Te0;%  Core ion temperature (keV)
Tia = 0.01*Ti0;%  Edge ion temperature (keV)
eTi = 1;%  Exponent for Ti profile (Ti(r) = (Ti0-Tia)*(1-(r/a)^2)^eTi + Tia)
%
Zeff0 = 1;%  Core effective charge (a.u.)
Zeffa = 1;%  Edge effective charge (a.u.)
eZeff = 0;%  Exponent for the effective charge (Zeff(r) = (Zeff0-Zeffa)*(1-(r/a)^2)^eZeff + Zeffa)
%
% Plasma parameters
%
[prho,equil_prof.pTe,equil_prof.pne,equil_prof.pzTi,equil_prof.pzni,equil_prof.zZi,equil_prof.zmi,fi,pkin] = idealprof_yp(Zi,mi,fi,Te0,Tea,2,eTe,ne0,nea,2,ene,Ti0,Tia,2,eTi,Zeff0,Zeffa,eZeff,NaN,npsi);%Profiles
%
%Magnetic equilibrium
%
[ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(ap,Rp,Zp,Bt,Ip,qmin*Rp/ap,eq,qopt,npsi,ntheta);%Cylindrical magnetic equilibrium
%
equil_magnetic.theta = theta;
equil_magnetic.ptx = x;
equil_magnetic.pty = y;
equil_magnetic.ptBx = Bx;
equil_magnetic.ptBy = By;
equil_magnetic.ptBPHI = BPHI;
%
equil_magnetic.psi_apRp = ppsi_apRp; %poloidal flux profile 
equil_magnetic.Rp = Rp;
equil_magnetic.Zp = Zp;
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
equil.id = id;
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equ