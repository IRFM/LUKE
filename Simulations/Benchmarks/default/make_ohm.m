%************************************** OHMIC EFIELD PROFILE ********************************************
%******************************************************************************************************************
% Create the local file OHM_ohm_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
ohm_id = 'DEFAULT';%Set here the name (identifier) of the Ohmic electric field profile
%
% Normlized Ohmic electric field profile calculation
% (WARNING: norm_ref = 0 by default when multiple radial positions are studied simultaneously, whatever the value in this file 
% -> normalization with pth_ref*nhuth_ref/e)
% 
epsi0 = 0;%Flux surface averaged core Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e) 
epsia = 0;%Flux surface averaged edge Ohmic electric field (pth_ref*nhuth_ref/e or pth*nhuth/e)
eepsi = 0;%Exponent for Ohmic electric field (WARNING: psi coordinate and not rho)
%
ohm.rho = linspace(0,1,20);%Arbitrary normalized minor radius
ohm.epsi = ((epsi0 - epsia)*(1.0-ohm.rho.^2).^eepsi + epsia);
%
% Any type of profile may be entered in the structure on any non-uniform radial grid.
% WARNING: profile is always function of a normalized minor radius
%
eval(['save OHM_',ohm_id,'.mat ohm']);




