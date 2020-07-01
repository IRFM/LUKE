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
hxr_id = 'WEST';
%Fast electron bremsstrahlung tomography (if exists)
%
[hxr] = bremTSconvert_dke_yp(1,10,1999,hxr_id);%Specific function for Tore Supra
%
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
hxrparam.kmin = 50;
hxrparam.kmax = 110;
hxrparam.kphot = [20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240];
%
eval(['save HXR_',hxr_id,'.mat hxr hxrparam']);
%