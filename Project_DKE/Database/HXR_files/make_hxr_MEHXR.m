%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat for the ME-HXR diagnostic. 
% 
%by T.Barbui (PPPL, tbarbui@pppl.gov)
%
clearvars
close all
%
hxr_id = 'MEHXR';
%
hxr = mehxr_tb;
%
% HXR parameter
%
hxrparam.id = 'STANDARD';
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
hxrparam.kmin = 50;% standard minimum value for Tph calculation (LH : 50; EC : 35)
hxrparam.kmax = 110;% standard maximum value for Tph calculation (LH : 110; EC : 75)
hxrparam.kphot = linspace(10,200,59);%Photon energy in keV
%
eval(['save MEHXR_',hxr_id,'.mat hxr hxrparam']);
disp(['save MEHXR_',hxr_id,'.mat saved']);
%
%graph1D_jd([1:20],hxr.EG_hxr,0,0,'chord index','geometrical factor (m-2)','EAST FEB camera',NaN,[0,20],NaN,'-','o','r',2)
