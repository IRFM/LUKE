function [] = make_wave_JETliketest_ter
% script make_wave_test_RT
%
% Parameters for test mode ray-tracing calculations
% This function has a benchmarking purpose only oncerning the (rho,theta) <-> (X,Y) coordinate transformation near the plasma core
%
% by Y. Peysson (IRFM/CEA) <yves.peysson@cea.fr>, G. Brochard (IRFM/CEA) <>, J. Decker (SPC/EPFL) <joan.decker@epfl.ch>
%
close all
%
id_wave = 'JETliketest_ter';
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
omega_rf = [3.7]*2*pi*1e9;
% 
rho0 = 0.968;
theta0 = 0.0;
phi0 = 0;
%
m0 = 0;
n0 = NaN;
Nphi0 = -1.8;%initial index of refraction
%
dNpar0 = NaN;
P0_2piRp = NaN;
%
% C3PO computing parameters
%
mdce_mode_main_C3PO_jd = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2)for the function main_C3PO_jd.m (MDC toolbox must be installed for option 1)
%
% Display parameters
%
C3POdisplay_pchip_rt.ray = 1;
C3POdisplay_pchip_rt.equilibrium = 0;
C3POdisplay_pchip_rt.p_opt = 2;%Printing or saving option of the figures
C3POdisplay_pchip_rt.mdce = 0;%for distributed computing
%
C3POdisplay_pchip_rtxy.ray = 0;
C3POdisplay_pchip_rtxy.equilibrium = 0;
C3POdisplay_pchip_rtxy.p_opt = 0;%Printing or saving option of the figures
C3POdisplay_pchip_rtxy.mdce = 0;%for distributed computing
%
C3POdisplay_analytic.ray = 0;
C3POdisplay_analytic.equilibrium = 0;
C3POdisplay_analytic.p_opt = 2;%Printing or saving option of the figures
C3POdisplay_analytic.mdce = 0;%for distributed computing
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
waveparam.opt_rf = NaN;
%
waveparam.dsmin = NaN;%minimum size for ray fragments
%
% -------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium
%
fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.nharm = NaN;%Number of harmonics in the magnetic equilibrium interpolation (NaN, Inf or empty, nharm = ntheta-1)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 10000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 0;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
%
% =========================================================================
%
% C3P0 ray tracing
%
fitparam.method = 'pchip';%nearest,spline,pchip
tstart = tic;
equil_fit_pchip = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
telapsed_equil_pchip = toc(tstart);
%
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated with pchip method.']);
if C3POdisplay_pchip_rt.equilibrium,testfitequil_yp(equil,equil_fit_pchip);end
%
% Calculation of Npar0 using Nphi0
%
% warning : this is valid only for m=0 cases
%
Bx_a0_fit = ppval(equil_fit_pchip.Bx_fit.pp_a0,rho0);
Bx_an_fit = ppval(equil_fit_pchip.Bx_fit.pp_an,rho0);
Bx_bn_fit = ppval(equil_fit_pchip.Bx_fit.pp_bn,rho0);
%
By_a0_fit = ppval(equil_fit_pchip.By_fit.pp_a0,rho0);
By_an_fit = ppval(equil_fit_pchip.By_fit.pp_an,rho0);
By_bn_fit = ppval(equil_fit_pchip.By_fit.pp_bn,rho0);
%
Bz_a0_fit = ppval(equil_fit_pchip.Bz_fit.pp_a0,rho0);
Bz_an_fit = ppval(equil_fit_pchip.Bz_fit.pp_an,rho0);
Bz_bn_fit = ppval(equil_fit_pchip.Bz_fit.pp_bn,rho0);
%
B_a0_fit = ppval(equil_fit_pchip.B_fit.pp_a0,rho0);
B_an_fit = ppval(equil_fit_pchip.B_fit.pp_an,rho0);
B_bn_fit = ppval(equil_fit_pchip.B_fit.pp_bn,rho0);
%
% Build interpolated magnetic fields
%	
[xBx] = calcval_yp(equil_fit_pchip,theta0,Bx_a0_fit,Bx_an_fit,Bx_bn_fit);
[xBy] = calcval_yp(equil_fit_pchip,theta0,By_a0_fit,By_an_fit,By_bn_fit);
[xBz] = calcval_yp(equil_fit_pchip,theta0,Bz_a0_fit,Bz_an_fit,Bz_bn_fit);
[xB] = calcval_yp(equil_fit_pchip,theta0,B_a0_fit,B_an_fit,B_bn_fit);
%
xBzn = xBz./xB;
%
Npar0 = Nphi0.*xBzn;
%
rayinit.omega_rf = omega_rf;
rayinit.yrho0 = rho0;%Initial radial position at launch
rayinit.ytheta0 = theta0;%Initial poloidal position at launch
rayinit.yphi0 = phi0;%Initial toroidal position at launch
rayinit.ym0 = m0;%Initial poloidal mode number
rayinit.yn0 = n0;%Initial toroidal mode number
rayinit.yNpar0 = Npar0;%Initial index of refraction
rayinit.ydNpar0 = dNpar0;%initial Ray spectral width
rayinit.yP0_2piRp = P0_2piRp;%Lineic initial power density initial power in the ray (W/m)
%
% --------------------------------------------------------------------------
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd.scheduler.mode = mdce_mode_main_C3PO_jd;%MatLab distributed computing environment
%
% ray-tracing calculations (rho,theta) coordinates only
%
rayparam.metricmode = 1;% 1 : Only curvilinear metric (analytic or numeric); 2 : Both curvilinear and cartesian metric
rayparam.rhoswitch = 0.1;% Radial position at which the switch occurs when metricmode = 2 (default value)
rayparam.deltaswitch = 0.001;% Delta  switch between (rho,theta) <-> (X,Y) to avoid oscillations between modes (default value)
rayparam.substitution_method = 7;%Method of substitution : 1->dichotomy1D, 2->dichotomy2D, 3->newton_numeric1D, 4->newton_numeric2D, 5->newton_analytic1D, 6->newton_analytic2D, 7->newton_mix2D (default value)
%
tstart = tic;
wave_numeric_pchip_rt = main_C3PO_jd(dkepath,[id_wave,'_numeric_pchip_rt'],equil,equil_fit_pchip,rayinit,waveparam,[],rayparam,C3POdisplay_pchip_rt,C3POparam,[],[],0);clear mex;clear functions
telapsed_ray_numeric_pchip_rt = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with pchip method and (rho,theta) coordinates only)');
%
% ray-tracing calculations (rho,theta) <-> (X,Y) conversion in the plasma core
%
rayparam.metricmode = 2;% 1 : Only curvilinear metric; 2 : Both curvilinear and cartesian metric
%
tstart = tic;
wave_numeric_pchip_rtxy = main_C3PO_jd(dkepath,[id_wave,'_numeric_pchip_rtxy'],equil,equil_fit_pchip,rayinit,waveparam,[],rayparam,C3POdisplay_pchip_rtxy,C3POparam,[],[],0);clear mex;clear functions
telapsed_ray_numeric_pchip_rtxy = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with pchip method with (rho,theta) <-> (X,Y) conversion in the plasma core)');
%
tstart = tic;
%
%rayparam.metricmode = 1;% 1 : Only curvilinear metric (analytic or numeric); 2 : Both curvilinear and cartesian metric
%
wave_analytic = main_C3PO_jd(dkepath,[id_wave,'_analytic'],equil,equil_fit_pchip,rayinit,waveparam,[],rayparam,C3POdisplay_analytic,C3POparam,[],[],flag_analytic);
telapsed_ray_analytic = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (analytic magnetic equilibrium)');
%
save_str = ['WAVE_',id_wave,'.mat'];
save(save_str,'id_wave','wave_numeric_pchip_rt','wave_numeric_pchip_rtxy','wave_analytic','equil_fit_pchip');
%
info_dke_yp(2,'Wave parameters saved');
%
disp(['Elapsed time (s):',num2str(telapsed_equil_pchip),' for interpolating MHD equilibrium (PCHIP interp. technique ']);
%
disp(['Elapsed time (s):',num2str(telapsed_ray_numeric_pchip_rt),' for ray calculations with numerical MHD equilibrium (PCHIP interp. technique, (rho,theta) coordinate only))']);
disp(['Elapsed time (s):',num2str(telapsed_ray_numeric_pchip_rtxy),' for ray calculations with numerical MHD equilibrium (PCHIP interp. technique (rho,theta) <-> (X,Y) conversion in the plasma core))']);
disp(['Elapsed time (s):',num2str(telapsed_ray_analytic),' for ray calculations with analytical MHD equilibrium']);
%
% --- display results ---
%
waves = {wave_numeric_pchip_rt,wave_numeric_pchip_rtxy,wave_analytic};
rays = {wave_numeric_pchip_rt.rays{1},wave_numeric_pchip_rtxy.rays{1},wave_analytic.rays{1}};
%
legs = {'Numeric - pchip_rt','Numeric - pchip_rtxy','Analytic';...
       'Numeric_pchip_rt','Numeric_pchip_rtxy','Analytic'};
%
equil_fit = [equil_fit_pchip];
%
filename = ['Fig_',id_wave];
%
opt.p_opt = C3POdisplay_pchip_rt.p_opt;
opt.ntheta_fit = 65;
opt.nrho_fit = 15;
opt.propvar = 1;   
%
graph_comp_RT_jd(rays,legs,equil_fit,filename,opt)
%
diary4cvs_C3PO_yp(id_wave,dkepath,waves);% diary some results for CVS validation







