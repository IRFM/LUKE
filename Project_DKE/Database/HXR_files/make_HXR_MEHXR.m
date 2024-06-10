%*******************************************************************************************************************
% Create the local file HXR_hxr_id.mat for the ME-HXR diagnostic. 
% 
%by T.Barbui (PPPL, tbarbui@pppl.gov)
%
clearvars
%
hxr_id = 'MEHXR';
%
nv = 60; %n. of viewing cords
%
% Chord label starts from 1 at the bottom divertor to 60 at the top (closer to the equatorial mid-plane of the plasma)
% LoS coordinates from Patrick's method applied to 2022 spatial calibration
%
hxrspec.R_hxr = 4.7211*ones(1,nv);% pinhole major radius (m)
hxrspec.Z_hxr = [0.076453,0.079175,0.081901,0.08463,0.087362,0.090098,0.092838,0.09558,0.098326,0.10108,0.10383,0.10658,0.10934,0.11211,0.11487,0.11764,0.12042,0.12319,0.12597,0.12876,0.13155,0.13434,0.13713,0.13993,0.14273,0.14553,0.14834,0.15116,0.15397,0.15679,0.15961,0.16243,0.16524,0.16806,0.17087,0.17367,0.17647,0.17927,0.18206,0.18485,0.18764,0.19043,0.19321,0.19598,0.19876,0.20153,0.20429,0.20706,0.20982,0.21257,0.21532,0.21807,0.22082,0.22356,0.2263,0.22904,0.23177,0.2345,0.23722,0.23995];% pinhole vertical position (m)
%
hxrspec.alpha_hxr = -0.032*ones(1,nv);%horizontal angle (with respect to R) [-pi...pi]. alpha_hxr is in an indirect frame (phi is negative clockwise when the tokamak is seen from the top)
hxrspec.beta_hxr = deg2rad(90 - linspace(16.05,-3.45,nv));%vertical angle in radians  
%
hxrspec.EG_hxr = 195*[1.82348586099110e-12,1.83060464368659e-12,1.83749989551992e-12,1.84416935872950e-12,1.85061084696500e-12,1.85682224626964e-12,1.86280151603060e-12,1.86854668989682e-12,1.87405587666393e-12,1.87932726112567e-12,1.88435910489149e-12,1.88914974716992e-12,1.89369760551719e-12,1.89800117655090e-12,1.90205903662819e-12,1.90586984248821e-12,1.90943233185851e-12,1.91274532402500e-12,1.91580772036525e-12,1.91861850484488e-12,1.92117674447668e-12,1.92348158974231e-12,1.92553227497640e-12,1.92732811871273e-12,1.92886852399245e-12,1.93015297863406e-12,1.93118105546512e-12,1.93195241251552e-12,1.93246679317218e-12,1.93272402629517e-12,1.93272402629517e-12,1.93246679317218e-12,1.93195241251552e-12,1.93118105546512e-12,1.93015297863406e-12,1.92886852399245e-12,1.92732811871273e-12,1.92553227497640e-12,1.92348158974231e-12,1.92117674447668e-12,1.91861850484488e-12,1.91580772036525e-12,1.91274532402500e-12,1.90943233185851e-12,1.90586984248821e-12,1.90205903662819e-12,1.89800117655090e-12,1.89369760551719e-12,1.88914974716992e-12,1.88435910489149e-12,1.87932726112567e-12,1.87405587666393e-12,1.86854668989682e-12,1.86280151603060e-12,1.85682224626964e-12,1.85061084696500e-12,1.84416935872950e-12,1.83749989551992e-12,1.83060464368659e-12,1.82348586099110e-12];%etendue (m^2*ster) [1,nchord]
%
hxrspec.kd_hxr = ones(nv,1)*[8,15,24,32,42,50,60,75,100,200];% reference energies for detector resolution [m,1]
%
hxrspec.phf_hxr = ones(nv,1)*[0.8,1.1,1.7,4,4,4.5,6,10,30,30];% detector resolution (width of the detector's S-curve) (keV) [m,1] 
%    
hxrspec.res_hxr =  ones(nv,1)*0.5;% charge-sharing parameter f (dimensionless) [m,1]
%
hxrspec.ef_hxr = ones(1,nv);% thickness of the vacuum window (mm) [1,m]
hxrspec.tf_hxr = repmat('Al',nv,1);% type of material for the vacuum window (Al ou Be) [1,m]
%
hxrspec.ea_hxr = 0*ones(1,nv);% thickness of the absorber (mm) [1,m] (WARNING: for 2 mm Cu: 2.83= 2*(29/26)^2*(dens_Cu/dens_Fe)  dens_Cu = 63.546, dens_Fe = 55.845)
hxrspec.ta_hxr = repmat('Al',nv,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m]
%
hxrspec.ec_hxr = 0*ones(1,nv);%thickness of the detector shield (mm) [1,m]
hxrspec.tc_hxr = repmat('Fe',nv,1);% type of material for the absorber (Al,Fe,Ge,Be ou Pb) [1,m] (20 mm of Mo. Fe put instead)
%
hxrspec.ed_hxr = ones(1,nv);% thickness of the detector (mm) [1,m]
hxrspec.td_hxr = repmat('CdTe',nv,1); % type of material for the detector (BGO,CsI,NaI,Ge or CdTe) [1,m]
%
hxrspec.lod_hxr = 83.8*ones(1,nv);% length of the detector (mm) [1,m]
hxrspec.lad_hxr = 33.5*ones(1,nv);% width of the detector (mm) [1,m]
hxrspec.lpm_hxr = zeros(1,nv);% Average distance between the radiation impact point and the detector edge (mm) [1,m]
%
hxrspec.kfit = [15:10:100];%Lower cutoff energy for diagnostic calculation [keV]
%
hxrspec.Gain_hxr = ones(1,nv);% factor of conversion photon energy (keV) <-> channel [1,m]
hxrspec.Offset_hxr = zeros(1,nv);% offset of conversion photon energy <-> channel [1,m]
hxrspec.pur_hxr = zeros(1,nv);% pile-up rejection (0: off, 1:on) [1,m]
%
hxrspec.chordstatus_hxr = ones(1,nv);% state of the line-of-sight [1,m]
%
eval(['save HXR_',hxr_id,'.mat hxrspec']);
%
