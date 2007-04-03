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
id_wave = 'JETliketest';% scenario identification (see paper Plasma Phys. Control. Fusion 41 (1999) 1231 - J.A. Heikkinen et al.)
%
p_opt = 2;%Printing or saving option of the figures
filename = id_wave;
%
id_equil = 'JETliketest';%For plasma equilibrium
mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
path_equil = '../EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
display_ray = 1;
display_equilibrium = 0;
%
% -------------------------------------------------------------------------
%
% ray-tracing parameters
%
method = 'spline';%nearest,spline,pchip,cubic
nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
f_rf = 3.7;%GHz
%
rho0 = 0.968;
theta0 = 0.0;
phi0 = 0;
%
m0 = 0;
Nphi0 = -2.0;%initial index of refraction
mmode = -1;%cold plasma mode [nx] : (1) m (-1) p 
%           p is the slow mode when kperp > 0 (ex : LH slow wave)
kmode = 0;% kinetic (1) or cold (0) plasma model
ngridresample = 1001;%Number of grid points for resample the radial profile of magnetic equilibrium parameters
opt_load = 1;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
rayparam.testmode = 0;
rayparam.tensortype = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 10000;
rayparam.dt0 = 1.e-4;
rayparam.drho = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;
rayparam.ncyclharm = 0;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 0;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
%
% -------------------------------------------------------------------------
%
% Fokker-Planck parameters
%
P0 = 1;%initial power in the ray (MW)
dNpar = 0.2;%ray spectral width for Fokker-Planck calculations
%Option parameter for cross-comparison between old FP code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
opt_rf = 1; % [1,1]
%
% -------------------------------------------------------------------------
%
%
if opt_load*exist(['EQUILV_',equil.id,'.mat']),
   load(['EQUILV_',equil.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is reloaded.']);
else
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
   [equil_fit] = fitequil_yp(equil,mode_equil,method,ngridresample,nharm);%Build vectorized magnetic equilibrium structure
   save(['EQUILV_',equil_fit.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil_fit.id,' is saved.']);
   if display_equilibrium,testfitequil_yp(equil,equil_fit);end
end
%
omega_rf = 2*pi*f_rf*1e9;
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
    [xBx,dummy,dummy,dummy,dummy] = calcval_yp(equil_fit,Bx_a0_fit,Bx_an_fit,Bx_bn_fit,[],[],[],theta0);
    [xBy,dummy,dummy,dummy,dummy] = calcval_yp(equil_fit,By_a0_fit,By_an_fit,By_bn_fit,[],[],[],theta0);
    [xBPHI,dummy,dummy,dummy,dummy] = calcval_yp(equil_fit,BPHI_a0_fit,BPHI_an_fit,BPHI_bn_fit,[],[],[],theta0);
    %
    xBp = sqrt(xBx.^2 + xBy.^2); 
    xBt = xBPHI; 
    xB = sqrt(xBt.^2 + xBp.^2);
    xBphin = xBt./xB;
%
Npar0 = Nphi0.*xBphin;
%
y0 = init_RT_jd(equil,equil_fit,rho0,theta0,phi0,omega_rf,Npar0,m0,mmode,kmode)';
%
info_dke_yp(2,'Initial conditions calculated');
%
if isreal(y0(4)),
    %
    [tout0, yout0] = raytracing_yp(rayparam,equil_fit,y0);
    %
    info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium)');
    %
    filename = [id_wave,'_numeric'];
    [iabs_out0,srho0,stheta0,sphi0,sR0,sZ0,sNpar0,sNperp0,sepol_pmz0,sphi_xyz0] = raypostprocessing_yp(tout0,yout0,rayparam,equil_fit,omega_rf,display_ray,p_opt,filename,' (numeric)');
    %
    [tout1, yout1] = raytracing_yp(rayparam,equil_fit,y0,2);
    %
    filename = [id_wave,'_analytic'];
    info_dke_yp(2,'Ray trajectories calculated (analytic magnetic equilibrium)');
    %
    [iabs_out1,srho1,stheta1,sphi1,sR1,sZ1,sNpar1,sNperp1,sepol_pmz1,sphi_xyz1] = raypostprocessing_yp(tout1,yout1,rayparam,equil_fit,omega_rf,display_ray,p_opt,filename,' (Analytic)');
    info_dke_yp(2,'Ray processing done');
    %
else
   error('kpsin has a non nul imaginary part !');
end
%
save_str = ['RAY_RESULTS_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str]);
%
info_dke_yp(2,'Wave parameters saved');
%
