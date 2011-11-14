% script make_wave_test_RT
%
% Parameters for test mode ray-tracing calculations
% This function has a benchmarking purpose only
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
clear all
close all
clc
%
id_wave = 'JETliketest1p8';
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
% Display parameters
%
C3POdisplay_pchip.ray = 1;
C3POdisplay_pchip.equilibrium = 0;
C3POdisplay_pchip.p_opt = 2;%Printing or saving option of the figures
C3POdisplay_pchip.mdce = 1;%for distributed computing
%
C3POdisplay_spline.ray = 0;
C3POdisplay_spline.equilibrium = 0;
C3POdisplay_spline.p_opt = 0;%Printing or saving option of the figures
C3POdisplay_spline.mdce = 0;%for distributed computing
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
fitparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
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
fitparam.method = 'pchip';%nearest,spline,pchip,cubic
tstart = tic;
equil_fit_pchip = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
telapsed_equil_pchip = toc(tstart);
%
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated with pchip method.']);
if C3POdisplay_pchip.equilibrium,testfitequil_yp(equil,equil_fit_pchip);end
%
fitparam.method = 'spline';%nearest,spline,pchip,cubic
tstart = tic;
equil_fit_spline = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
telapsed_equil_spline = toc(tstart);
%
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated with spline method.']);
if C3POdisplay_spline.equilibrium,testfitequil_yp(equil,equil_fit_spline);end
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
BPHI_a0_fit = ppval(equil_fit_pchip.BPHI_fit.pp_a0,rho0);
BPHI_an_fit = ppval(equil_fit_pchip.BPHI_fit.pp_an,rho0);
BPHI_bn_fit = ppval(equil_fit_pchip.BPHI_fit.pp_bn,rho0);
%
% Build interpolated magnetic fields
%	
[xBx] = calcval_yp(equil_fit_pchip,theta0,Bx_a0_fit,Bx_an_fit,Bx_bn_fit);
[xBy] = calcval_yp(equil_fit_pchip,theta0,By_a0_fit,By_an_fit,By_bn_fit);
[xBPHI] = calcval_yp(equil_fit_pchip,theta0,BPHI_a0_fit,BPHI_an_fit,BPHI_bn_fit);
%
xBp = sqrt(xBx.^2 + xBy.^2); 
xBt = xBPHI; 
xB = sqrt(xBt.^2 + xBp.^2);
xBphin = xBt./xB;
%
Npar0 = Nphi0.*xBphin;
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
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
tstart = tic;
wave_numeric_pchip = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil,equil_fit_pchip,rayinit,waveparam,[],rayparam,C3POdisplay_pchip,C3POparam,[],[],0);clear mex;clear functions
telapsed_ray_numeric_pchip = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with pchip method)');
%
% Calculation of Npar0 using Nphi0
%
% warning : this is valid only for m=0 cases
%
Bx_a0_fit = ppval(equil_fit_spline.Bx_fit.pp_a0,rho0);
Bx_an_fit = ppval(equil_fit_spline.Bx_fit.pp_an,rho0);
Bx_bn_fit = ppval(equil_fit_spline.Bx_fit.pp_bn,rho0);
%
By_a0_fit = ppval(equil_fit_spline.By_fit.pp_a0,rho0);
By_an_fit = ppval(equil_fit_spline.By_fit.pp_an,rho0);
By_bn_fit = ppval(equil_fit_spline.By_fit.pp_bn,rho0);
%
BPHI_a0_fit = ppval(equil_fit_spline.BPHI_fit.pp_a0,rho0);
BPHI_an_fit = ppval(equil_fit_spline.BPHI_fit.pp_an,rho0);
BPHI_bn_fit = ppval(equil_fit_spline.BPHI_fit.pp_bn,rho0);
%
% Build interpolated magnetic fields
%	
[xBx] = calcval_yp(equil_fit_spline,theta0,Bx_a0_fit,Bx_an_fit,Bx_bn_fit);
[xBy] = calcval_yp(equil_fit_spline,theta0,By_a0_fit,By_an_fit,By_bn_fit);
[xBPHI] = calcval_yp(equil_fit_spline,theta0,BPHI_a0_fit,BPHI_an_fit,BPHI_bn_fit);
%
xBp = sqrt(xBx.^2 + xBy.^2); 
xBt = xBPHI; 
xB = sqrt(xBt.^2 + xBp.^2);
xBphin = xBt./xB;
%
Npar0 = Nphi0.*xBphin;
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
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
tstart = tic;
wave_numeric_spline = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil,equil_fit_spline,rayinit,waveparam,[],rayparam,C3POdisplay_spline,C3POparam,[],[],0);clear mex;clear functions
telapsed_ray_numeric_spline = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with spline method)');
%
tstart = tic;
wave_analytic = main_C3PO_jd(dkepath,[id_wave,'_analytic'],equil,equil_fit_pchip,rayinit,waveparam,[],rayparam,C3POdisplay_pchip,C3POparam,[],[],flag_analytic);
telapsed_ray_analytic = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (analytic magnetic equilibrium)');
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
save(save_str,'id_wave','wave_numeric_pchip','wave_numeric_spline','wave_analytic','equil_fit_pchip','equil_fit_spline');
%
info_dke_yp(2,'Wave parameters saved');
%
disp(['Elapsed time (s):',num2str(telapsed_equil_pchip),' for interpolating MHD equilibrium (PCHIP interp. technique)']);
disp(['Elapsed time (s):',num2str(telapsed_equil_spline),' for interpolating MHD equilibrium (SPLINE interp. technique)']);
%
disp(['Elapsed time (s):',num2str(telapsed_ray_numeric_pchip),' for ray calculations with numerical MHD equilibrium (PCHIP interp. technique)']);
disp(['Elapsed time (s):',num2str(telapsed_ray_numeric_spline),' for ray calculations with numerical MHD equilibrium (SPLINE interp. technique)']);
disp(['Elapsed time (s):',num2str(telapsed_ray_analytic),' for ray calculations with analytical MHD equilibrium']);
%
% --- display results ---
%
rays = {wave_numeric_pchip.rays{1},wave_numeric_spline.rays{1},wave_analytic.rays{1}};
%
legs = {'Numeric - pchip','Numeric - spline','Analytic';...
       'Numeric_pchip','Numeric_spline','Analytic'};
%
equil_fit = [equil_fit_pchip,equil_fit_spline,equil_fit_pchip];
%
filename = ['Fig_',id_wave];
%
opt.p_opt = C3POdisplay_pchip.p_opt;
opt.ntheta_fit = 65;
opt.nrho_fit = 15;
opt.propvar = 1;   
%
graph_comp_RT_jd(rays,legs,equil_fit,filename,opt)
%


