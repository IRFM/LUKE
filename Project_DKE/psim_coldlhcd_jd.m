function [xyomega_lh,xyvparmin_lh,xyvparmax_lh,xynparmin_lh,xynparmax_lh,xynpar_lh,xydnpar_lh,...
    xyP0_in_lh,xyfinc_lh,xythetab_lh,xyopt_lh] = psim_coldlhcd_jd(xrho);
%
% Parameters for LHCD calculations with cold plasma wave model
% Note: these calculations do not include any coupling to ray-tracing 
% and do not bring consistency between propagating and absorbed power densities.
%
% by J. Decker (jodecker@mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
blist_lh = [3]; %Index of selected scenarios for the LH wave. [1,n_scenario_lh]
%
yomega_lh = [4.6,4.6,4.6];%LH wave frequency (GHz) [1,n_scenario_lh]
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%
nr = length(xrho);
nb_lh = length(blist_lh);
if nb_lh == 0, 
    blist_lh=ones(1,nb_lh); %for correct empty matrix size management
end
%
xyvparmin_lh = ones(nr,1)*yvparmin_lh(blist_lh);
xyvparmax_lh = ones(nr,1)*yvparmax_lh(blist_lh);
xynparmin_lh = ones(nr,1)*ynparmin_lh(blist_lh);
xynparmax_lh = ones(nr,1)*ynparmax_lh(blist_lh);
xyomega_lh = 2*pi*1e9*ones(nr,1)*yomega_lh(blist_lh);%(GHz -> rad/s)
xynpar_lh = ones(nr,1)*ynpar_lh(blist_lh);
xydnpar_lh = ones(nr,1)*ydnpar_lh(blist_lh);
xyP0_in_c_lh = ones(nr,1)*yP0_in_c_lh(blist_lh)*1e6;%(MW -> W)
xypeak_lh = ones(nr,1)*ypeak_lh(blist_lh);
xywidth_lh = ones(nr,1)*ywidth_lh(blist_lh);
xyfinc_lh = ones(nr,1)*yfinc_lh(blist_lh);
xythetab_lh = ones(nr,1)*ythetab_lh(blist_lh)*pi/180;%(deg -> rad)
xyopt_lh = ones(nr,1)*yopt_lh(blist_lh); 
%
xyrho = repmat(xrho',[1,nb_lh]);
%
yP0_in_lh_prof = logical(yP0_in_lh_prof(blist_lh));
%
xyP0_in_lh = zeros(nr,nb_lh);
xyP0_in_lh(:,yP0_in_lh_prof) = exp(-(xyrho(:,yP0_in_lh_prof) - xypeak_lh(:,yP0_in_lh_prof)).^2./(xywidth_lh(:,yP0_in_lh_prof)/2/sqrt(log(2))).^2).*xyP0_in_c_lh(:,yP0_in_lh_prof);%Gaussian radial profile on midplane
xyP0_in_lh(:,~yP0_in_lh_prof) = xyP0_in_c_lh(:,~yP0_in_lh_prof);%Uniform radial profile
%
