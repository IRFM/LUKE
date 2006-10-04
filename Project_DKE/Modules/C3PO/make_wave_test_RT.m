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
id_wave = 'test_RT';
%
id_equil = 'TSvacuum';'JETh77';'ALCATORC';'PLT';'RTtest';'JETh77';'VERSATOR2';'ITERh77';'TScirctest';'COMPASSh77';'TScirc_flatprof_cyl_2';%For plasma equilibrium
path_equil = '';'../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
% -------------------------------------------------------------------------
%
% ray-tracing parameters
%
method = 'spline';%nearest,spline,pchip,cubic
nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
f_rf = 1500;%GHz
%
rho0 = 0.98;
theta0 = 6*pi/2/16;
phi0 = 0;
%
m0 = 0;
Npar0 = 0.9;%initial index of refraction
xmode = 1;%cold plasma mode [nx] : (-1) m (1) p 
%           p is the slow mode when kperp > 0 (ex : LH slow wave)
kmode = 0;% kinetic (1) or cold (0) plasma model
ngridresample = 1001;%Number of grid points for resample the radial profile of magnetic equilibrium parameters
opt_load = 1;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
rayparam.testmode = 0;
rayparam.tensortype = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 100000;
rayparam.dt0 = 1.e-4;
rayparam.drho = 1.e-4;
rayparam.tol = 1e-10;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 10000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
%
% -------------------------------------------------------------------------
%
% Fokker-Planck parameters
%
P0 = 1;%initial power in the ray (W)
dNpar = 0.2;%ray spectral width for Fokker-Planck calculations
%Option parameter for cross-comparison between old FP code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
opt_rf = 2; % [1,1]
%
% -------------------------------------------------------------------------
%
if opt_load*exist(['EQUILV_',equil.id,'.mat']),
   load(['EQUILV_',equil.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is reloaded.']);
else
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
   [equil_fit] = fitequil_yp(equil,nharm,method,ngridresample);%Build vectorized magnetic equilibrium structure
   save(['EQUILV_',equil_fit.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil_fit.id,' is saved.']);
  % testfitequil_yp(equil,equil_fit);
end
%
omega_rf = 2*pi*f_rf*1e9;
%
y0 = init_RT_jd(equil,equil_fit,rho0,theta0,phi0,omega_rf,Npar0,m0,xmode,kmode)';
%
info_dke_yp(2,'Initial conditions calculated');
%
if isreal(y0(4)),
    %
    [tout, yout] = raytracing_yp(rayparam,equil_fit,y0);
    return
    %
    info_dke_yp(2,'Ray trajectories calculated');
    %
    [spsin,stheta,sphi,sR,sZ,sNpar,sNperp,sepol_pmz,sphi_xyz] = raypostprocessing_yp(tout, yout,rayparam,equil_fit,omega_rf);
    %
    info_dke_yp(2,'Ray processing done');
    return
    %
else
   error('kpsin has a non nul imaginary part !');
end
%
% building ray for Fp calculations
%
ns = length(spsin);
%
ray.P0 = P0;% Power launched in the ray (W) [1,1]
%
ray.sR = sR.';% Ray location (major radius) along the propagation [1,ns]
ray.sphi = sphi.';% Ray location (toroidal angle) along the propagation [1,ns]
ray.sZ = sZ.';% Ray location (vertical) along the propagation [1,ns]
%
ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
ray.spsin = spsin.';% Ray location (normalized magnetic flux) along the propagation [1,ns]
ray.stheta = stheta.';% Ray location (poloidal angle) along the propagation [1,ns]
%
ray.skR = [];% Ray wave vector (major radius) along the propagation [1,ns]
ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
ray.skZ = [];% Ray wave vector (vertical) along the propagation [1,ns]
%
ray.sNpar = sNpar.';% Ray parallel wave number [1,ns]
ray.sNperp = sNperp.';% Ray perpendicular wave number [1,ns]
ray.sdNpar = dNpar*ones(1,ns);% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. ->
%       square spectrum (centered on sNpar)
ray.sepol_pmz = sepol_pmz.';% polarization vector [3,ns] complex
ray.sphi_xyz = sphi_xyz.';% normalized power flow [3,ns]
%
wave.omega_rf = omega_rf;
wave.opt_rf = opt_rf;%option for FLR calculations [1,1]
wave.opt_disp = 0+i;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
wave.equil_id = id_equil;
wave.rays{1} = ray;
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);
%
info_dke_yp(2,'Wave parameters saved');
%
%
