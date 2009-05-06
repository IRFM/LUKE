% script make_wave_MST_400ka
%
% runs C3PO based on formatted ray launching parameters and builds the WAVE structure
%
% by 	J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr> 
% and   Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr>
%
clear all
close all
clc
%
id_wave = 'RFP_LH';
%
% Equilibrium parameters
%
id_equil = 'RFP';%For plasma equilibrium
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
%
% initial ray conditions
%
ids_rayinit = {'LH'};
paths_rayinit = {''};
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2)for the function main_C3PO_jd.m (MDC toolbox must be installed for option 1)
C3POparam.clustermode.main_C3PO_jd.timeout = 300;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
C3POparam.clustermode.main_C3PO_jd.size = 4;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
%
% Display parameters
%
C3POdisplay.ray = 1;
C3POdisplay.equilibrium = 1;
C3POdisplay.p_opt = 2;%Printing or saving option of the figures
%
% Wave parameters
%
waveparam.mmode = -1;%cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
%
%Option parameter for FLR effects and cross-comparison between old FP code: 
%	- (0): all FLR effects
%	- (1): small FLR effects and 1/vpar dependence
%	- (2): small FLR effects and no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
waveparam.opt_rf = 1;
%
waveparam.dsmin = Inf;%minimum size for ray fragments
waveparam.cut_fac = Inf;% the ray is cut when P/P_in = exp(-10*cut_fac). Use Inf if the whole ray is to be kept
%
n_rf_list = 0;
%
% -------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium
%
% Equilibrium parameters for the ray-tracing
%
fitparam.method = 'pchip';%nearest,spline,pchip,cubic
fitparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
fitparam.opt_load = 1;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 1000;
rayparam.dt0 = 1.e-4;
rayparam.drho = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 30000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
%
% -------------------------------------------------------------------------
%
% Load structures
%
[equil,rayinits] = load_structures_yp('equil',id_equil,path_equil,'rayinits',ids_rayinit,paths_rayinit);
%
% C3P0 ray tracing
%
wave = main_C3PO_jd(id_wave,equil,rayinits{1},waveparam,fitparam,rayparam,C3POdisplay,C3POparam);
%
% Wave processing and relativistic linear damping
%
wave = wave_process_jd(equil,wave,n_rf_list);
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);
%
info_dke_yp(2,'Wave parameters saved');

