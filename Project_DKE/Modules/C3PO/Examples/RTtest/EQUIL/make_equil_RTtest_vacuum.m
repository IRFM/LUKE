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
%
% Equilibrium parameters
%
Rp = 3.0;%  Plasma major radius on axis (m)
Zp = 0.0;
ap = 0.3*Rp;%  Inverse aspect ratio
Ip = 1;% Signed value of the plasma current (MA) (with R,Z,phi direct)
Bt = 3.0;%  Signed value of the toroidal magnetic field on the magnetic axis (T) (with R,Z,phi direct)
%
qmin_Rpap = 1/0.3;%Safety factor q0_Rpap at plasma center normalized to Rp/ap
eq = 2;% Exponent for q_Rpap radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section) 
qopt = 1;%Option for q profile. 
%
equil_prof.theta = linspace(0,2*pi,ntheta);% Uniform theta grid
%
% Plasma parameters
%
equil_prof.zZi = [];%[1,ni]
equil_prof.zmi = [];%[1,ni]
equil_prof.fi = [];%[1,3]
equil_prof.pTe = [];% Electron temperature (keV)
equil_prof.pne = [];% Electron density (m-3)
equil_prof.pzTi = [];% Same temperature for all ion species
equil_prof.pzni = [];
%
%Magnetic equilibrium
%
[ppsin,equil_mag.psi_apRp,equil_mag.theta,equil_mag.ptx,equil_mag.pty,equil_mag.ptBx,equil_mag.ptBy,equil_mag.ptBPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(ap,Rp,Zp,Bt,Ip,qmin_Rpap,eq,qopt,npsi,ntheta);%Cylindrical magnetic equilibrium
%
equil_mag.Rp = Rp;
equil_mag.Zp = Zp;
%
equil = conc_struct_jd(equil_mag,equil_prof);
equil.id = 'RTtest_vacuum';%
%
filename = ['EQUIL_',equil.id,'.mat'];
%
eval(['save ',filename,' equil'])
%
