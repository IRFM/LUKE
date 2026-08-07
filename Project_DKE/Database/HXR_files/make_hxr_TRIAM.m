% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
hxr_id = 'TRIAM';
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
hxrparam.kphot = [20:2:200];
%
eval(['save HXR_',hxr_id,'.mat hxr hxrparam']);
%