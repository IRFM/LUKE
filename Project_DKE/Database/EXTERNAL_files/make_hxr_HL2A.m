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
%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat for HL2A tokamak. Note that most
% external lines of sight are not considered since they have a different
% collimating point
% 
%by Y.Peysson (CEA/IRFM, yves.peysson@cea.fr) and Shaodong Song (SWIP, songshd@swip.ac.cn)
%
clc
clear all
close all
%
hxr_id = 'HL2A';
%
hxr.R_hxr = 2.9*ones(1,21);% reference major radius (m)
hxr.Z_hxr = 0*ones(1,21);% reference vertical position (m)
%
% Detector label starts from 1 at the bottom to 20 up (closer to the equatorial mid-plane of the plasma)
%
hxr.alpha_hxr = zeros(1,21);%horizontal angle (with respect to R) [-pi...pi]. The negative sign comes from the fact that kv is defined in a direct frame, while alpha_hxr corresponds to an indirect frame in radians
hxr.beta_hxr = fliplr([1.7366,1.7200,1.7034,1.6869,1.6703,1.6537,1.6371,1.6205,1.6040,1.5874,1.5708,1.5542,1.5376,1.5211,1.5045,1.4879,1.4713,1.4547,1.4382,1.4216,1.4050]);%vertical angle in radians (fliplr for the numbering definition of the chord in HL-2A)
%
hxr.EG_hxr = 1e-8*fliplr([0.2101,0.2142,0.2179,0.2216,0.2256,0.2291,0.2326,0.2364,0.2398,0.2431,0.2460,0.2431,0.2398,0.2364,0.2326,0.2291,0.2256,0.2216,0.2179,0.2142,0.2101]);%geometrical extend (m^2) [1,nchord] (circular aperture of the pinhole camera, square detectors)
%
hxr.kd_hxr = ones(21,1)*[10,30,50,70,90,110,130,150,170,190,210,250];% reference energies for the photofraction [m,p] (Parameters approximately adapted for 57Co and 241Am spectra in measured in the lab)
%
hxr.phf_hxr = ones(21,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];% photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p] (Parameters approximately adapted for 57Co and 241Am spectra in measured in the lab)
%
hxr.res_hxr =  ones(21,1)*[6,-0.9];% fit parameters of the energy resolution of the detectors [m,2] (Parameters approximately adapted for 57Co and 241Am spectra in measured in the lab)
%
hxr.ef_hxr = ones(1,21);% thickness of the vacuum window (mm) [1,m]
hxr.tf_hxr = repmat('Al',21,1);% type of material for the vacuum window (Al ou Be) [1,m]
%
hxr.ea_hxr = 0.5*ones(1,21);% thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxr.ta_hxr = repmat('Al',21,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
%
hxr.ec_hxr = 0.5*ones(1,21);%thickness of the detector shield (mm) [1,m]
hxr.tc_hxr = repmat('Fe',21,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m] (20 mm of Mo. Fe put instead)
%
hxr.ed_hxr = 2*ones(1,21);% thickness of the detector (mm) [1,m]
hxr.td_hxr = repmat('CdTe',21,1); % type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
%
hxr.lod_hxr = 5*ones(1,21);% length of the detector (mm) [1,m]
hxr.lad_hxr = 5*ones(1,21);% width of the detector (mm) [1,m]
hxr.lpm_hxr = zeros(1,21);% Average distance between the radiation impact point and the detector edge (mm) [1,m]
%
hxr.kdiag_hxr = [10,30,50,70,90,110,150,60;30,50,70,90,110,150,200,130];% energy channels (the last one -> upper and lower bound for Tph calculation) (keV) [2,m+1]
%
hxr.Gain_hxr = ones(1,21);% factor of conversion photon energy (keV) <-> channel [1,m]
hxr.Offset_hxr = zeros(1,21);% offset of conversion photon energy <-> channel [1,m]
hxr.pur_hxr = zeros(1,21);% pile-up rejection (0: off, 1:on) [1,m]
%
hxr.chordstatus_hxr = [0,1,0,1,0,0,1,0,1,1,1,1,1,0,0,0,0,1,0,0,1];% state of the line-of-sight [1,m]
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
hxrparam.kphot = [20:10:180];%Photon energy in keV
%
eval(['save HXR_',hxr_id,'.mat hxr hxrparam']);
disp(['save HXR_',hxr_id,'.mat saved']);
%
%graph1D_jd([1:20],hxr.EG_hxr,0,0,'chord index','geometrical factor (m-2)','EAST FEB camera',NaN,[0,20],NaN,'-','o','r',2)