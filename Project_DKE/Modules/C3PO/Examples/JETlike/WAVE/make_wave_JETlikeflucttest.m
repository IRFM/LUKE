% script make_wave_test_RT
%
% Parameters for test mode ray-tracing calculations
% This function has a benchmarking purpose only
%
% by Y. Peysson (DRFC/DSM/CEA) <yves.peysson@cea.fr> and J. Decker (DRFC/DSM/CEA) <joan.decker@cea.fr>
%
close all
%
id_wave = 'JETlikeflucttest';
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
id_fluct = 'ne_Bperp_k_ripple';%For density and magnetic field fluctuation
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
theta0 = pi/12;
phi0 = 3*pi/18/4;%between two toroidal magnetic field coils (phi = 0 corresponds to a coil position)
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
fitparam.equil.method = 'pchip';%nearest,spline,pchip
fitparam.equil.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
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
rayparam.testmode = 1;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 10000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;
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
   fluct = fluctphase_yp(fluct);
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
[xBx] = calcval_yp(equil_fit,theta0,Bx_a0_fit,Bx_an_fit,Bx_bn_fit);
[xBy] = calcval_yp(equil_fit,theta0,By_a0_fit,By_an_fit,By_bn_fit);
[xBPHI] = calcval_yp(equil_fit,theta0,BPHI_a0_fit,BPHI_an_fit,BPHI_bn_fit);
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
% -------------------------------------------------------------------------
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',dkepath);%All cluster parameters and paths
%
% ray-tracing calculations
%
wave_nofluct = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil,equil_fit,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],[],0);clear mex;clear functions
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium with no plasma fluctuations)');
%
if ~isempty(fluct),
    [wave_fluct] = main_C3PO_jd(dkepath,[id_wave,'_fluct'],equil,equil_fit,rayinit,waveparam,[],rayparam,C3POdisplay,C3POparam,[],fluct_fit,0);
else
    wave_fluct = wave_nofluct;
end
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
