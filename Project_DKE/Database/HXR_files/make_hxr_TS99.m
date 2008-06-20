%******************************************** HARD X-RAY CONFIGURATION ********************************************
%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clc
clear all
close all
%
hxr_id = 'TS99';%Set here the name (identifier) of the Hard X-ray configuration
%
%Fast electron bremsstrahlung tomography (if exists)
%
[hxr] = bremTSconvert_dke_yp(1,10,1999);%Specific function for Tore Supra
%
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
eval(['save HXR_',hxr_id,'.mat hxr hxrparam']);
%