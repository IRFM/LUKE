function [Nperpp,Nperpm,Kxyz,ep_xyz,em_xyz,ep_pmz,em_pmz,ep_pyk,em_pyk,phip_xyz,phim_xyz,phip_pmz,phim_pmz,phip_pyk,phim_pyk]...
    = colddisp_dke_jd(Npar,omega_rf,ne,zni,zZi,zmi,Bfield);
%
% This function solves the dispersion relation and the wave equation
% in the linear cold plasma model. It calculates the perpendicular index of
% refraction, the polarization and the power flow as a function of the wave
% frequency and the parallel index of refraction. 
%
% - (x,y,z): We assume that the magnetic field is in the z direction and the 
%           perpendicular index of refraction in the x direction. 
% - (p,m,z): p and m refer to the left hand and right hand rotating fields 
%           respectively.
% - (p,y,k): p and y are the transverse components of the polarization, with 
%           respect to the wave vector. k is the longitudinal component.
%
% The power flow is: phi = Re[e x (N x e*)] = Re[N - (N . e)e*]  
%
%   INPUTS: 
%
%       - Npar: parallel index of refraction [1,1]       
%       - omega_rf: wave frequency (rad/s) [1,1] 
%       - ne: electron density (m-3) [1,1]
%       - zni: ion density (m-3) [1,i]
%       - zZi: ion charges [1,i] 
%       - zmi: ion masses (mp) [1,i]  
%       - Bfield: magnetic field amplitude [1,1]
%
%   OUTPUTS:
%
%       - Nperpp: perpendicular index of refraction (root +) [1,1]
%       - Nperpm: perpendicular index of refraction (root -) [1,1] 
%       - Kxyz: cold plasma dielectric tensor elements [3,3]
%       - ep_xyz: polarization vector in the (x,y,z) coordinates (root +) [3,1]
%       - em_xyz: polarization vector in the (x,y,z) coordinates (root -) [3,1] 
%       - ep_pmz: polarization vector in the (p,m,z) coordinates (root +) [3,1] 
%       - em_pmz: polarization vector in the (p,m,z) coordinates (root -) [3,1]  
%       - ep_pyk: polarization vector in the (p,y,k) coordinates (root +) [3,1]  
%       - em_pyk: polarization vector in the (p,y,k) coordinates (root -) [3,1] 
%       - phip_xyz: power flow in the (x,y,z) coordinates (root +) [3,1]
%       - phim_xyz: power flow vector in the (x,y,z) coordinates (root -) [3,1] 
%       - phip_pmz: power flow vector in the (p,m,z) coordinates (root +) [3,1] 
%       - phim_pmz: power flow vector in the (p,m,z) coordinates (root -) [3,1]  
%       - phip_pyk: power flow vector in the (p,y,k) coordinates (root +) [3,1]  
%       - phim_pyk: power flow vector in the (p,y,k) coordinates (root -) [3,1] 
%
% created 05/02/2003
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
% 
qe = 1.6022e-19;%Electron charge (C)
me = 9.1094e-31;%Electron rest mass (Kg)
mp = 1.6726e-27;%Proton rest mass (Kg)
e0 = 8.8542e-12;%Free space permeability (F/m)
%
ns = [ne;zni(:)];
qs = qe*[-1;zZi(:)];
ms = [me;mp*zmi(:)];
%
wps = sqrt(ns.*qs.^2/e0./ms);
wcs = qs*Bfield./ms;
%
ps = wps/omega_rf;
ys = wcs/omega_rf;
%
ys(ys.^2 == 1) = ys(ys.^2 == 1) + eps;
%
%   Dielectric tensor elements
%
Kperp = 1 - sum(ps.^2./(1 - ys.^2));
Kpar = 1 - sum(ps.^2);
Kxy = sum(ps.^2.*ys./(1 - ys.^2));
%
Kxyz = [Kperp,-i*Kxy,0;i*Kxy,Kperp,0;0,0,Kpar];
%
%   Dispersion relation
%
A = Kperp;
B = (Npar^2 - Kperp)*(Kperp + Kpar) + Kxy^2;
C = Kpar*((Npar^2 - Kperp)^2 - Kxy^2);
%
Nperpp = sqrt((-B + sqrt(B^2-4*A*C))/(2*A));
Nperpm = sqrt((-B - sqrt(B^2-4*A*C))/(2*A));
%
Nxyzp = [Nperpp;0;Npar];         
Nxyzm = [Nperpm;0;Npar];         
%
%   Dispersion tensor for + root
%
Dxyzp = Nxyzp*Nxyzp' - sum(Nxyzp.^2)*diag([1,1,1]) + Kxyz;
%
%   Dispersion tensor for - root
%
Dxyzm = Nxyzm*Nxyzm' - sum(Nxyzm.^2)*diag([1,1,1]) + Kxyz;
%
%   Eigenvectors
%
[Evecp,Evalp] = eig(Dxyzp);
[Evecm,Evalm] = eig(Dxyzm);
%
Eval0p = diag(Evalp); %eigenvalues
Eval0m = diag(Evalm); %eigenvalues
%
jp = find(abs(Eval0p) == min(abs(Eval0p))); %select eigenvalue lambda=0 
jm = find(abs(Eval0m) == min(abs(Eval0m))); %select eigenvalue lambda=0 
%
Evec0p = Evecp(:,max(jp)); %eigenvector
Evec0m = Evecm(:,max(jm)); %eigenvector
%
%   Polarization vectors
%
ep_xyz = Evec0p./norm(Evec0p); %xyz
em_xyz = Evec0m./norm(Evec0m);
%
M_xypm = [1,i,0;1,-i,0;0,0,sqrt(2)]/sqrt(2);
%
ep_pmz = M_xypm*ep_xyz; %pmz
em_pmz = M_xypm*em_xyz;
%
cp = Npar/norm(Nxyzp);
sp = Nperpp/norm(Nxyzp); 
cm = Npar/norm(Nxyzm);
sm = Nperpm/norm(Nxyzm); 
%
Mp_xzpk = [cp,0,-sp;0,1,0;sp,0,cp];
Mm_xzpk = [cm,0,-sm;0,1,0;sm,0,cm];
%
ep_pyk = Mp_xzpk*ep_xyz; %pyk
em_pyk = Mm_xzpk*em_xyz;
%
%   Power flow phi = Re[e x (N x e*)] = Re[N - (N . e)e*] 
%
Npmzp = M_xypm*Nxyzp;
Npmzm = M_xypm*Nxyzm;
Npykp = Mp_xzpk*Nxyzp;
Npykm = Mm_xzpk*Nxyzm;
%
phip_xyz = real(Nxyzp - (Nxyzp'*ep_xyz)*conj(ep_xyz));
phim_xyz = real(Nxyzm - (Nxyzm'*em_xyz)*conj(em_xyz)); 
phip_pmz = real(Npmzp - (Npmzp'*ep_pmz)*conj(ep_pmz));
phim_pmz = real(Npmzm - (Npmzm'*em_pmz)*conj(em_pmz)); 
phip_pyk = real(Npykp - (Npykp'*ep_pyk)*conj(ep_pyk)); 
phim_pyk = real(Npykm - (Npykm'*em_pyk)*conj(em_pyk));
