%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat for EAST tokamak
% 
%by Y.Peysson (CEA/IRFM, yves.peysson@cea.fr) and Shiyao Lin (IPP/AS, linsy@ipp.ac.cn) and . Decker (CEA/IRFM, joan.decker@cea.fr)
%
clc
clear all
close all
%
hxr_id = 'EAST';
%
hxr.R_hxr = 3.889*ones(1,20);% reference major radius (m)
hxr.Z_hxr = -0.32297*ones(1,20);% reference vertical position (m)
%
% Detector label starts from 1 at the bottom to 20 up (closer to the equatorial mid-plane of the plasma)
%
hxr.alpha_hxr = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];%horizontal angle (with respect to R) [-pi...pi]. The negative sign comes from the fact that kv is defined in a direct frame, while alpha_hxr corresponds to an indirect frame
hxr.beta_hxr = [2.0145,1.9879,1.9613,1.9347,1.9081,1.8815,1.8549,1.8283,1.8017,1.7751,1.7484,1.7218,1.6952,1.6686,1.6420,1.6154,1.5888,1.5622,1.5356,1.5090]
%
hxr.EG_hxr = pi*5^2*5^2*1e-12/0.698^2/4*cos(hxr.beta_hxr - pi/2).^4;%geometrical extend (m^2) [1,nchord] (circular aperture of the pinhole camera, square detectors)
%
hxr.kd_hxr = ones(20,1)*[10,30,50,70,90,110,130,150,170,190,210,250];% reference energies for the photofraction [m,p] (Parameters approximately adapted for 57Co and 241Am spectra in measured in the lab)
%
hxr.phf_hxr = ones(20,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];% photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p] (Parameters approximately adapted for 57Co and 241Am spectra in measured in the lab)
%
hxr.res_hxr =  ones(20,1)*[6,-0.9];% fit parameters of the energy resolution of the detectors [m,2] (Parameters approximately adapted for 57Co and 241Am spectra in measured in the lab)
%
hxr.ef_hxr = ones(1,20);% thickness of the vacuum window (mm) [1,m]
hxr.tf_hxr = repmat('Al',20,1);% type of material for the vacuum window (Al ou Be) [1,m]
%
hxr.ea_hxr = 0.5*ones(1,20);% thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxr.ta_hxr = repmat('Al',20,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
%
hxr.ec_hxr = 20*ones(1,20);%thickness of the detector shield (mm) [1,m]
hxr.tc_hxr = repmat('Fe',20,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m] (20 mm of Mo. Fe put instead)
%
hxr.ed_hxr = 2*ones(1,20);% thickness of the detector (mm) [1,m]
hxr.td_hxr = repmat('CdTe',20,1); % type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
%
hxr.lod_hxr = 5*ones(1,20);% length of the detector (mm) [1,m]
hxr.lad_hxr = 5*ones(1,20);% width of the detector (mm) [1,m]
hxr.lpm_hxr = zeros(1,20);% Average distance between the radiation impact point and the detector edge (mm) [1,m]
%
hxr.kdiag_hxr = [20,40,60,80,100,120,140,160,50;40,60,80,100,120,140,160,180,110];% energy channels (the last one -> upper and lower bound for Tph calculation) (keV) [2,m+1]
%
%
hxr.Gain_hxr = ones(1,20);% factor of conversion photon energy (keV) <-> channel [1,m]
hxr.Offset_hxr = zeros(1,20);% offset of conversion photon energy <-> channel [1,m]
hxr.pur_hxr = zeros(1,20);% pile-up rejection (0: off, 1:on) [1,m]
%
hxr.chordstatus_hxr = ones(1,20);% state of the line-of-sight [1,m]
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
%
%graph1D_jd([1:20],hxr.EG_hxr,0,0,'chord index','geometrical factor (m-2)','EAST FEB camera',NaN,[0,20],NaN,'-','o','r',2)