function [blist_lh,yomega_lh,yvparmin_lh,yvparmax_lh,ynparmin_lh,ynparmax_lh,ynpar_lh,ydnpar_lh,...
    yP0_in_c_lh,yP0_in_lh_prof,ypeak_lh,ywidth_lh,yfinc_lh,ythetab_lh,yopt_lh] = psim_coldlhcd_jd;
%
% Parameters for LHCD calculations with cold plasma wave model
% Note: these calculations do not include any coupling to ray-tracing 
% and do not bring consistency between propagating and absorbed power densities.
%
% by J. Decker (jodecker@mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
blist_lh = [3]; %Index of selected scenarios for the LH wave. [1,n_scenario_lh]
%
yomega_lh = [NaN,NaN,4.6];%LH wave frequency (GHz) [1,n_scenario_lh]
%
% Choose (vparmin_lh,vparmax_lh) or (nparmin_lh,nparmax_lh) for square n// LH wave power spectrum,
% or (npar_lh,dnpar_lh) for Gaussian shape
%
yvparmin_lh = [3,4,3.5];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
yvparmax_lh = [5,7,6];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
ynparmin_lh = [NaN,NaN,NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
ynparmax_lh = [NaN,NaN,NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
ynpar_lh = [NaN,NaN,NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
ydnpar_lh = [NaN,NaN,NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
yP0_in_c_lh = [1.0,1.0,1.0];%Central LHW Power (MW) [1,n_scenario_lh]
%     
yP0_in_lh_prof = [0,0,0];%LHW Power radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
ypeak_lh = [0.5,0.5,0.5];%Radial peak position of the LHW Power profile (r/a on midplane) [1,n_scenario_lh]
ywidth_lh = [0.1,0.1,0.1];%Radial width of the LH LHW Power profile (r/a on midplane) [1,n_scenario_lh]
%
% Note: For LHW, typically we have yfinc_lh >> 1. However, for normal poloidal incidence, 
% and within the electrostatic approximation, we have yfinc_lh ~ Nperp/Npar. To
% take this value, select yfinc_lh = NaN
yfinc_lh = [NaN,NaN,NaN];%incidence factor (yfinc >= 1)
%
ythetab_lh = [0,90,0];%Poloidal location of LH beam (Degree) [1,n_scenario_lh]
%
%Option parameter for FLR and cross-comparison between old LH code: 
%	- (0): exact calculation
%	- (1): small FLR expansion with 1/vpar dependence
%	- (2): small FLR expansion without 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
yopt_lh = [1,2,0]; % [1,n_scenario_lh]
