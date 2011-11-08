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
format long
%
id_wave = 'JETliketest2p0_fluct_noripple';
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
id_fluct = 'test_noripple';%For density and magnetic field fluctuation
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
omega_rf = [3.7]*2*pi*1e9;
% 
rho0 = 0.968;
theta0 = [pi/12];
phi0 = 0;%between two toroidal magnetic field coils (phi = 0 corresponds to a coil position)
%
m0 = 0;
n0 = NaN;
Nphi0 = -2.0;%initial index of refraction
%
dNpar0 = NaN;
P0_2piRp = NaN;
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
waveparam.opt_rf = NaN;
%
waveparam.dsmin = NaN;%minimum size for ray fragments
%
% -----------------------------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium and the plasma fluctuations (if calculated)
%
fitparam.equil.method = 'pchip';%nearest,spline,pchip,cubic
fitparam.equil.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.equil.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
fitparam.equil.mode_equil = 1;%(rho,theta) -> 0, (x,y) -> 1
%
fitparam.fluct.mode_equil = fitparam.equil.mode_equil;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.fluct.method = 'pchip';%nearest,spline,pchip,cubic
fitparam.fluct.nharm = 32;%Number of harmonics in the plasma fluctuations interpolation (less than ntheta_equil/2)
fitparam.fluct.ngridresample = 201;%Number of grid points for resampling the radial profile of plasma fluctuations parameters (very slow if too big !!)
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 5000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;%
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 10000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed (usually 20. Otherwise Inf)
rayparam.kextra = 1000;%number of calculations performed beyond the full linear absorption (for quasilinear calculations which may require more points)
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
   fluct = fluctphase_yp(fluct,0);%Mersenne-Twitter pseudorandom generator -> 0, Matlab rand (reset by clock) -> 1
   [fluct_fit] = fitfluct_yp(fluct,fitparam.equil.mode_equil,fitparam.fluct.method,fitparam.fluct.ngridresample,fitparam.fluct.nharm);%Build vectorized plasma fluctuation structure
   info_dke_yp(2,['Vectorial form of the plasma fluctuations ',equil.id,'_',fluct.id,' is calculated.']);
   if C3POdisplay.fluctuations,testfitfluct_yp(equil_fit,fluct,fluct_fit);end
end
%
% Calculation of Npar0 using Nphi0
%
% warning : this is valid only for m=0 cases
%
Bx_a0_fit = ppval(equil_fit.Bx_fit.pp_a0,rho0);
Bx_an_fit = ppval(equil_fit.Bx_fit.pp_an,rho0);
Bx_bn_fit = ppval(equil_fit.Bx_fit.pp_bn,rho0);
%
By_a0_fit = ppval(equil_fit.By_fit.pp_a0,rho0);
By_an_fit = ppval(equil_fit.By_fit.pp_an,rho0);
By_bn_fit = ppval(equil_fit.By_fit.pp_bn,rho0);
%
BPHI_a0_fit = ppval(equil_fit.BPHI_fit.pp_a0,rho0);
BPHI_an_fit = ppval(equil_fit.BPHI_fit.pp_an,rho0);
BPHI_bn_fit = ppval(equil_fit.BPHI_fit.pp_bn,rho0);
%
% Build interpolated magnetic fields
%
for jt = 1:length(theta0),
    [xBx] = calcval_yp(equil_fit,theta0(jt),Bx_a0_fit,Bx_an_fit,Bx_bn_fit);
    [xBy] = calcval_yp(equil_fit,theta0(jt),By_a0_fit,By_an_fit,By_bn_fit);
    [xBPHI] = calcval_yp(equil_fit,theta0(jt),BPHI_a0_fit,BPHI_an_fit,BPHI_bn_fit);
    %
    xBp = sqrt(xBx.^2 + xBy.^2); 
    xBt = xBPHI; 
    xB = sqrt(xBt.^2 + xBp.^2);
    xBphin = xBt./xB;
    %
    Npar0(jt) = Nphi0.*xBphin;
