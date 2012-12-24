function rundke_metis_wave(c_opt,basestr,shotnum,shotimes,locpath_simul,locid_simul,launch,dkeparam,dkedisplay,equil,ohm,transpfaste,rayparam_in,waveparam_in,C3POparam_in)
%
if ~iscell(locpath_simul),
    path_simul = [basestr,filesep,shotnum,filesep,locpath_simul];% Simulation path (leave empty for current path)
else
    path_simul = [locpath_simul{1},basestr,filesep,shotnum,filesep,locpath_simul{2}];% Simulation path (leave empty for current path)
end    
%
% -------------------------------------------------------------------------
%
% Wave parameters
%
waveparam.mmode = -1;% cold plasma mode (1) m (-1) p, (slow/fast LH wave: -1/+1, O/X mode: -1/+1) :1
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
% ====================================================
%
waveparam = conc_struct_jd(waveparam,waveparam_in);
rayparam = conc_struct_jd(rayparam,rayparam_in);
C3POparam = conc_struct_jd(C3POparam,C3POparam_in);
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
% ====================================================
%
% start rundke_metis function
%
rundke_metis(path_simul,locid_simul,c_opt,basestr,shotnum,shotimes,dkepath,{wavestruct},equil,dkeparam,dkedisplay,ohm,transpfaste)
%