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
id_wave = 'JETliketest2p0';
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
Nphi0 = -2.0;%initial index of refraction
%
dNpar0 = NaN;
P0_2piRp = NaN;
%
% Display parameters
%
C3POdisplay.ray = 0;
C3POdisplay.equilibrium = 0;
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
rayparam.testmode = 1;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 10000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 30000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
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
if C3POdisplay.equilibrium,testfitequil_yp(equil,equil_fit_pchip);end
%
fitparam.method = 'spline';%nearest,spline,pchip,cubic
tstart = tic;
equil_fit_spline = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
telapsed_equil_spline = toc(tstart);
%
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated with spline method.']);
if C3POdisplay.equilibrium,testfitequil_yp(equil,equil_fit_spline);end
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
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',0,dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
tstart = tic;
wave_numeric_pchip = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil_fit_pchip,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],0);clear mex;clear functions
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
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',0,dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
tstart = tic;
wave_numeric_spline = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil_fit_spline,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],0);clear mex;clear functions
telapsed_ray_numeric_spline = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with spline method)');
%
tstart = tic;
wave_analytic = main_C3PO_jd(dkepath,[id_wave,'_analytic'],equil_fit_pchip,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],flag_analytic);
telapsed_ray_analytic = toc(tstart);
%
info_dke_yp(2,'Ray trajectories calculated (analytic magnetic equilibrium)');
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave_numeric_pchip wave_numeric_spline wave_analytic']);
%
info_dke_yp(2,'Wave parameters saved');
%
% For poloidal ray trajectory comparison
%
ntheta_fit= 65;
rho_fit = linspace(0,1,15);
theta_fit = linspace(0,2*pi,ntheta_fit);
phi_fit = linspace(0,2*pi,ntheta_fit);
x_a0_fit = ppval(equil_fit_pchip.x_fit.pp_a0,rho_fit);
x_an_fit = ppval(equil_fit_pchip.x_fit.pp_an,rho_fit);
x_bn_fit = ppval(equil_fit_pchip.x_fit.pp_bn,rho_fit);
y_a0_fit = ppval(equil_fit_pchip.y_fit.pp_a0,rho_fit);
y_an_fit = ppval(equil_fit_pchip.y_fit.pp_an,rho_fit);
y_bn_fit = ppval(equil_fit_pchip.y_fit.pp_bn,rho_fit);
%
for ii = 1:ntheta_fit,
   R_fit_pchip(:,ii) = equil_fit_pchip.Rp + x_a0_fit.' + x_an_fit*cos(equil_fit_pchip.x_fit.n*theta_fit(ii)) + x_bn_fit*sin(equil_fit_pchip.x_fit.n*theta_fit(ii));
   Z_fit_pchip(:,ii) = equil_fit_pchip.Zp + y_a0_fit.' + y_an_fit*cos(equil_fit_pchip.y_fit.n*theta_fit(ii)) + y_bn_fit*sin(equil_fit_pchip.y_fit.n*theta_fit(ii));
end
%
Rmin_pchip = min(min(R_fit_pchip));
Rmax_pchip = max(max(R_fit_pchip));
Zmin_pchip = min(min(Z_fit_pchip));
Zmax_pchip = max(max(Z_fit_pchip));
%
x_a0_fit = ppval(equil_fit_spline.x_fit.pp_a0,rho_fit);
x_an_fit = ppval(equil_fit_spline.x_fit.pp_an,rho_fit);
x_bn_fit = ppval(equil_fit_spline.x_fit.pp_bn,rho_fit);
y_a0_fit = ppval(equil_fit_spline.y_fit.pp_a0,rho_fit);
y_an_fit = ppval(equil_fit_spline.y_fit.pp_an,rho_fit);
y_bn_fit = ppval(equil_fit_spline.y_fit.pp_bn,rho_fit);
%
for ii = 1:ntheta_fit,
   R_fit_spline(:,ii) = equil_fit_spline.Rp + x_a0_fit.' + x_an_fit*cos(equil_fit_spline.x_fit.n*theta_fit(ii)) + x_bn_fit*sin(equil_fit_spline.x_fit.n*theta_fit(ii));
   Z_fit_spline(:,ii) = equil_fit_spline.Zp + y_a0_fit.' + y_an_fit*cos(equil_fit_spline.y_fit.n*theta_fit(ii)) + y_bn_fit*sin(equil_fit_spline.y_fit.n*theta_fit(ii));
