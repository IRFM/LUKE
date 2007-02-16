% script make_rayinit_ITER_Scen4
%
% Creates rayinit structure 
%
% WARNING: the definitions used in the DKE code, and here crucial for HXR calculations are the following
%         1) the toroidal frame (R,Z,phi) is direct (phi is positive clockwise when the tokamak is seen from the top)
%         2) the poloidal frame (r,theta,phi) is direct
%         3) (psi,s,phi) must be direct : if Ip.phi > 0, then B.theta > 0 and psi > 0, and s.theta > 0 (s as the same direction of theta)
%         4) the sign of psi is the sign of Ip.phi
% With the definitions above, if Ip is positive, psi is turned outward, Btheta is counterclockwise poloidally, and s too. The Ampere theorem is OK !
%
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
%
% WARNING: for simulations, the relative direction of the plasma current
% to the toroidal magnetic field must be specified, as well as if the RF
% wave is driving co or counter current.
%
clear all
close all
clc
%
% Equilibrium parameters
%
id_equil = 'ITER_Scen4_IAEA06';%For plasma equilibrium
path_equil = '../../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_rayinit = '20Z_Alpha_5p0';
launch.type = 'LH';%wave type
launch.omega_rf = [5.0]*2*pi*1e9;%wave angular frequency (rad/s) [1,1] (same frequency)
%
% Initial ray conditions (horizontal dimension represents different beams, vertical dimension
% represents different poloidal locations)
%
launch.bPlhtot = [26.08,3.92]*1e6;%initial power in the ray (W) (main lobe) [1,n_lobe]
launch.bNpar0 = [2.0,-3.9];%Initial Npar value (main lobe) [1,n_lobe]
launch.bwidth = [0.1,0.1];%ray spectral width for lobe width calculations [1,n_lobe]
launch.ry0 = [-0.5,0.0,0.5];%vertical launching positions [1,m_pol]
%
launch.m0 = 0;%initial poloidal mode number [1,1]
launch.phi0 = 0;%toroidal angle position [1,1]
launch.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
%==========================================================================
%
% Load equilibrium
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	error([path_equil,'EQUIL_',id_equil,'.mat does not exist']);
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
nb = length(launch.bNpar0);
launch.bdNpar0 = zeros(1,nb);
%
for ib = 1:nb,
    launch.bdNpar0(ib) = spectrum_sinc_jd(launch.bNpar0(ib),launch.bwidth(ib));
end
%
launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
%
save_str = ['LAUNCH_',id_equil,'_',id_rayinit,'.mat'];% not used, for reference only
eval(['save ',save_str,' launch']);
%
% Ray initial characteristics
%
rayinit = main_rayinit_launch_jd(equil,launch)
%
save_str = ['RAYINIT_',id_equil,'_',id_rayinit,'.mat'];
eval(['save ',save_str,' rayinit']);
