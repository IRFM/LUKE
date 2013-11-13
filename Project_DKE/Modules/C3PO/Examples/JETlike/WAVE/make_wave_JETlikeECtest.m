% script make_wave_test_RT
%
% Parameters for test mode ray-tracing calculations
% This function has a benchmarking purpose only
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
close all
%
id_wave = 'JETlikeECtest';
flag_analytic = 2;
%
% Path parameters
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
id_equil = 'JETliketest';%For plasma equilibrium
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Load structures
%
[equil,dkepath] = load_structures_yp('equil',id_equil,path_equil,'dkepath',id_dkepath,path_dkepath);
%
% =========================================================================
%
% initial ray conditions
%
freq_GHz = 110;
%
R_L = 5.0;
Z_L = 0.1;
phi_L = 0;
%
P_L = 1e-6;% [MW] 
%
alpha_L = 165;% With respect to R axis
beta_L = 90;% With respect to Z axis
%
dNpar0 = 0.05;%spectral width
ns = 1000;%discrtization parameter for free space propagation
method = 'linear';%interpolation method for ray separatrix crossing
%
% Display parameters
%
C3POdisplay.ray = 1;
C3POdisplay.equilibrium = 0;
C3POdisplay.p_opt = -1;%Printing or saving option of the figures
C3POdisplay.mdce = 1;%for distributed computing
%
% Wave parameters
%
waveparam.mmode = -1;%cold plasma mode [1] : (-1) O mode (1) X mode
waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
%
%Option parameter for FLR effects and cross-comparison between old FP code: 
%	- (0): all FLR effects
%	- (1): small FLR effects and 1/vpar dependence
%	- (2): small FLR effects and no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
waveparam.opt_rf = 1;
%
waveparam.dsmin = 0;%minimum size for ray fragments
%
waveparam.nd = 1;%Number of transverse distance positions for beamlets
waveparam.nchi = 1;%Number of angular positions for beamlets
%
waveparam.n_rf_list = 1:2;
waveparam.ns = 1;%ray smoothing parameter
%
waveparam.dsmin = NaN;%minimum size for ray fragments
%
% -------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium
%
fitparam.equil.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.equil.method = 'spline';%nearest,spline,pchip
fitparam.equil.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.equil.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 1;
rayparam.tensortype = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 100000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-9;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 100000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 0;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
rayparam.kextra = 50;
%
% launch structure
%
launch.id = id_wave;
launch.type = 'EC';
launch.omega_rf = [freq_GHz]*2*pi*1e9;%wave angular frequency (rad/s)
%
launch.yR_L = R_L;
launch.yZ_L = Z_L;
launch.yphi_L = phi_L;
%
launch.yalpha_L = alpha_L*pi/180;
launch.ybeta_L = beta_L*pi/180;
%
launch.yP_L = P_L*1e6;
%
launch.dNpar0 = dNpar0;
%
launch.ns = ns;
launch.method = method;
%
launch.w0 = NaN;
launch.z_L = NaN;
%
% =========================================================================
%
% C3P0 ray tracing
%
equil_fit = fitequil_yp(equil,fitparam.equil.mode_equil,fitparam.equil.method,fitparam.equil.ngridresample,fitparam.equil.nharm);%Build vectorized magnetic equilibrium structure
%
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
if C3POdisplay.equilibrium,testfitequil_yp(equil,equil_fit);end
%
% Ray init calculation from launch
%
rayinit = main_rayinit_launch_jd(equil,launch);
%
% --------------------------------------------------------------------------
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
tstart = tic;
wave = main_C3PO_jd(dkepath,[id_wave],equil,equil_fit,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],0);clear mex;clear functions
telapsed_ray = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium)');
%
save_str = ['WAVE_',id_wave,'.mat'];
save(save_str,'id_wave','wave');
%
info_dke_yp(2,'Wave parameters saved');
%
disp(['Elapsed time (s):',num2str(telapsed_ray),' for ray calculations (PCHIP interp. technique)']);
%
diary4cvs_C3PO_yp(id_wave,dkepath,wave);% diary some results for CVS validation

