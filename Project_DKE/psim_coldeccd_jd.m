function [xyY_ec,xyomega_ec,xynpar_ec,xydnpar_ec,xynparmin_ec,xynparmax_ec,xyP0_in_ec,xyfinc_ec,xythetab_ec,xyopt_ec,xyepolc_ec,xyn_ec] = psim_coldeccd_jd(xrho);
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%
nr = length(xrho);
nb_ec = length(blist_ec);
if nb_ec == 0, 
    blist_ec=ones(1,nb_ec); %for correct empty matrix size management
end
%
xyY_ec = ones(nr,1)*yY_ec(blist_ec);
xyomega_ec = 2*pi*1e9*ones(nr,1)*yomega_ec(blist_ec);%(Hz -> rad/s)
xynpar_ec = ones(nr,1)*ynpar_ec(blist_ec);
xydnpar_ec = ones(nr,1)*ydnpar_ec(blist_ec);
xyP0_in_c_ec = ones(nr,1)*yP0_in_c_ec(blist_ec)*1e6;%(MW -> W)
xypeak_ec = ones(nr,1)*ypeak_ec(blist_ec);
xywidth_ec = ones(nr,1)*ywidth_ec(blist_ec);
xyfinc_ec = ones(nr,1)*yfinc_ec(blist_ec);
xythetab_ec = ones(nr,1)*ythetab_ec(blist_ec)*pi/180;%(deg -> rad)
xyopt_ec = ones(nr,1)*yopt_ec(blist_ec); 
xyepolc_ec = ones(nr,1)*yepolc_ec(blist_ec); 
xyn_ec = ones(nr,1)*yn_ec(blist_ec); 
%
xyrho = repmat(xrho',[1,nb_ec]);
%
xynparmin_ec = NaN*ones(nr,nb_ec);
xynparmax_ec = NaN*ones(nr,nb_ec);
%
yP0_in_ec_prof = logical(yP0_in_ec_prof(blist_ec));
%
xyP0_in_ec = zeros(nr,nb_ec);
xyP0_in_ec(:,yP0_in_ec_prof) = exp(-(xyrho(:,yP0_in_ec_prof) - xypeak_ec(:,yP0_in_ec_prof)).^2./(xywidth_ec(:,yP0_in_ec_prof)/2/sqrt(log(2))).^2).*xyP0_in_c_ec(:,yP0_in_ec_prof);%Gaussian radial profile on midplane
xyP0_in_ec(:,~yP0_in_ec_prof) = xyP0_in_c_ec(:,~yP0_in_ec_prof);%Uniform radial profile