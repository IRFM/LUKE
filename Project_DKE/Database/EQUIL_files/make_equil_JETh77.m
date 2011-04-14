%
%   This script generates the data file of an magnetic equilibrium  created
%   by the HELENA magnetic equlibrium solver (helmex77 version)
%
%   By Y. Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM, joan.decker@cea.fr) 
%
clear all
close all
%
id = 'JETh77';% scenario identification
%
% Equilibrium parameters
%
% Here find the definitions for the shape of the separatrix
%
%   - R_sep = (R_sep_max + R_sep_min)/2, for the guess.
%   - a_sep = (R_sep_max - R_sep_min)/2, for the guess.
%   - Z_sep = Z(R_sep_max), for the guess.
%   - elongation_sep = (Z_sep_max - Z_sep_min)/2 (always positive) (xpoint(1) + xpoint(5) is approximately elongation_sep*a_sep)
%   - upper_triangularity_sep = (R_sep - R(Z_sep_max))/2 (always positive) xpoint(2) = upper_triangularity_sep*a_sep
%   - lower_triangularity_sep = (R_sep - R(Z_sep_min))/2 (always positive) xpoint(6) = lower_triangularity_sep*a_sep
%   
%
% if no upper X-point exists, xpoint(2) = xpoint(3) = 0. In this case,xpoint(1) is the upper altitude of the separatrix in minor radius unit.
% if no lower X-point exists, xpoint(7) = xpoint(8) = 0. In this case,xpoint(5) is the lower altitude of the separatrix in minor radius unit (always positive).
% if an upper X-point exists, xpoint(2) + xpoint(3) close to 90 degrees
% if an lower X-point exists, xpoint(7) + xpoint(8) close to 90 degrees
%
R_sep = 3.0;%  Geometrical major radius of the separatrix (m)
a_sep = 0.9;%  Geometrical minor radius of the separatrix (m)
Z_sep = 0.0;%  Geometrical vertical shift of the separatrix (m)
%
xpoint(1) = 1.687;%Upper altitude X point in minor radius unit
xpoint(2) = 0.466;%Upper triangularity in minor radius unit
xpoint(3) = 0;%Upper separatrix angle (R,X)  (LFS, degrees)
xpoint(4) = 0;%Upper separatrix angle (-R,X) (HFS, degrees)
xpoint(5) = 2.001;%Lower altitude X point in minor radius unit (always positive)
xpoint(6) = 0.568;%Lower triangularity in minor radius unit
xpoint(7) = 22.46;%Lower separatrix angle (R,X)  (LFS, degrees)
xpoint(8) = 67.92;%Lower separatrix angle (-R,X)  (HFS, degrees)
%
npsi = 101;%ONLY 101 radial profile grid points for HELMEX77
ntheta = 65;%ONLY 65 poloidal grid points for HELMEX77
%
Ip = 2;%  Plasma current (MA)  
%
qmin = 1;%  Safety factor q0 at plasma center
eq = 3;%  Exponent for q radial profile (q = (qmax - qmin)*(r/a).^eq + qmin, qmax calaculated by the Ampere's theorem at the plasma edge with a circular plasma cross-section)
qopt = 1;%Option for q profile. (0): constant (default, uniform current, psi=rho^2), (1): from qmin and eq 
%
Bt = 3.5;%  Toroidal magnetic field on the magnetic axis (T) 
%
% Kinetic parameters (profiles)
%
Zi =  [1,1,1,6];%  Ion types: (1) H/D/T, (2) He, ..., (6) C [1,p] (WARNING: Zi must be [1,1,1,imp1,imp2] for hydrogen plasmas)
mi =  [1,2,3,12];%  Ion mass (uma) [1,p] (WARNING: Zi must be [1,2,3,mimp1,mimp2] for hydrogen plasmas)
fi =  [0,1,0];%  Hydrogen isotopic fraction (H/D/T) [1,3] (WARNING: only used when hydrogen plasmas are considered)
%
Te0 = 5;%  Core electron temperature (keV)
Tea = 0.5;%  Edge electron temperature (keV)
eTe1 = 4;%  Exponent #1 for Te profile 
eTe2 = 2;%  Exponent #2 for Te profile 
%
ne0 = 2.0e19;%  Core electron density (m-3)
nea = 2.0e17;%  Edge electron density (m-3)
ene1 = 4;%  Exponent #1 for ne profile 
ene2 = 0.5;%  Exponent #2 for ne profile
%
Ti0 = 2;%  Core ion temperature (keV)
Tia = 0.2;%  Edge ion temperature (keV)
eTi1 = 4;%  Exponent #1 for Ti profile
eTi2 = 2;%  Exponent #2 for Ti profile
%
Zeff0 = 1.5;%  Core effective charge (a.u.)
Zeffa = 1.5;%  Edge effective charge (a.u.)
eZeff = 0;%  Define the slope at the radial point where the derivative is maximum (must be >> 1)
xZeff = 0.5;%Radial normalized position at which the derivative is maximum
%
% Initial calculations to set up the guess for HELMEX77 (cylindrical magnetic equilibrium with circular concentric flux surfaces)
%
% Magnetic data
%
[ppsin,ppsi_apRp,theta,x,y,Bx,By,BPHI,pBpp,pq_Rpap,pj,pmag,Ip_test] = idealequilcyl_yp(a_sep,R_sep,Z_sep,Bt,Ip,qmin*R_sep/a_sep,eq,qopt,npsi,ntheta);%Cylindrical magnetic equilibrium
%
[prho,pTe,pne,pzTi,pzni,zZi,zmi,fi,pkin] = idealprof_yp(Zi,mi,fi,Te0,Tea,eTe1,eTe2,ne0,nea,ene1,ene2,Ti0,Tia,eTi1,eTi2,Zeff0,Zeffa,eZeff,xZeff,npsi);%Profiles
%
figure('Name','Guess magnetic equilibrium'),
subplot(2,2,1),plot(prho,pj/1e6),xlabel('\rho');ylabel('j (MA/m^2)');title(['I_p = ',num2str(round(Ip_test)/1e6),' MA'])
subplot(2,2,2),plot(prho,pBpp),xlabel('\rho');ylabel('B_p(T)');title(['B_t ',num2str(Bt),' T'])
subplot(2,2,3),plot(prho,pq_Rpap*a_sep/R_sep),xlabel('\rho');ylabel('q')
subplot(2,2,4),plot(prho,ppsin),xlabel('\rho');ylabel('\psi_n')
%
pj_min = min(pj); 
if pj_min < 0,pj = pj - pj_min;end,%pj must be non-negative. Only the shape is considered and Ip for the total plasma current
[equil_magnetic,prho_out,pspsin_out,pspsinT_out,pp_out] = equil_magnetic_helmex77_yp(a_sep,R_sep,Z_sep,xpoint,Bt,Ip,ppsi_apRp*R_sep/a_sep,pj,pkin,ntheta,2);
%
[qe] = pc_dke_yp;
figure('Name','Pressure profile'),
subplot(121),plot(prho,pmag*qe*1000/100000),xlabel('\rho');ylabel('pressure (Bar)');title(['Guess magnetic']),axis('square')
subplot(122),plot(prho,pkin*qe*1000/100000,'b',prho_out,pp_out*qe*1000/100000,'r--'),xlabel('\rho');ylabel('pressure (Bar)');legend('Guess kinetic','HELENA'),axis('square')
%
equil_prof.pTe = pTe;
equil_prof.pne = pne;
equil_prof.pzTi = pzTi;
equil_prof.pzni = pzni;
equil_prof.zZi = zZi;
equil_prof.zmi = zmi;
%
equil = conc_struct_jd(equil_magnetic,equil_prof);
equil.id = id;
%
eval(['save EQUIL_',id,'.mat equil']);
%







