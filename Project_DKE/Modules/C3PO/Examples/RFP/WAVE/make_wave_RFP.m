% script make_wave_MST_400ka
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
% Path parameters
%
id_dkepath = '';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%
id_wave = 'RFP_LH';
%
% Equilibrium parameters
%
id_equil = 'RFP';%For plasma equilibrium
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
% initial ray conditions
%
ids_rayinit = {'LH'};
paths_rayinit = {''};
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
waveparam.opt_rf = 1;
%
waveparam.dsmin = Inf;%minimum size for ray fragments
waveparam.cut_fac = Inf;% the ray is cut when P/P_in = exp(-10*cut_fac). Use Inf if the whole ray is to be kept
%
n_rf_list = 0;
%
% -------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium
%
% Equilibrium parameters for the ray-tracing
%
fitparam.equil.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.equil.method = 'pchip';%nearest,spline,pchip,cubic
fitparam.equil.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.equil.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 1000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 10000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = Inf;%value of optical depth beyond which the wave is considered absorbed (usually 20. Otherwise Inf)
rayparam.kextra = 1000;%number of calculations performed beyond the full linear absorption (for quasilinear calculations which may require more points)%
% -------------------------------------------------------------------------
%
% Load structures
%
[dkepath,equil,rayinits] = load_structures_yp('dkepath',id_dkepath,path_dkepath,'equil',id_equil,path_equil,'rayinits',ids_rayinit,paths_rayinit);
%
% Vectorial description of the magnetic equilibrium
%
equil_fit = fitequil_yp(equil,fitparam.equil.mode_equil,fitparam.equil.method,fitparam.equil.ngridresample,fitparam.equil.nharm);%Build vectorized magnetic equilibrium structure
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
if C3POdisplay.equilibrium,testfitequil_yp(equil,equil_fit);end
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',0,dkepath);%All cluster parameters and paths
%
% C3P0 ray tracing
%
tstart = tic;
wave = main_C3PO_jd(dkepath,id_wave,equil_fit,rayinits{1},waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],0);
telapsed_ray = toc(tstart);
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);
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
figure('Name','Poloidal ray trajectory comparison')
graph1D_jd(wave.rays{1}.sx + equil_fit.Rp,wave.rays{1}.sy + equil_fit.Zp,0,0,'R(m)','Z(m)',['Poloidal ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','r',2);drawnow;hold on
graph1D_jd(R_fit,Z_fit,0,0,'','','',NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);drawnow
graph1D_jd(R_fit',Z_fit',0,0,'R(m)','Z(m)',['Poloidal Ray trajectory'],NaN,[Rmin,Rmax],[Zmin,Zmax],'-','none','b',1);hold on
axis('equal');
print_jd(C3POdisplay.p_opt,[id_wave,'_poloidal_trajectory']);
%
figure('Name','Normalized radial position comparison')
graph1D_jd(abs(wave.rays{1}.sphi/2/pi),wave.rays{1}.srho,0,0,'abs(\phi)/2\pi','\rho',['Normalized radial position'],NaN,'','','-','none','r',2);drawnow;hold on
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_rho']);
%
figure('Name','Parallel wave refractive index comparison')
graph1D_jd(abs(wave.rays{1}.sphi/2/pi),wave.rays{1}.sNpar,0,0,'abs(\phi)/2\pi','N_{||}',['Parallel wave refractive index'],NaN,'','','-','none','r',2);drawnow;hold on
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_Npar']);
%
figure('Name','Dispersion relation comparison')
graph1D_jd(abs(wave.rays{1}.sphi/2/pi),wave.rays{1}.sD,0,1,'abs(\phi)/2\pi','det(D)',['Dispersion relation'],NaN,'','','-','none','r',2);drawnow;hold on
print_jd(C3POdisplay.p_opt,[id_wave,'_comparison_Disp']);
%
disp(['Elapsed time (s):',num2str(telapsed_ray),' for ray calculations (PCHIP interp. technique)']);
%
