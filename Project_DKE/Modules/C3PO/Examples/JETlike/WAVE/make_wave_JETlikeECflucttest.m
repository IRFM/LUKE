function [] = make_wave_JETlikeECflucttest
% script make_wave_test_RT
%
% Parameters for test mode ray-tracing calculations
% This function has a benchmarking purpose only
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
close all
%
id_wave = 'JETlikeECflucttest';
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
% Density and magnetic field fluctuation
%
id_fluct = 'noripple';%For density and magnetic field fluctuation
path_fluct = '../FLUCT/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Load structures
%
[equil,dkepath,fluct] = load_structures_yp('equil',id_equil,path_equil,'dkepath',id_dkepath,path_dkepath,'fluct',id_fluct,path_fluct);
%
% =========================================================================
%
% initial ray conditions
%
freq_GHz = 100;
%
R_L = 5.6;
Z_L = 0.1;
%
P_L = 1e-6;% [MW] 
%
cone_div = 1.08;% equivalent exp(-2) power cone divergence
cone_ori = -0.5;% equivalent cone origin
%
z_L = 0.0;% focal point
%
alpha_prater = -10;% angle between N_P and horizontal plane
beta_prater = 22;% angle between N and poloidal plane
%
% C3PO computing parameters
%
mdce_mode_main_C3PO_jd = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2)for the function main_C3PO_jd.m (MDC toolbox must be installed for option 1)
%
% Display parameters
%
C3POdisplay.ray = 0;
C3POdisplay.equilibrium = 0;
C3POdisplay.fluctuations = 0;
C3POdisplay.p_opt = 2;%Printing or saving option of the figures
C3POdisplay.mdce = 1;%for distributed computing
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
% -----------------------------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium and the plasma fluctuations (if calculated)
%
fitparam.equil.method = 'spline';%nearest,spline,pchip
fitparam.equil.nharm = NaN;%Number of harmonics in the magnetic equilibrium interpolation (NaN, Inf or empty, nharm = ntheta-1)
fitparam.equil.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
fitparam.equil.mode_equil = 1;%(rho,theta) -> 0, (x,y) -> 1
%
fitparam.fluct.mode_equil = fitparam.equil.mode_equil;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.fluct.method = 'pchip';%nearest,spline,pchip
fitparam.fluct.nharm = 32;%Number of harmonics in the plasma fluctuations interpolation (less than ntheta_equil/2)
fitparam.fluct.ngridresample = 201;%Number of grid points for resampling the radial profile of plasma fluctuations parameters (very slow if too big !!)
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 50000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 50000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 0;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
rayparam.kextra = 50;%
%
% launch structure
%
launch.id = id_wave;
launch.type = 'EC';
launch.omega_rf = [freq_GHz]*2*pi*1e9;%wave angular frequency (rad/s)
%
launch.yR_L = R_L;
launch.yZ_L = Z_L;
launch.yphi_L = 0;
launch.yalpha_L = sign(beta_prater)*pi - atan(tand(beta_prater)/cosd(alpha_prater));
launch.ybeta_L = acos(cosd(beta_prater)*sind(alpha_prater));
launch.yP_L = P_L*1e6;
launch.dNpar0 = NaN;
launch.ns = 1;%ns;
launch.method = 'spline';
%
launch.w0 = 0.3/(freq_GHz*pi*cone_div*pi/180);
launch.z_L = z_L;
%
% -------------------------------------------------------------------------
%
% C3P0 ray tracing
%
% Vectorial description of the magnetic equilibrium
%
equil_fit = fitequil_yp(equil,fitparam.equil.mode_equil,fitparam.equil.method,fitparam.equil.ngridresample,fitparam.equil.nharm);%Build vectorized magnetic equilibrium structure
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
if C3POdisplay.equilibrium,testfitequil_yp(equil,equil_fit);end
%
% Vectorial description of the plasma fluctuations
%
if ~isempty(fluct),
   fluct = fluctphase_yp(fluct);
   [fluct_fit] = fitfluct_yp(fluct,fitparam.equil.mode_equil,fitparam.fluct.method,fitparam.fluct.ngridresample,fitparam.fluct.nharm);%Build vectorized plasma fluctuation structure
   info_dke_yp(2,['Vectorial form of the plasma fluctuations ',equil.id,'_',fluct.id,' is calculated.']);
   if C3POdisplay.fluctuations,testfitfluct_yp(equil_fit,fluct,fluct_fit);end
end
%
% -------------------------------------------------------------------------
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd.scheduler.mode = mdce_mode_main_C3PO_jd;%MatLab distributed computing environment
%
% ray-tracing calculations
%
rayinit = main_rayinit_launch_jd(equil,launch);
wave_nofluct = main_C3PO_jd(dkepath,[id_wave,'_nofluct'],equil,equil_fit,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],0);clear mex;clear functions
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with no plasma fluctuations)');
%
rayinit = main_rayinit_launch_jd(equil,launch);
[wave_fluct] = main_C3PO_jd(dkepath,[id_wave,'_fluct'],equil,equil_fit,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],fluct_fit,0);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with plasma fluctuations)');
%
save_str = ['WAVE_',id_wave,'.mat'];
save(save_str,'id_wave','wave_fluct','wave_nofluct','equil_fit','fluct');
%
info_dke_yp(2,'Wave parameters saved');
%
% --- display results ---
%
waves = {wave_nofluct,wave_fluct};
rays = {wave_nofluct.rays{1},wave_fluct.rays{1}};
%
legs = {'No fluct.','With fluct.';...
       'nofluct','fluct'};
%
filename = ['Fig_',id_wave];
%
opt.p_opt = C3POdisplay.p_opt;
opt.ntheta_fit = 65;
opt.nrho_fit = 15;
opt.propvar = 1;   
%
graph_comp_RT_jd(rays,legs,equil_fit,filename,opt)
%
diary4cvs_C3PO_yp(id_wave,dkepath,waves);% diary some results for CVS validation