end
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
rayinit_theta = rayinit;
rayinit_theta.ytheta0 = rayinit_theta.ytheta0(jt);
rayinit_theta.yNpar0 = rayinit_theta.yNpar0(jt);
%
tstart = tic;
wave_nofluct = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil,equil_fit,rayinit_theta,waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],0);clear mex;clear functions
telapsed_ray_nofluct = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with no plasma fluctuations)');
%
tstart = tic;
wave_fluct = main_C3PO_jd(dkepath,[id_wave,'_fluct'],equil,equil_fit,rayinit_theta,waveparam,[],rayparam,C3POdisplay,C3POparam,[],fluct_fit,0);
telapsed_ray_fluct = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with plasma fluctuations)');
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave_fluct wave_nofluct fluct']);
%
info_dke_yp(2,'Wave parameters saved');
%
ntheta_fit= 65;
rho_fit = linspace(0,1,15);
theta_fit = linspace(0,2*pi,ntheta_fit);
phi_fit = linspace(0,2*pi,ntheta_fit);
x_a0_fit = ppval(equil_fit.x_fit.pp_a0,rho_fit);
x_an_fit = ppval(equil_fit.x_fit.pp_an,rho_fit);
x_bn_fit = ppval(equil_fit.x_fit.pp_bn,rho_fit);
y_a0_fit = ppval(equil_fit.y_fit.pp_a0,rho_fit);
y_an_fit = ppval(equil_fit.y_fit.pp_an,rho_fit);
y_bn_fit = ppval(equil_fit.y_fit.pp_bn,rho_fit);
%
for ii = 1:ntheta_fit,
   R_fit(:,ii) = equil_fit.Rp + x_a0_fit.' + x_an_fit*cos(equil_fit.x_fit.n*theta_fit(ii)) + x_bn_fit*sin(equil_fit.x_fit.n*theta_fit(ii));
   Z_fit(:,ii) = equil_fit.Zp + y_a0_fit.' + y_an_fit*cos(equil_fit.y_fit.n*theta_fit(ii)) + y_bn_fit*sin(equil_fit.y_fit.n*theta_fit(ii));
end
%
Rmin = min(min(R_fit));
Rmax = max(max(R_fit));
Zmin = min(min(Z_fit));
Zmax = max(max(Z_fit));
%
figure('Name','Poloidal ray trajectory comparison')
graph1D_jd(wave_nofluct.rays{1}.sx + equil_fit.Rp,wave_nofluct.rays{1}.sy + equil_fit.Zp,0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);drawnow;hold on
graph1D_jd(wave_fluct.rays{1}.sx + equil_fit.Rp,wave_fluct.rays{1}.sy + equil_fit.Zp,0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',2);drawnow;hold on
graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)',['Poloidal Ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
axis('equal');
print_jd(C3POdisplay.p_opt,[id_wave,'_poloidal_trajectory']);
%
figure('Name','Normalized radial position comparison')
graph1D_jd(abs(wave_nofluct.rays{1}.sphi/2/pi),wave_nofluct.rays{1}.srho,0,0,'abs(\phi)/2\pi','\rho',['Normalized radial position'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_fluct.rays{1}.sphi/2/pi),wave_fluct.rays{1}.srho,0,0,'abs(\phi)/2\pi','\rho',['Normalized radial position'],NaN,'','','-','none','b',2);drawnow;hold on
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_rho']);
%
figure('Name','Parallel wave refractive index comparison')
graph1D_jd(abs(wave_nofluct.rays{1}.sphi/2/pi),real(wave_nofluct.rays{1}.sNpar),0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_fluct.rays{1}.sphi/2/pi),real(wave_fluct.rays{1}.sNpar),0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','','-','none','b',2);drawnow;hold on
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_Npar']);
%
figure('Name','Dispersion relation comparison')
graph1D_jd(abs(wave_nofluct.rays{1}.sphi/2/pi),wave_nofluct.rays{1}.sD,0,1,'abs(\phi)/2\pi','det(D)',['Dispersion relation'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_fluct.rays{1}.sphi/2/pi),wave_fluct.rays{1}.sD,0,1,'abs(\phi)/2\pi','det(D)',['Dispersion relation'],NaN,'','','-','none','b',2);drawnow;hold on
legend('No n_e fluctuations','With n_e fluctuations','Location','SouthEast')
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_Disp']);
%
disp(['Elapsed time (s):',num2str(telapsed_ray_nofluct),' for ray calculations without density fluctuations (PCHIP interp. technique)']);
disp(['Elapsed time (s):',num2str(telapsed_ray_fluct),' for ray calculations with density fluctuations (PCHIP interp. technique)']);
%













