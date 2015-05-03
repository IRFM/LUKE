%************************************** HARD X-RAY CONFIGURATION ********************************************
%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
hxr_id = 'CMOD';%Set here the name (identifier) of the Hard X-ray configuration
%
%
%Fast electron bremsstrahlung tomography (if exists)
%
hxr.alpha_hxr = [2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8,2.8]*pi/180;%Angles in radians (positive in clockwise direction, see the definition of the frame in the documentation of DKE)
hxr.beta_hxr = pi/2 - [14.4367,13.5049,12.5730,11.6408,10.7079,9.7743,8.8437,7.9118,6.9783,6.0466,5.1132,4.1811,3.2500,2.3162,1.3830,0.4502,-0.4788,-1.4116,-2.3447,-3.2785,-3.9957,-5.1417,-6.0758,-7.0071,-7.9376,-8.8731,-9.8037,-10.7374,-11.6667,-12.6025,-13.5353,-14.4671]*pi/180;%Angles in radians
hxr.R_hxr = [1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871,1.871];%Distance in meter
hxr.Z_hxr = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];%Distance in meter
hxr.EG_hxr = [2.9400e-03,3.0000e-03,3.0700e-03,3.1300e-03,3.1900e-03,3.2500e-03,3.3100e-03,3.3700e-03,3.4300e-03,3.4800e-03,3.5400e-03,3.5900e-03,3.6500e-03,3.7000e-03,3.7500e-03,3.8000e-03,3.8000e-03,3.7500e-03,3.7000e-03,3.6500e-03,3.5900e-03,3.5400e-03,3.4800e-03,3.4200e-03,3.3700e-03,3.3100e-03,3.2500e-03,3.1900e-03,3.1300e-03,3.0600e-03,3.0000e-03,2.9400e-03]*1e-6;%geometrical extend (m^2) [1,nchord]
hxr.kd_hxr = ones(32,1)*[10,30,50,70,90,110,130,150,170,190,210,250];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Reference energies for the photofraction [m,p]
hxr.phf_hxr = ones(32,1)*[0.75,0.62,0.51,0.41,0.32,0.2,0.2,0.2,0.2,0.2,0.2,0.2];%Parameters approximately corresponding to  photon energy spectra of gamma sources 57Co and 241Am. Photofraction determined using the "MCDET.f" Monte-carlo hard x-ray absorption code at energies kd [m,p]
hxr.res_hxr = ones(32,1)*[6,-0.9];%fit parameters of the energy resolution of the detectors [m,2]
hxr.ef_hxr = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];% thickness of the vacuum window (mm) [1,m]
hxr.tf_hxr = ['Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al'];% type of material for the vacuum window (Al ou Be) [1,m]

hxr.ea_hxr = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];%thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxr.ta_hxr = ['Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe';'Fe'];%type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]

hxr.ec_hxr = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];%thickness of the detector shield (mm) [1,m]
hxr.tc_hxr = ['Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al';'Al'];%type of material for the detector shield (Al,C ou Be) [1,m]

hxr.ed_hxr = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];%thickness of the detector (mm) [1,m]
hxr.td_hxr = ['CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe';'CdTe'];%type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]

hxr.kdiag_hxr = [20,40,60,80,100,120,140,160,50;40,60,80,100,120,140,160,180,110];%Measured photon energy spectrum (keV) [kmin1,kmin2,...,kmintphot,kmax1,kmax2,...,kmaxtphot] (here photon temp is calculated between 50 and 110 keV) [1,k]
%
hxr.kphot = [20:10:180];%Photon energy in keV
hxr.n_gauleg = 35;%Number of Legendre polynomials for prjections of cross-section and distribution
hxr.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
eval(['save HXR_',hxr_id,'.mat hxr']);
