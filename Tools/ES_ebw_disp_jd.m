function [xNperp,xepol_pmz,xphi_xyz,xalphaphi_lin_nr,...
        xalphaphi_lin_wr,xalphaphi_lin_fr,xepol_xyz,xepol_pyk,xphi_pmz,xphi_pyk]...
    = ES_ebw_disp_jd(xNpar,omega_rf,xTe,xne,xB,xNperp_in,opt_calc,opt_disp,nmax)
%
% This function solves the dispersion relation and the wave equation
% in the linear electrostatic plasma model. It calculates the perpendicular index of
% refraction and the polarization as a function of the wave
% frequency and the parallel index of refraction. 
%
% This function is vai
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
%       - xNpar: parallel index of refraction [1,nx]       
%       - omega_rf: wave frequency (rad/s) [1,nx] 
%       - xTe: electron temperature (keV) [1,nx]
%       - xne: electron density (m-3) [1,nx]
%       - xB: magnetic field amplitude [1,nx]
%       - xNperp_in: perpendicular index of refraction (initial guess) [1,nx]
%       - opt_calc: option for dispersion calculation (default : 1)
%       - opt_disp: option for dispersion model (default : 2)
%       - nmax: maximum harmonic number (default:50) 
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
% by Joan Decker <joan.decker@cea.fr> (CEA/DRFC) and  Yves Peysson <yves.peysson@cea.fr> (CEA/DRFC)
% 
if nargin < 9
    nmax = 50;
end
if nargin < 8
    opt_disp = 0;
end
if nargin < 7
    opt_calc = 1;
end
if nargin < 6
    error('An initial guess must be provided')
end
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;
%
xa = xne.*qe.^2/e0./me/omega_rf^2;
xb = qe*xB./me/omega_rf;
xbeta = sqrt(xTe/mc2);
%
if opt_calc,
    [mask,xNperp,xepol_pmz,xphi_xyz,xalphaphi_lin_nr,...
        xalphaphi_lin_wr,xalphaphi_lin_fr,xepol_xyz,xepol_pyk,xphi_pmz,xphi_pyk] = ...
    disp_ES_ebw_jd(xa,1./xb,xbeta,xNpar,xNperp_in,opt_disp,nmax);
else
	if nargout > 3
    	[mask,xNperp,xepol_pmz,xphi_xyz,xalphaphi_lin_nr,...
        	xalphaphi_lin_wr,xalphaphi_lin_fr,xepol_xyz,xepol_pyk,xphi_pmz,xphi_pyk] = ...
    	proc_ES_ebw_jd(xa,1./xb,xbeta,xNpar,xNperp_in,opt_disp,nmax);
	else
    	[mask,xNperp,xepol_pmz,xphi_xyz] = ...
    	proc_ES_ebw_jd(xa,1./xb,xbeta,xNpar,xNperp_in,opt_disp,nmax);
	end
end
%