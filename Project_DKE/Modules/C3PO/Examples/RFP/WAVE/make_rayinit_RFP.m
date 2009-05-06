% script make_rayinit_MST_400ka
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
% Path parameters
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
id_equil = 'RFP';%For plasma equilibrium
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_rayinit = 'LH';
%
launch.type = 'LH';%wave type
launch.omega_rf = [0.8]*2*pi*1e9;%wave angular frequency (rad/s) [1,1] (same frequency)
%
% Initial ray conditions (horizontal dimension represents different beams, vertical dimension
% represents different poloidal locations)
%
launch.bPlhtot = [1]*1e6;%initial power in the ray (W) (main lobe) [1,n_lobe]
launch.bNpar0 = [10];%Initial Npar value (main lobe) [1,n_lobe]
launch.bdNpar0 = [3];%ray spectral width for Fokker-Planck calculations [1,n_lobe]
launch.ry0 = [-0.36];%vertical launching positions [1,m_pol]
%
launch.n0 = 0;%initial toroidal mode number [1,1]
launch.phi0 = 0;%toroidal angle position [1,1]
launch.LFS = -1;% (-1) high field side launching, (1) low field side launching [1,1]
%
%==========================================================================
%
%
% Load structures
%
[equil,dkepath] = load_structures_yp('equil',id_equil,path_equil,'dkepath',id_dkepath,path_dkepath);
%
launch.i_ref = length(equil.psi_apRp) - 1;%Initial radial position index [1,1]
%
% Ray initial characteristics
%
rayinit = main_rayinit_launch_jd(equil,launch)
%
save_str = ['RAYINIT_',id_equil,'_',id_rayinit,'.mat'];
eval(['save ',save_str,' rayinit']);
