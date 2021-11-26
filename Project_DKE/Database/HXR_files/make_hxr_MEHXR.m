%******************************************************************************************************************
% Create the local file HXR_hxr_id.mat for the ME-HXR diagnostic. 
% 
%by T.Barbui (PPPL, tbarbui@pppl.gov)
%
clearvars
close all
%
hxr_id = 'ME-HXR';
%
nv = 60; %n. of viewing cords
%
hxr.R_hxr = 5.198*ones(1,nv);% pinhole major radius (m)
hxr.Z_hxr = 0.205*ones(1,nv);% pinhole vertical position (m)
%
% Detector label starts from 1 at the bottom to 20 up (closer to the equatorial mid-plane of the plasma)
%
hxr.alpha_hxr = zeros(1,nv);%horizontal angle (with respect to R) [-pi...pi]. The negative sign comes from the fact that kv is defined in a direct frame, while alpha_hxr corresponds to an indirect frame in radians
hxr.beta_hxr = fliplr(deg2rad(90 - linspace(16.05,-3.45,nv)));%vertical angle in radians (fliplr for the numbering definition of the chord in ME-HXR: 1 top, 60 bottom)
%
hxr.EG_hxr = [1.82348586099110e-12,1.83060464368659e-12,1.83749989551992e-12,1.84416935872950e-12,1.85061084696500e-12,1.85682224626964e-12,1.86280151603060e-12,1.86854668989682e-12,1.87405587666393e-12,1.87932726112567e-12,1.88435910489149e-12,1.88914974716992e-12,1.89369760551719e-12,1.89800117655090e-12,1.90205903662819e-12,1.90586984248821e-12,1.90943233185851e-12,1.91274532402500e-12,1.91580772036525e-12,1.91861850484488e-12,1.92117674447668e-12,1.92348158974231e-12,1.92553227497640e-12,1.92732811871273e-12,1.92886852399245e-12,1.93015297863406e-12,1.93118105546512e-12,1.93195241251552e-12,1.93246679317218e-12,1.93272402629517e-12,1.93272402629517e-12,1.93246679317218e-12,1.93195241251552e-12,1.93118105546512e-12,1.93015297863406e-12,1.92886852399245e-12,1.92732811871273e-12,1.92553227497640e-12,1.92348158974231e-12,1.92117674447668e-12,1.91861850484488e-12,1.91580772036525e-12,1.91274532402500e-12,1.90943233185851e-12,1.90586984248821e-12,1.90205903662819e-12,1.89800117655090e-12,1.89369760551719e-12,1.88914974716992e-12,1.88435910489149e-12,1.87932726112567e-12,1.87405587666393e-12,1.86854668989682e-12,1.86280151603060e-12,1.85682224626964e-12,1.85061084696500e-12,1.84416935872950e-12,1.83749989551992e-12,1.83060464368659e-12,1.82348586099110e-12];%etendue (m^2*ster) [1,nchord]
%
hxr.kd_hxr = ones(nv,1)*[8.1000,11.9000,17.5000,22.2000,25.3000,32.2000,36.0000,49.1000,59.3000,68.8000,75.0000,100,200];% reference energies for detector resolution [m,1]
%
hxr.phf_hxr = ones(nv,1)*[0.6369,0.9766,1.7834,2.1231,2.2081,3.1847,3.7792,4.3312,6.1146,10.1062,10.4034,23.8641,23.8641];% detector resolution (width of the detector's S-curve) (keV) [m,1] 
%    
hxr.res_hxr =  ones(nv,1)*0.39;% charge-sharing parameter f (dimensionless) [m,1]
%
hxr.ef_hxr = ones(1,nv);% thickness of the vacuum window (mm) [1,m]
hxr.tf_hxr = repmat('Al',nv,1);% type of material for the vacuum window (Al ou Be) [1,m]
%
hxr.ea_hxr = 0*ones(1,nv);% thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxr.ta_hxr = repmat('Al',nv,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
%
hxr.ec_hxr = 0*ones(1,nv);%thickness of the detector shield (mm) [1,m]
hxr.tc_hxr = repmat('Fe',nv,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m] (20 mm of Mo. Fe put instead)
%
hxr.ed_hxr = ones(1,nv);% thickness of the detector (mm) [1,m]
hxr.td_hxr = repmat('CdTe',nv,1); % type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
%
hxr.lod_hxr = 83.8*ones(1,nv);% length of the detector (mm) [1,m]
hxr.lad_hxr = 33.5*ones(1,nv);% width of the detector (mm) [1,m]
hxr.lpm_hxr = zeros(1,nv);% Average distance between the radiation impact point and the detector edge (mm) [1,m]
%
% not used in bremdiag_dke_yp
%hxr.kdiag_hxr = [linspace(10,200,59); 200*ones(1,59)];% Measured photon energy spectrum (keV) [kmin1,kmin2,...; kmintphot,kmax1,kmax2,...,kmaxtphot] (here photon temp is calculated between 50 and 110 keV) [1,k]
%
hxr.Gain_hxr = ones(1,nv);% factor of conversion photon energy (keV) <-> channel [1,m]
hxr.Offset_hxr = zeros(1,nv);% offset of conversion photon energy <-> channel [1,m]
hxr.pur_hxr = zeros(1,nv);% pile-up rejection (0: off, 1:on) [1,m]
%
hxr.chordstatus_hxr = ones(1,nv);% state of the line-of-sight [1,m]
%
% HXR parameter
%
hxrparam.id = hxr_id;
hxrparam.mfactor = 1;%For the magnetic equilibrium
hxrparam.method = 'spline';%For the magnetic equilibrium in the HXR calculations
hxrparam.ns = 3000;%for chord integration
hxrparam.n_gauleg = 35;%Number of Legendre polynomials for projections of cross-section and electron velocity distribution
hxrparam.epsi_gauleg = 1e-14;%Accuracy of the Legendre projection
%
hxrparam.kmin = 50;% standard minimum value for Tph calculation (LH : 50; EC : 35)
hxrparam.kmax = 110;% standard maximum value for Tph calculation (LH : 110; EC : 75)
hxrparam.kphot = [10:5:200];%Photon energy in keV
%
eval(['save HXR_',hxr_id,'.mat hxr hxrparam']);
disp(['save HXR_',hxr_id,'.mat saved']);
%
%graph1D_jd([1:20],hxr.EG_hxr,0,0,'chord index','geometrical factor (m-2)','EAST FEB camera',NaN,[0,20],NaN,'-','o','r',2)
