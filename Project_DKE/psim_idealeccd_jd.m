function [blist_ec,yY_ec,yomega_ec,ynpar_ec,ydnpar_ec,...
    yD0_in_c_ec,yD0_in_ec_prof,ypeak_ec,ywidth_ec,ythetab_ec,yopt_ec,yepolc_ec,yn_ec] = psim_idealeccd_jd;
%
% Parameters for test mode ECCD calculations
% This function has a benchmarking purpose only
% Aproximations: 
%   - The wave is purely electromagnetic: the power flow is in the direction of the wave vector.
%   - Only one polarization is accounted for (parallel for O mode and -rotating for X mode)
%
% by J. Decker (jodecker@mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
blist_ec = [1]; %Index of selected scenarios for the EC wave. [1,n_scenario_ec]
%
% Choose any of the following two inputs
%
yY_ec = [0.98,0.98,0.98];%Normalized EC wave frequency: wce/w [1,n_scenario_ec]
yomega_ec = [NaN,NaN,NaN];%EC wave frequency (GHz) [1,n_scenario_ec]
%
ynpar_ec = [-0.3,0.3,0.3];%EC wave Gaussian N// Spectrum: peak [1,n_scenario_ec]
ydnpar_ec = [0.02,0.02,0.02];%EC wave Gaussian N// Spectrum: width [1,n_scenario_ec]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
yD0_in_c_ec = [0.14,0.14,0.14];%Central EC QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_ec]
%     
yD0_in_ec_prof = [0,0,0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_ec]
ypeak_ec = [0.5,0.5,0.5];%Radial peak position of the EC quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_ec]
ywidth_ec = [0.1,0.1,0.1];%Radial width of the EC quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_ec]
%
ythetab_ec = [0,90,180];%Poloidal location of EC beam (Degree) [1,n_scenario_ec]
%
%Option parameter for FLR 
%	- (0): exact calculation
%	- (1): small FLR expansion
%
yopt_ec = [1,1,1]; % [1,n_scenario_ec]
%
%Polarization 
%	- (0): O mode in N// << 1 limit: |e//| = 1
%	- (1): X mode with wpe << wce condition: |e-| =1/sqrt(2)
%
yepolc_ec = [1,1,1];
%
yn_ec = [2,2,2];%EC resonance harmonic [1,n_scenario_ec]
