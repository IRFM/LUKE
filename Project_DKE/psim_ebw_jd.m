function [xyY_ebw,xyomega_ebw,xynpar_ebw,xydnpar_ebw,xynparmin_ebw,xynparmax_ebw,xyP0_in_ebw,xyfinc_ebw,xythetab_ebw,xyopt_ebw,xyn_ebw] = psim_ebw_jd(xrho);
%
% Parameters for EBWCD calculations with hot plamsa dispersion solver
% Note: these calculations do not include any coupling to ray-tracing 
% and do not bring consistency between propagating and absorbed power densities.
%
% by J. Decker (jodecker@mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
blist_ebw = [1]; %Index of selected scenarios for the EBW wave. [1,n_scenario_ebw]
%
% Choose any of the following two inputs
%
yY_ebw = [NaN];%Normalized EBW wave frequency: wce/w [1,n_scenario_ebw]
yomega_ebw = [19.5];%EBW wave frequency (GHz) [1,n_scenario_ebw]
%
% Choose (nparmin_ebw,nparmax_ebw) for square n// EBW wave power spectrum,
% or (npar_ebw,dnpar_ebw) for Gaussian shape
%
ynpar_ebw = [0.5];%EBW wave Gaussian N// Spectrum: peak [1,n_scenario_ebw]
ydnpar_ebw = [ynpar_ebw/3];%EBW wave Gaussian N// Spectrum: width [1,n_scenario_ebw]
%
ynparmin_ebw = [NaN];%EBW wave square N// Spectrum: Lower limit [1,n_scenario_ebw]
ynparmax_ebw = [NaN];%EBW wave square N// Spectrum: Upper limit [1,n_scenario_ebw]
%
yP0_in_c_ebw = [0.19159];%Central EBW Power (MW) [1,n_scenario_ebw]
%     
yP0_in_ebw_prof = [0];%EBW Power radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_ebw]
ypeak_ebw = [NaN];%Radial peak position of the EBWW Power profile (r/a on midplane) [1,n_scenario_ebw]
%
yfinc_ebw = [1];%incidence factor (yfinc >= 1). Note: If yfinc_ebw = NaN, the incidence factor is calculated using the 
% power flow calculated by the dispersion tensor.In the limit of infinitely thin flux-surface, yfinc_ebw = 1/cos(alpha)
%   where alpha is the incidence angle of the ray on the surface
%
ythetab_ebw = [0];%Poloidal location of EBW beam (Degree) [1,n_scenario_ebw]
%
yn_ebw = [2];%EBW resonance harmonic [1,n_scenario_ebw]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%
nr = length(xrho);
nb_ebw = length(blist_ebw);
if nb_ebw == 0, 
    blist_ebw=ones(1,nb_ebw); %for correct empty matrix size management
end
%
yopt_ebw = [0]*ones(1,nb_ebw); % [1,nb_ebw] Only exact calculations for FLR effects in EBWCD
%
xyY_ebw = ones(nr,1)*yY_ebw(blist_ebw);
xyomega_ebw = 2*pi*1e9*ones(nr,1)*yomega_ebw(blist_ebw);%(Hz -> rad/s)
xynpar_ebw = ones(nr,1)*ynpar_ebw(blist_ebw);
xydnpar_ebw = ones(nr,1)*ydnpar_ebw(blist_ebw);
xynparmin_ebw = ones(nr,1)*ynparmin_ebw(blist_ebw);
xynparmax_ebw = ones(nr,1)*ynparmax_ebw(blist_ebw);
xyP0_in_c_ebw = ones(nr,1)*yP0_in_c_ebw(blist_ebw)*1e6;%(MW -> W)
xypeak_ebw = ones(nr,1)*ypeak_ebw(blist_ebw);
xyfinc_ebw = ones(nr,1)*yfinc_ebw(blist_ebw);
xythetab_ebw = ones(nr,1)*ythetab_ebw(blist_ebw)*pi/180;%(deg -> rad)
xyopt_ebw = ones(nr,1)*yopt_ebw(blist_ebw); 
xyn_ebw = ones(nr,1)*yn_ebw(blist_ebw); 
%
xyrho = repmat(xrho',[1,nb_ebw]);
%
% *** Not returned - just for reference
%
xywidth_ebw = NaN*ones(nr,nb_ebw);%Radial width of the EBW EBWW Power profile (r/a on midplane)
xyepolc_ebw = NaN*ones(nr,nb_ebw); % [1,nb_ebw] Only one mode considered at a time.
%
% ***
%
yP0_in_ebw_prof = logical(yP0_in_ebw_prof(blist_ebw));
%
xyP0_in_ebw = zeros(nr,nb_ebw);
xyP0_in_ebw(:,yP0_in_ebw_prof) = exp(-(xyrho(:,yP0_in_ebw_prof) - xypeak_ebw(:,yP0_in_ebw_prof)).^2./(xywidth_ebw(:,yP0_in_ebw_prof)/2/sqrt(log(2))).^2).*xyP0_in_c_ebw(:,yP0_in_ebw_prof);%Gaussian radial profile on midplane
xyP0_in_ebw(:,~yP0_in_ebw_prof) = xyP0_in_c_ebw(:,~yP0_in_ebw_prof);%Uniform radial profile