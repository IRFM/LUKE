function [blist_rf,yomega_rf,ydnpar_rf,ywaist_rf,yP0_L,yalpha_L,ybeta_L,ytheta_L,yR_L,yZ_L,yopt_rf,yepolc_rf,nsmin] = psim_straightray_jd;
%
% Launching parameters for straightray_jd, code that couples straight ray
% path calculations to the DKE code. 
%
% by J. Decker (jodecker@alum.mit.edu) and Y. Peysson (yves.peysson@cea.fr)
%
blist_rf = [1]; %Index of selected RF beams. [1,nb_rf]
%
yomega_rf = [90,90,90];%RF wave frequency (GHz) [1,nb_rf]
%
% Choose one of the following two inputs
%
    ydnpar_rf = [NaN,0.02,0.02];%RF wave Gaussian N// Spectrum width [1,nb_rf]
%    
    ywaist_rf = [0.05,NaN,NaN];%RF wave Gaussian beam waist (m) [1,nb_rf]
%
yP0_L = [1.0,1.0,1.0];%RFW Launching Power (MW) [1,nb_rf]    
%
yalpha_L = [-170,-170,-160]; %launching horizontal angle (with respect to R) (degrees) [-180...180]
ybeta_L = [90,90,90]; %launching vertical angle (with respect to Z) (degrees) [0...180]
%
% Choose one of the following two sets of launching parameters
%
%   Set 1: assuming launching from plasma edge
%
    ytheta_L = [0,0,0]; %launching poloidal angle (with respect to R) (degrees) [-180...180]
%
%   Set 2: raw parameters
%
    yR_L = [NaN,NaN,NaN]; %launching toroidal major radius (m) [0...infty]
    yZ_L = [NaN,NaN,NaN]; %launching vertical position (m) [-infty...infty]
%
%Option parameter for FLR 
%	- (0): exact calculation
%	- (1): small FLR expansion
%
yopt_rf = [0,0,0]; % [1,nb_rf]
%
%Polarization 
%	- (0): O mode 
%	- (1): X mode 
%
yepolc_rf = [1,1,1];
%
nsmin = 50; %minimum number of propagation steps within one flux-surface

