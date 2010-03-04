%************************************** HARD X-RAY CONFIGURATION ********************************************
%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker CEA-DRFC (joan.decker@cea.fr)
%
clear all
close all
hxr_id = 'TCV';%Set here the name (identifier) of the Hard X-ray configuration
%
% Small Tore Supra HXR camera installed on TCV tokamak
% mv_TS = [-1.5000,-2.4500,-3.4000,-4.3500,-5.3000,-6.2500,-7.2000,-8.1500,-9.1000,-10.0500,-11.0000,-11.9500,-12.9000,-13.8500,-14.8000,-15.7500,-16.7000,-17.6500,-18.6000,-19.5500,-20.5000];	
% mv = mv_TS(1:18);%Only the 18 first chords are considered
% kv = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
% %
% hxr.alpha_hxr = -kv*pi/180;%horizontal angle (with respect to R) [-pi...pi]. The negative sign comes from the fact that kv is defined in a direct frame, while alpha_hxr corresponds to an indirect frame
% hxr.beta_hxr = fliplr((90 + 90 - (mv - mv(11) - 2))*pi/180);%vertical angle (with respect to Z) [0...pi]
%
% Only chords 5 to 18 see the plasma
%
beta_hxr_stefano = [NaN,NaN,NaN,NaN,183.3893,182.6976,...
    181.7569,180.8162,179.8755,178.9349,178.0000,177.0651,176.1245,...
    175.1838,174.2431,173.3024,172.3615,171.6614,NaN]/180*pi;
%
hxr.beta_hxr = NaN(1,19);
hxr.alpha_hxr = NaN(1,19);
%
hxr.beta_hxr(beta_hxr_stefano <= pi) = beta_hxr_stefano(beta_hxr_stefano <= pi);
hxr.alpha_hxr(beta_hxr_stefano <= pi) = 0;
%
% according to the correct definitions of alpha (-pi -> pi) and beta (0 -> pi)
%
hxr.beta_hxr(beta_hxr_stefano > pi) = 2*pi - beta_hxr_stefano(beta_hxr_stefano > pi);
hxr.alpha_hxr(beta_hxr_stefano > pi) = pi;
%
hxr.R_hxr = [1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048,1.048];%Distance in meter
hxr.Z_hxr = [-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137,-1.137];%Distance in meter
hxr.EG_hxr = [0,0,0,0,0.219,1.627,1.789,1.951,2.112,2.272,2.384,2.272,2.112,1.951,1.789,1.627,1.465,0.178,0]*1e-9;%geometrical extend (m^2) [1,nchord]
hxr.kd_hxr = ones(19,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Reference energies for the photofraction [m,p]
hxr.phf_hxr = ones(19,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
hxr.res_hxr = ones(19,1)*[6,-0.9];%fit parameters of the energy resolution of the detectors [m,2]
hxr.ef_hxr = [0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25,0.25];% thickness of the vacuum window (mm) [1,m]
hxr.tf_hxr = ['Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be';'Be'];% type of material for the vacuum window (Al ou Be) [1,m]
% Air absoprtion is negligible as far as the photon energy is less than 10 keV, and the length is less than several meters (here air thickness is 57.64 cm)
hxr.ea_hxr = 0*[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];%thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxr.ta_hxr = ['Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe'];%type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
hxr.ec_hxr = [0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5,0.5];%thickness of the detector shield (mm) [1,m]
hxr.tc_hxr = ['Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al'];%type of material for the detector shield (Al,C ou Be) [1,m]
hxr.ed_hxr = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];%thickness of the detector (mm) [1,m]
hxr.td_hxr = ['CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe'];%type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
hxr.kdiag_hxr = [20,40,60,80 ,100,120,140,160,50  ;...
                 40,60,80,100,120,140,160,180,110];%Measured photon energy spectrum (keV) [kmin1,kmin2,...,kmintphot,kmax1,kmax2,...,kmaxtphot] (here photon temp is calculated between 50 and 110 keV) [1,k]
%
hxr.kphot = [20:10:180];%Photon energy in keV
%
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
eval(['save HXR_',hxr_id,'.mat hxr hxrparam']);
