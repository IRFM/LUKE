function [blist_ec,yY_ec,yomega_ec,ynpar_ec,ydnpar_ec,...
    yP0_in_c_ec,yP0_in_ec_prof,ypeak_ec,ywidth_ec,yfinc_ec,ythetab_ec,yopt_ec,yepolc_ec,yn_ec] = psim_coldeccd_jd;
%
% Parameters for ECCD calculations with cold plasma wave model
% Note: these calculations do not include any coupling to ray-tracing 
% and do not bring consistency between propagating and absorbed power densities.
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
ynpar_ec = [0.3,0.3,0.3];%EC wave Gaussian N// Spectrum: peak [1,n_scenario_ec]
ydnpar_ec = [0.02,0.02,0.02];%EC wave Gaussian N// Spectrum: width [1,n_scenario_ec]
%
yP0_in_c_ec = [1.0,1.0,1.0];%Central ECW Power (MW) [1,n_scenario_ec]
%     
yP0_in_ec_prof = [0,0,0];%ECW Power radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_ec]
ypeak_ec = [0.5,0.5,0.5];%Radial peak position of the ECW Power profile (r/a on midplane) [1,n_scenario_ec]
ywidth_ec = [0.1,0.1,0.1];%Radial width of the EC ECW Power profile (r/a on midplane) [1,n_scenario_ec]
%
yfinc_ec = [1,1,1];%incidence factor (yfinc >= 1)
%
ythetab_ec = [0,90,180];%Poloidal location of EC beam (Degree) [1,n_scenario_ec]
%
%Option parameter for FLR 
%	- (0): exact calculation
%	- (1): small FLR expansion
%
yopt_ec = [0,0,0]; % [1,n_scenario_ec]
%
%Polarization 
%	- (0): O mode 
%	- (1): X mode 
%
yepolc_ec = [1,1,1];
%
yn_ec = [2,2,2];%EC resonance harmonic [1,n_scenario_ec]
