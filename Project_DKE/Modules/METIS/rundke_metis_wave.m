function rundke_metis_wave(path_simul,locid_simul,basestr,shotnum,shotimes,freq_GHz,rZ0,Npar_p,Npar_m,dNpar_p,dNpar_m,Ptot,dir,opt)
%
launch.id = ['Npar0_',num2str(abs(Npar_p))];
%
launch.type = 'LH';%wave type
launch.omega_rf = freq_GHz*2*pi*1e9;%wave angular frequency (rad/s) [1,1] (same frequency)
%
% Initial ray conditions (horizontal dimension represents different beams, vertical dimension
% represents different poloidal locations)
%
launch.bPlhtot = Ptot*[dir,(1 - dir)]*1e6;%initial power in the ray (W) (main lobe) [1,n_lobe]
launch.bNpar0 = [Npar_p,Npar_m];%Initial Npar value (main lobe) [1,n_lobe]
launch.bdNpar0 = [dNpar_p,dNpar_m];%ray spectral width for lobe width calculations [1,n_lobe]
%
launch.rZ0 = rZ0;%vertical launching positions [1,m_pol]
%
launch.m0 = 0;%initial poloidal mode number [1,1]
launch.phi0 = 0;%toroidal angle position [1,1]
launch.LFS = 1;% (-1) high field side launching, (1) low field side launching [1,1]
%
launch.i_ref = opt.i_ref;
%
% -------------------------------------------------------------------------
%
% Wave parameters
%
waveparam.mmode = opt.mode;%cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
%
%Option parameter for FLR effects and cross-comparison between old FP code: 
%	- (0): all FLR effects
%	- (1): small FLR effects and 1/vpar dependence
%	- (2): small FLR effects and no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
waveparam.opt_rf = 1;
%
waveparam.dsmin = 0.01;%minimum size for ray fragments
%
waveparam.nd = 1;%Number of transverse distance positions for beamlets
waveparam.nchi = 1;%Number of angular positions for beamlets
waveparam.ns = 1;%Smoothing parameter
%
waveparam.n_rf_list = 0;
%
% Display parameters
%
C3POdisplay.ray = 0;
C3POdisplay.equilibrium = 0;
C3POdisplay.p_opt = -1;%Printing or saving option of the figures
%
dkepath = load_structures_yp('dkepath','','');
%
load('C3POPARAM_LH.mat','fitparam','rayparam','C3POparam');
%
rayparam.reflection = opt.reflection;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
C3POparam.clustermode.main_C3PO_jd.mode = opt.ray;
%
wavestruct.id = launch.id;
wavestruct.wavesolver = 'C3PO';
wavestruct.launch = launch;
wavestruct.waveparam = waveparam;
wavestruct.fitequilparam = fitparam;
wavestruct.rayparam = rayparam;
wavestruct.C3POparam = C3POparam;
wavestruct.raydisplay = C3POdisplay;
%
dkeparam.nit_rf = 40;% maximum number of RF iterations (default : 20)
dkedisplay = struct;
equil = struct;
ohm = '';
transpfaste.Dr_model = 0;%Radial diffusion type: (0) no vpar dependence, (1) magnetic turbulence model (vpar/vth), (2) Energy dependence
transpfaste.Dr0 = 0.0;%Core radial diffusion coefficient (m^2/s)
%
% ====================================================
%
% start rundke_metis function
%
rundke_metis(path_simul,locid_simul,opt.luke,basestr,shotnum,shotimes,dkepath,{wavestruct},equil,dkeparam,dkedisplay,ohm,transpfaste)
%