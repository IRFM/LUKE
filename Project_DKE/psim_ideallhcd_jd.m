function [blist_lh,yvparmin_lh,yvparmax_lh,ynparmin_lh,ynparmax_lh,ynpar_lh,ydnpar_lh,...
    yD0_in_c_lh,yD0_in_lh_prof,ypeak_lh,ywidth_lh,ythetab_lh,yopt_lh] = psim_ideallhcd_jd;
%
% Parameters for test mode LHCD calculations
% This function has a benchmarking purpose only
% Approximations: 
%   - The polarization is purely electrostatic: in that case, only the parallel polarization term is non-zero.
%   - Small FLR limit: J0(z) -> 1. 
%
% by J. Decker (RLE/MIT) <jodecker@mit.edu> and Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
blist_lh = [3]; %Index of selected scenarios for the LH wave. [1,n_scenario_lh]
%
% Choose (vparmin_lh,vparmax_lh) or (nparmin_lh,nparmax_lh) for square n// LH wave power spectrum,
% or (npar_lh,dnpar_lh) for Gaussian shape
%
yvparmin_lh = [NaN,-6,3.5];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
yvparmax_lh = [NaN,-3.5,6];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
ynparmin_lh = [NaN,NaN,NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
ynparmax_lh = [NaN,NaN,NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
ynpar_lh = [2.50,NaN,NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
ydnpar_lh = [0.15,NaN,NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
yD0_in_c_lh = [1.0,1.0,1.0];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
yD0_in_lh_prof = [0,0,0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
ypeak_lh = [0.5,0.5,0.5];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
ywidth_lh = [0.1,0.1,0.1];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
ythetab_lh = [0,0,0];%Poloidal location of LH beam (Degree) [1,n_scenario_lh]
%
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
yopt_lh = [2,2,2]; % [1,n_scenario_lh]