end
%
Rmin_spline = min(min(R_fit_spline));
Rmax_spline = max(max(R_fit_spline));
Zmin_spline = min(min(Z_fit_spline));
Zmax_spline = max(max(Z_fit_spline));
%
figure('Name','Poloidal ray trajectory')
pmode_ray_pchip = wave_numeric_pchip.rays{1}.spmode;
pmode_ray_spline = wave_numeric_spline.rays{1}.spmode;
%
graph1D_jd(wave_numeric_pchip.rays{1}.sx(pmode_ray_pchip) + equil_fit_pchip.Rp,wave_numeric_pchip.rays{1}.sy(pmode_ray_pchip) + equil_fit_pchip.Zp,0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin_pchip,Rmax_pchip],[Zmin_pchip,Zmax_pchip],'none','.','r',2);drawnow;hold on
graph1D_jd(wave_numeric_pchip.rays{1}.sx(~pmode_ray_pchip) + equil_fit_pchip.Rp,wave_numeric_pchip.rays{1}.sy(~pmode_ray_pchip) + equil_fit_pchip.Zp,0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin_pchip,Rmax_pchip],[Zmin_pchip,Zmax_pchip],'none','.','b',2);drawnow;hold on
%graph1D_jd(wave_numeric_spline.rays{1}.sx(pmode_ray_spline) + equil_fit_spline.Rp,wave_numeric_spline.rays{1}.sy(pmode_ray_spline) + equil_fit_spline.Zp,0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin_spline,Rmax_spline],[Zmin_spline,Zmax_spline],'none','.','r',2);drawnow;hold on
%graph1D_jd(wave_numeric_spline.rays{1}.sx(~pmode_ray_spline) + equil_fit_spline.Rp,wave_numeric_spline.rays{1}.sy(~pmode_ray_spline) + equil_fit_spline.Zp,0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin_spline,Rmax_spline],[Zmin_spline,Zmax_spline],'none','.','b',2);drawnow;hold on
%
graph1D_jd(R_fit_pchip,Z_fit_pchip,0,0,'','','',NaN,[Rmin_pchip,Rmax_pchip],[Zmin_pchip,Zmax_pchip],'-','none','b',1);drawnow
graph1D_jd(R_fit_pchip',Z_fit_pchip',0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin_pchip,Rmax_pchip],[Zmin_pchip,Zmax_pchip],'-','none','b',1);hold on
axis('equal');
print_jd(C3POdisplay.p_opt,[id_wave,'_poloidal_trajectory']);
%
figure('Name','Normalized radial position comparison')
graph1D_jd(abs(wave_numeric_pchip.rays{1}.sphi/2/pi),wave_numeric_pchip.rays{1}.srho,0,0,'abs(\phi)/2\pi','\rho',['Normalized radial position'],NaN,'','','--','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_numeric_spline.rays{1}.sphi/2/pi),wave_numeric_spline.rays{1}.srho,0,0,'abs(\phi)/2\pi','\rho',['Normalized radial position'],NaN,'','',':','none','b',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.srho,0,0,'abs(\phi)/2\pi','\rho',['Normalized radial position'],NaN,'','','-','none','k',2);drawnow;hold on
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_rho']);
%
figure('Name','Parallel wave refractive index comparison')
graph1D_jd(abs(wave_numeric_pchip.rays{1}.sphi/2/pi),wave_numeric_pchip.rays{1}.sNpar,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','','--','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_numeric_spline.rays{1}.sphi/2/pi),wave_numeric_spline.rays{1}.sNpar,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','',':','none','b',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.sNpar,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','','-','none','k',2);drawnow;hold on
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_Npar']);
%
figure('Name','Dispersion relation comparison')
graph1D_jd(abs(wave_numeric_pchip.rays{1}.sphi/2/pi),wave_numeric_pchip.rays{1}.sD,0,1,'abs(\phi)/2\pi','det(D)',['Dispersion relation'],NaN,'','','--','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_numeric_spline.rays{1}.sphi/2/pi),wave_numeric_spline.rays{1}.sD,0,1,'abs(\phi)/2\pi','det(D)',['Dispersion relation'],NaN,'','',':','none','b',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.sD,0,1,'abs(\phi)/2\pi','det(D)',['Dispersion relation'],NaN,'','','-','none','k',2);drawnow;hold on
legend('PCHIP','SPLINE','Analytic','Location','SouthEast')
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_Disp']);
%
figure('Name','Normalized poloidal position comparison')
graph1D_jd(abs(wave_numeric_pchip.rays{1}.sphi/2/pi),wave_numeric_pchip.rays{1}.stheta/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi',['Poloidal angle'],NaN,'','','--','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_numeric_spline.rays{1}.sphi/2/pi),wave_numeric_spline.rays{1}.stheta/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi',['Poloidal angle'],NaN,'','',':','none','b',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.stheta/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi',['Poloidal angle'],NaN,'','','-','none','k',2);drawnow;hold on
legend('Numeric (pchip)','Numeric (spline)','Analytic')
figure('Name','Poloidal mode number comparison')
graph1D_jd(abs(wave_numeric_pchip.rays{1}.sphi/2/pi),wave_numeric_pchip.rays{1}.spmode,0,0,'abs(\phi)/2\pi','m',['Poloidal mode number'],NaN,'','','--','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_numeric_spline.rays{1}.sphi/2/pi),wave_numeric_spline.rays{1}.spmode,0,0,'abs(\phi)/2\pi','m',['Poloidal mode number'],NaN,'','',':','none','b',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.spmode,0,0,'abs(\phi)/2\pi','m',['Poloidal mode number'],NaN,'','','-','none','k',2);drawnow;hold on
legend('Numeric (pchip)','Numeric (spline)','Analytic')
figure('Name','Perpendicular wave refractive index comparison')
graph1D_jd(abs(wave_numeric_pchip.rays{1}.sphi/2/pi),wave_numeric_pchip.rays{1}.sNperp,0,0,'abs(\phi)/2\pi','N_{perp}',['Perpendicular wave refractive index'],NaN,'','','--','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_numeric_spline.rays{1}.sphi/2/pi),wave_numeric_spline.rays{1}.sNperp,0,0,'abs(\phi)/2\pi','N_{perp}',['Perpendicular wave refractive index'],NaN,'','',':','none','b',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.sNperp,0,0,'abs(\phi)/2\pi','N_{perp}',['Perpendicular wave refractive index'],NaN,'','','-','none','k',2);drawnow;hold on
legend('Numeric (pchip)','Numeric (spline)','Analytic')
%
disp(['Elapsed time (s):',num2str(telapsed_equil_pchip),' for interpolating MHD equilibrium (PCHIP interp. technique)']);
disp(['Elapsed time (s):',num2str(telapsed_equil_spline),' for interpolating MHD equilibrium (SPLINE interp. technique)']);
%
disp(['Elapsed time (s):',num2str(telapsed_ray_numeric_pchip),' for ray calculations with numerical MHD equilibrium (PCHIP interp. technique)']);
disp(['Elapsed time (s):',num2str(telapsed_ray_numeric_spline),' for ray calculations with numerical MHD equilibrium (SPLINE interp. technique)']);
disp(['Elapsed time (s):',num2str(telapsed_ray_analytic),' for ray calculations with analytical MHD equilibrium']);