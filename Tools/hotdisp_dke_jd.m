function [Nperp,e_xyz,e_pmz,e_pyk,D,X,X_s,X_sn,alphaphi_lin,phiT_xyz,phiP_xyz,phiT_pmz,phiP_pmz,phiT_pyk,phiP_pyk]...
    = hotdisp_dke_jd(Npar,omega_rf,Te,ne,zTi,zni,zZi,zmi,Bfield,Nperp_in,herm_mode,display_mode,nmax,NZ,tol,method_type)
% This function solves the dispersion relation and the wave equation
% in the linear kinetic plasma model. It calculates the perpendicular index of
% refraction and the polarization as a function of the wave
% frequency and the parallel index of refraction. 
%
% - (x,y,z): We assume that the magnetic field is in the z direction and the 
%           perpendicular index of refraction in the x direction. 
% - (p,m,z): p and m refer to the left hand and right hand rotating fields 
%           respectively.
% - (p,y,k): p and y are the transverse components of the polarization, with 
%           respect to the wave vector. k is the longitudinal component.
%
%   INPUTS: 
%
%       - Npar: parallel index of refraction [1,1]       
%       - omega_rf: wave frequency (rad/s) [1,1] 
%       - Te: electron temperature (keV) [1,1]
%       - ne: electron density (m-3) [1,1]
%       - zTi: ion temperature (keV) [1,i]
%       - zni: ion density (m-3) [1,i]
%       - zZi: ion charges [1,i] 
%       - zmi: ion masses (mp) [1,i]  
%       - Bfield: magnetic field amplitude [1,1]
%       - Nperp_in: perpendicular index of refraction (initial guess) [1,1] (default:1)    
%       - herm_mode: mode for the calculation (0) full dielectric tensor, (1) hermitian part (default:0) 
%           >>> In the case herm_mode = 1, the power flow and linear absorption
%               are also calculated
%       - display_mode: (0,1) none (2) convergence figures (default:0)  
%       - nmax: maximum harmonic number (default:10) 
%       - NZ: number of grid points in Z function integration calculation (default:100) 
%       - tol: tolerance on the value of the dispersion relation (default:1e-6) 
%       - method_type: 'newton', 'segments' (default:'newton') 
%
%   OUTPUTS:
%
%       - Nperp: perpendicular index of refraction [1,1]
%       - e_xyz: polarization vector in the (x,y,z) coordinates [3,1]
%       - e_pmz: polarization vector in the (p,m,z) coordinates [3,1] 
%       - e_pyk: polarization vector in the (p,y,k) coordinates [3,1]  
%       - X: kinetic plasma susceptibility tensor elements [3,3]
%       - X_s: kinetic plasma susceptibility tensor elements for species s [3,3,1+i]
%       - X_sn: kinetic plasma susceptibility tensor elements for species s and harmonic n [3,3,1+i,N]
%
% created 05/02/2003
% by Joan Decker <jodecker@alum.mit.edu> (MIT/RLE) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
% 
if nargin < 16,
   method_type = 'newton';
end
if nargin < 15,
   tol = 1e-5;
end
if nargin < 14,
   NZ = 1000;
end
if nargin < 13,
   nmax = 10;
end
if nargin < 12,
   display_mode = 0;
end
if nargin < 11,
   herm_mode = 0;
end
if nargin < 10,
   Nperp_in = 1.0;
end
%
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
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
bTs = sqrt([Te*1e3*qe/me/clum^2;zTi(:)*1e3*qe./(mp*zmi(:))/clum^2]);
%
[Nperp,e_xyz,e_pmz,e_pyk,D,X,X_s,X_sn,...
          alphaphi_lin,phiT_xyz,phiP_xyz,phiT_pmz,phiP_pmz,phiT_pyk,phiP_pyk]...
    = kineticdisp_jd(ps.^2,ys,bTs,Npar,Nperp_in,herm_mode,display_mode,nmax,NZ,tol,method_type);
%
