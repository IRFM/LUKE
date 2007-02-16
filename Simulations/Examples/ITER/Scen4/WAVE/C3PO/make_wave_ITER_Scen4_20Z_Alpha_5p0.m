% script make_wave_ITER_Scen4
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
id_wave = '20Z_Alpha_5p0';
%
% Equilibrium parameters
%
id_equil = 'ITER_Scen4_IAEA06';%For plasma equilibrium
path_equil = '../../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
%
% initial ray conditions
%
id_rayinit = id_wave;
path_rayinit = '';
%
% Display parameters
%
display.ray = 1;
display.equilibrium = 0;
display.p_opt = -1;%Printing or saving option of the figures
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
waveparam.opt_rf = 0;
%
n_rf_list = 0;
%
% -------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium
%
% Equilibrium parameters for the ray-tracing
%
fitparam.method = 'spline';%nearest,spline,pchip,cubic
fitparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
fitparam.opt_load = 1;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 20000;
rayparam.dt0 = 1.e-4;
rayparam.drho = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 30000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
%
% -------------------------------------------------------------------------
%
% Load equilibrium
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	return
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
% load initial ray conditions 
%
if exist([path_rayinit,'RAYINIT_',id_equil,'_',id_rayinit,'.mat']) == 0,%Initial ray conditions
	info_dke_yp(2,[path_rayinit,'RAYINIT_',id_equil,'_',id_rayinit,'.mat does not exist']);
	return
else
    eval(['load ',path_rayinit,'RAYINIT_',id_equil,'_',id_rayinit,'.mat']);
	info_dke_yp(2,'Structure ''rayinit'' successfully loaded');
end
%
% C3P0 ray tracing
%
wave = main_C3PO_jd(id_wave,equil,rayinit,waveparam,fitparam,rayparam,display);
%
% Wave processing and relativistic linear damping
%
wave = wave_process_jd(equil,wave,n_rf_list);
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);
%
info_dke_yp(2,'Wave parameters saved');

