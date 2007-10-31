% script make_wave_TScirc_LHtest
%
% Parameters for test mode LHCD calculations
% This function has a benchmarking purpose only
% Approximations: 
%   - Circular equilibrium required
%   - The polarization is purely electrostatic: in that case, only the parallel polarization term is non-zero.
%   - Small FLR limit: J0(z) -> 1. 
%
% by J. Decker (RLE/MIT) <jodecker@mit.edu> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
clear all
%
id_wave = 'LH_karney';
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '../EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
opt_lh = 2; % [1,1]
%
%
blist_lh = [1]; %Index of selected scenarios for the LH wave. [1,n_scenario_lh]
%
% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
yD0_in_c_lh = [1];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
yD0_in_lh_prof = [0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
ypeak_lh = [NaN];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
ywidth_lh = [NaN];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%
% -------------------------------------------------------------------------
%
wavestruct.omega_lh = omega_lh;
wavestruct.opt_lh = opt_lh;
wavestruct.norm_ref = norm_ref;
wavestruct.yvparmin_lh = yvparmin_lh(blist_lh);
wavestruct.yvparmax_lh = yvparmax_lh(blist_lh);
wavestruct.yNparmin_lh = yNparmin_lh(blist_lh);
wavestruct.yNparmax_lh = yNparmax_lh(blist_lh);
wavestruct.yNpar_lh = yNpar_lh(blist_lh);
wavestruct.ydNpar_lh = ydNpar_lh(blist_lh);
wavestruct.yD0_in_c_lh = yD0_in_c_lh(blist_lh);
wavestruct.yD0_in_lh_prof = yD0_in_lh_prof(blist_lh);
wavestruct.ypeak_lh = ypeak_lh(blist_lh);
wavestruct.ywidth_lh = ywidth_lh(blist_lh);
wavestruct.ythetab_lh = ythetab_lh(blist_lh);
%
wave = make_idealLHwave_jd(equil,wavestruct);
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);
