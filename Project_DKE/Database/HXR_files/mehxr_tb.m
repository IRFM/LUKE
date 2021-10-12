function hxr = mehxr_tb
%
% By Tullio Barbui (PPPL)
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
hxr.kd_hxr = ones(nv,1)*linspace(10,200,59);% reference energies for the photofraction [m,p]
%
hxr.phf_hxr = ones(nv,1)*[0.989100000000000,0.988339655172414,0.987668965517241,0.989356896551724,0.989031034482759,0.987212807881774,0.859189655172414,0.785403448275862,0.798579310344828,0.811612068965517,0.814979310344828,0.829896551724138,0.852368965517241,0.867650000000000,0.889351724137931,0.897731034482759,0.892524137931035,0.885189655172414,0.869151724137931,0.843051724137931,0.811848275862069,0.783398275862069,0.750124137931035,0.713270689655172,0.675758620689655,0.641568965517241,0.607589655172414,0.572620689655172,0.543957688898009,0.517936131250000,0.492757544458603,0.469109351252824,0.446383562266070,0.424859375183068,0.404583550678268,0.385676692822773,0.367324297095619,0.350571874834707,0.334587525014701,0.319759405439900,0.305584115182563,0.292365143753521,0.280010211403678,0.268542254716992,0.257775076608244,0.247500902391716,0.237734384903781,0.228674846769810,0.220286486976579,0.212356118425335,0.204708687015250,0.197592529945717,0.190965316162078,0.184581831069176,0.178537342422905,0.172970278041070,0.167639419086498,0.162599448271287,0.157740728800000];% detector efficiency
%
hxr.res_hxr = ones(nv,1)*[6,-0.9];% fit parameters of the energy resolution of the detectors [m,2] (Parameters approximately adapted for 57Co and 241Am spectra in measured in the lab)
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
hxr.kmin = 50;% standard minimum value for Tph calculation (LH : 50; EC : 35)
hxr.kmax = 110;% standard maximum value for Tph calculation (LH : 110; EC : 75)
hxr.kphot = linspace(10,200,59);%Photon energy in keV
%
hxr.kdiag_hxr = hxr.kphot;%Measured photon energy spectrum (keV) [1,k]
%