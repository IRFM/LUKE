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
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',0,dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
wave_numeric = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[],[],0);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium)');
%
wave_analytic = main_C3PO_jd(dkepath,[id_wave,'_analytic'],equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[],[],flag_analytic);
%
info_dke_yp(2,'Ray trajectories calculated (analytic magnetic equilibrium)');
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave_numeric wave_analytic']);
%
info_dke_yp(2,'Wave parameters saved');
%
% For poloidal ray trajectory comparison
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
% For toroidal display
%
Xmin_fit = Rmin*cos(phi_fit);   
Ymin_fit = Rmin*sin(phi_fit); 
Xmax_fit = Rmax*cos(phi_fit);   
Ymax_fit = Rmax*sin(phi_fit); 
Xp_fit = equil_fit.Rp*cos(phi_fit);   
Yp_fit = equil_fit.Rp*sin(phi_fit);
%
figure('Name','Poloidal ray trajectory comparison')
graph1D_jd(wave_numeric.rays{1}.sx + equil_fit.Rp,wave_numeric.rays{1}.sy + equil_fit.Zp,0,0,'R(m)','Z(m)',['Poloidal Ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);drawnow;hold on
graph1D_jd(wave_analytic.rays{1}.sx(1:10:end) + equil_fit.Rp,wave_analytic.rays{1}.sy(1:10:end) + equil_fit.Zp,0,0,'R(m)','Z(m)',['Poloidal Ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'none','.','b',2);drawnow;hold on
graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)',['Poloidal Ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
axis('equal');
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_poloidal']);
%
figure('Name','Toroidal ray trajectory comparison')
graph1D_jd((wave_numeric.rays{1}.sx + equil_fit.Rp).*cos(wave_numeric.rays{1}.sphi),-(wave_numeric.rays{1}.sx + equil_fit.Rp).*sin(wave_numeric.rays{1}.sphi),0,0,'X(m)','Y(m)',['Toroidal ray trajectory'],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','r',2);hold on
graph1D_jd((wave_analytic.rays{1}.sx(1:30:end) + equil_fit.Rp).*cos(wave_analytic.rays{1}.sphi(1:30:end)),-(wave_analytic.rays{1}.sx(1:30:end) + equil_fit.Rp).*sin(wave_analytic.rays{1}.sphi(1:30:end)),0,0,'X(m)','Y(m)',['Toroidal ray trajectory'],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'none','.','b',2);hold on
graph1D_jd(Xmin_fit,Ymin_fit,0,0,'','','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','b',1);drawnow
graph1D_jd(Xmax_fit,Ymax_fit,0,0,'X(m)','Y(m)','',NaN,[-Rmax,Rmax],[-Rmax,Rmax],'-','none','b',1);hold on
graph1D_jd(Xp_fit,Yp_fit,0,0,'X(m)','Y(m)',['Toroidal ray trajectory'],NaN,[-Rmax,Rmax],[-Rmax,Rmax],'--','none','b',1);hold on
axis('equal');
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_toroidal']);
%
figure('Name','Comparison: Normalized radial position')
graph1D_jd(abs(wave_numeric.rays{1}.sphi/2/pi),wave_numeric.rays{1}.srho,0,0,'abs(\phi)/2\pi','rho',['Normalized radial position'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.srho,0,0,'abs(\phi)/2\pi','rho',['Normalized radial position'],NaN,'','','-','none','b',2);drawnow;hold on
legend('Numeric','Analytic')
figure('Name','Comparison: Normalized poloidal position')
graph1D_jd(abs(wave_numeric.rays{1}.sphi/2/pi),wave_numeric.rays{1}.stheta/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi',['Poloidal angle'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.stheta/2/pi,0,0,'abs(\phi)/2\pi','\theta/2\pi',['Poloidal angle'],NaN,'','','-','none','b',2);drawnow;hold on
legend('Numeric','Analytic')
figure('Name','Comparison: Poloidal mode number')
graph1D_jd(abs(wave_numeric.rays{1}.sphi/2/pi),wave_numeric.rays{1}.spmode,0,0,'abs(\phi)/2\pi','m',['Poloidal mode number'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.spmode,0,0,'abs(\phi)/2\pi','m',['Poloidal mode number'],NaN,'','','-','none','b',2);drawnow;hold on
legend('Numeric','Analytic')
figure('Name','Comparison: Parallel wave refractive index')
graph1D_jd(abs(wave_numeric.rays{1}.sphi/2/pi),wave_numeric.rays{1}.sNpar,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.sNpar,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','','-','none','b',2);drawnow;hold on
legend('Numeric','Analytic')
figure('Name','Comparison: Perpendicular wave refractive index')
graph1D_jd(abs(wave_numeric.rays{1}.sphi/2/pi),wave_numeric.rays{1}.sNperp,0,0,'abs(\phi)/2\pi','N_{perp}',['Perpendicular wave refractive index'],NaN,'','','-','none','r',2);drawnow;hold on
graph1D_jd(abs(wave_analytic.rays{1}.sphi/2/pi),wave_analytic.rays{1}.sNperp,0,0,'abs(\phi)/2\pi','N_{perp}',['Perpendicular wave refractive index'],NaN,'','','-','none','b',2);drawnow;hold on
legend('Numeric','Analytic')