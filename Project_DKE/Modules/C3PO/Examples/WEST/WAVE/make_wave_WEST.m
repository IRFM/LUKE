% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
%function [] = make_wave_PLTtest
% script make_wave_test_RT
%
% Parameters for test mode ray-tracing calculations
% This function has a benchmarking purpose only
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
close all
clear all
clc
%
id_wave = 'WEST_54952';
flag_analytic = 4;
p_opt = -1;
%
% Path parameters
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% Equilibrium parameters
%
id_equil = 'WEST_54952_4.44_4.55_1_METIS_LH_ALOHA_10L_#1';%For plasma equilibrium
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% -------------------------------------------------------------------------
%
% Load structures
%
[equil,dkepath] = load_structures_yp('equil',id_equil,path_equil,'dkepath',id_dkepath,path_dkepath);
%
% initial ray conditions
%
omega_rf = [3.7]*2*pi*1e9;
nparmax = 8;
resolution = 0;%low resolution (fast calculations): 0, high resolution (slow calculations): 1
% 
rho0 = 0.99;
theta0 = 0.0;
phi0 = 0.0;
%
m0 = 20;
n0 = NaN;
Npar0 = 1.9;%initial index of refraction
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
C3POdisplay.ray = 0;
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
fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.method = 'spline';%nearest,spline,pchip
fitparam.nharm = NaN;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 40000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
%
rayparam.metricmode = 1;% 1 : Only curvilinear metric (analytic or numeric); 2 : Both curvilinear and cartesian metric
rayparam.rhoswitch = 0.1;% Radial position at which the switch occurs when metricmode = 2 (default value)
rayparam.deltaswitch = 0.001;% Delta  switch between (rho,theta) <-> (X,Y) to avoid oscillations between modes (default value)
rayparam.substitution_method = 7;%Method of substitution : 1->dichotomy1D, 2->dichotomy2D, 3->newton_numeric1D, 4->newton_numeric2D, 5->newton_analytic1D, 6->newton_analytic2D, 7->newton_mix2D (default value)
%
% =========================================================================
%
% C3P0 ray tracing
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
C3POparam.clustermode.main_C3PO_jd.scheduler.mode = mdce_mode_main_C3PO_jd;%MatLab distributed computing environment
%
% ray-tracing calculations
%
equil_fit = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
%
wave_numeric = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[],[],0);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium)');
%
save_str = ['WAVE_',id_wave,'.mat'];
save(save_str,'id_wave','wave_numeric');
%
%
info_dke_yp(2,'Wave parameters saved');
%
% --- display results ---
%
waves = {wave_numeric};
rays = {wave_numeric.rays{1}};
%
legs = {'Numeric'};
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
if ~isempty(rays{1})
    disp(['N||0 (from ray) = ',num2str(abs(real(rays{1}.sNpar(1))))]);
    npar0 = abs(real(rays{1}.sNpar(1)));
else
    disp(['N||0 = ',num2str(npar0)]);
end
%
[na,gamma_KAM_exact,gamma_KAM_approximate,open_upperboundaries_propagationdomain,intersection,Npar_gap_min,R_kinematic_gap_min] = LH_acces_yp(equil,omega_rf,rays{1},npar0,nparmax,resolution);
%
    