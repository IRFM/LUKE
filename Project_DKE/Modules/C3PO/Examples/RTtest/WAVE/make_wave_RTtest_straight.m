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
id_wave = 'RTtest_straight';
flag_analytic = 1;
%
% Path parameters
%
id_dkepath = 'LOCAL';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
id_equil = 'RTtest_vacuum';%For plasma equilibrium
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% initial ray conditions
%
omega_rf = [5.3015e-2*10000]*2*pi*1e9;%GHz (clum_norm = 1 for f_rf = 5.3015e-2, but limitation in m values)
% 
rho0 = 0.98;
theta0 = pi/4;
phi0 = 0.0;
%
m0 = -0.3*10000;
n0 = NaN;
Npar0 = 0.5;%initial index of refraction
%
dNpar0 = NaN;
P0_2piRp = NaN;
%
% Display parameters
%
C3POdisplay.ray = 1;
C3POdisplay.equilibrium = 0;
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
waveparam.opt_rf = NaN;
%
waveparam.dsmin = NaN;%minimum size for ray fragments
%
% -------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium
%
fitparam.equil.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.equil.method = 'pchip';%nearest,spline,pchip,cubic
fitparam.equil.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.equil.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 100000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 0;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = Inf;%value of optical depth beyond which the wave is considered absorbed
%
% -------------------------------------------------------------------------
%
% Load structures
%
[equil,dkepath] = load_structures_yp('equil',id_equil,path_equil,'dkepath',id_dkepath,path_dkepath);
%
% =========================================================================
%
% C3P0 ray tracing
%
% Vectorial description of the magnetic equilibrium
%
equil_fit = fitequil_yp(equil,fitparam.equil.mode_equil,fitparam.equil.method,fitparam.equil.ngridresample,fitparam.equil.nharm);%Build vectorized magnetic equilibrium structure
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
if C3POdisplay.equilibrium,testfitequil_yp(equil,equil_fit);end
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
% -------------------------------------------------------------------------
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
wave_numeric = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[],[],0);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium)');
%
wave_analytic = main_C3PO_jd(dkepath,[id_wave,'_analytic'],equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[],[],flag_analytic);
%
info_dke_yp(2,'Ray trajectories calculated (analytic magnetic equilibrium)');
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
save(save_str,'id_wave','wave_numeric','wave_analytic');
%
info_dke_yp(2,'Wave parameters saved');
%
% --- display results ---
%
rays = {wave_numeric.rays{1},wave_analytic.rays{1}};
%
legs = {'Numeric','Analytic'};
%
filename = ['Fig_',id_wave];
%
opt.p_opt = C3POdisplay.p_opt;
opt.ntheta_fit = 65;
opt.nrho_fit = 15;
opt.propvar = 1;   
%
graph_comp_RT_jd(rays,legs,'',filename,opt)
%
