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
id_wave = 'ITER_Scen4_19';
p_opt = 2;%Printing or saving option of the figures
filename = id_wave;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LHRF parameters given by Paul Bonoli
%f = 5.0 GHz
%P_lh(ToT) = 30 MW
%S_lh(N//) = S_0 * sin**2(x) / x**2
%x = (2*pi)*(N// - 1.9)/(2.0-1.8) for 1.8 < N// < 2.0
%x = (2*pi)*[N// - (-3.9)]/[-4.0-(-3.8)] for -4.0 < N// < -3.8
%S_0 is chosen so that:
%P_lh (N// > 0) = 26.08 MW
%P_lh (N// < 0) = 3.91 MW
%The LH Grill was modeled with three poloidal launch points distributed vertically at (-0.5, 0, +0.5) m
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Test the launched power spectrum according to Paul
%
nparm = linspace(-7,-1,1000);xm =  (2*pi)*(nparm + 3.9)/(-4.0+3.8);Plhm = 39.2304*sin(xm).^2./xm.^2;
ipeakm = find(Plhm==max(Plhm));
iwm = min(find(Plhm>max(Plhm)/exp(1)));
widthm = abs(nparm(ipeakm) - nparm(iwm));
nparp = linspace(1,5,1000);xp =  (2*pi)*(nparp - 1.9)/(2.0-1.8);Plhp = 262.7073*sin(xp).^2./xp.^2;
ipeakp = find(Plhp==max(Plhp));
iwp = min(find(Plhp>max(Plhp)/exp(1)));
widthp = abs(nparm(ipeakp) - nparm(iwp));
Plhtotm = trapz(nparm,Plhm);
Plhtotp = trapz(nparp,Plhp);
figure('Name','Initial ITER scenario 4 power spectrum')
[ax] = graph1D_jd(nparm,Plhm,0,0,'N_{||}','dP_{LH}/dN_{||} (MW)','Initial ITER scenario 4 power spectrum @ 5.0 GHz',NaN,[-5,5],'','-','none','b',2);hold on
[ax] = graph1D_jd(nparp,Plhp,0,0,'N_{||}','dP_{LH}/dN_{||} (MW)','Initial ITER scenario 4 power spectrum @ 5.0 GHz',NaN,[-5,5],'','-','none','r',2);hold on
legend(['Lobe (-): ',num2str(Plhtotm),' (MW), \DeltaN_{||}: ',num2str(widthm)],['Lobe (+): ',num2str(Plhtotp),' (MW), \DeltaN_{||}: ',num2str(widthp)]);
print_jd(2,['id_wave','_Spectrum']);
%
id_equil = 'ITER_Scen4';%For plasma equilibrium
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
display_ray = 1;
display_equilibrium = 1;

%
% -------------------------------------------------------------------------
%
% Global parameters for the vectorial magnetic equilibrium
%
% Equilibrium parameters for the ray-tracing
method = 'spline';%nearest,spline,pchip,cubic
nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
ngridresample = 1001;%Number of grid points for resample the radial profile of magnetic equilibrium parameters
opt_load = 1;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 30000;
rayparam.dt0 = 1.e-4;
rayparam.drho = 1.e-4;
rayparam.tol = 1e-10;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 100000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
%
% Initial ray conditions
%
rho0 = [0.98,0.98];%Initial radial position at launch
theta0 = [0,0];%Initial poloidal position at launch
phi0 = [0,0];%Initial toroidal position at launch
%
f_rf = [5,5];%RF wave frequency
m0 = [0,0];%Initial poloidal mode number
Npar0 = [1.9,-3.9];%Initial index of refraction
%
xmode = [1,1];%cold plasma mode [nx] : (-1) m (1) p, p is the slow mode when kperp > 0 (ex : LH slow wave)
kmode = [0,0];% kinetic (1) or cold (0) plasma model
%
% -------------------------------------------------------------------------
%
% Fokker-Planck parameters
%
P0 = [Plhtotp,Plhtotm];%initial power in the ray (W)
dNpar = [widthp,widthm];%ray spectral width for Fokker-Planck calculations
%
%Option parameter for cross-comparison between old FP code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
opt_rf = [1,1]; % [1,1]
%
% -------------------------------------------------------------------------
%
%
if opt_load*exist(['EQUILV_',equil.id,'.mat']),
   load(['EQUILV_',equil.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is reloaded.']);
else
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
   [equil_fit] = fitequil_yp(equil,nharm,method,ngridresample);%Build vectorized magnetic equilibrium structure
   save(['EQUILV_',equil_fit.id,'.mat'],'equil_fit');
   info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil_fit.id,' is saved.']);
   if display_equilibrium,testfitequil_yp(equil,equil_fit);end
end
%
for ir = 1:length(f_rf),
   omega_rf = 2*pi*f_rf(ir)*1e9;
%
   y0 = init_RT_jd(equil,equil_fit,rho0(ir),theta0(ir),phi0(ir),omega_rf,Npar0(ir),m0(ir),xmode(ir),kmode(ir))';
%
   info_dke_yp(2,'Initial conditions calculated');
%
   if isreal(y0(4)),
%
       [tout, yout] = raytracing_yp(rayparam,equil_fit,y0);
%
       info_dke_yp(2,['Trajectory of ray #',int2str(ir),' calculated']);
%
       [iabs_out,srho,stheta,sphi,sR,sZ,sNpar,sNperp,sepol_pmz,sphi_xyz] = raypostprocessing_yp(tout,yout,rayparam,equil_fit,omega_rf,display_ray,p_opt,filename);
       iabs = min(length(srho),round(iabs_out*1.1));
%
% building ray for Fp calculations
%
       ray.P0 = P0(ir)*1e6;% Power launched in the ray (W) [1,1]
%
       ray.sR = sR(1:iabs).';% Ray location (major radius) along the propagation [1,ns]
       ray.sphi = sphi(1:iabs).';% Ray location (toroidal angle) along the propagation [1,ns]
       ray.sZ = sZ(1:iabs).';% Ray location (vertical) along the propagation [1,ns]
%
       ray.ss = [];% Ray propagation distance parameter for each ray (put to NaN once the ray is absorbed) [1,ns]
       ray.spsin = [];% Ray location (normalized magnetic flux) along the propagation [1,ns]
       ray.stheta = [];% Ray location (poloidal angle) along the propagation [1,ns]
%
       ray.skR = [];% Ray wave vector (major radius) along the propagation [1,ns]
       ray.sn = [];% Ray wave number (toroidal) along the propagation [1,ns]
       ray.skZ = [];% Ray wave vector (vertical) along the propagation [1,ns]
%
       ray.sNpar = sNpar(1:iabs).';% Ray parallel wave number [1,ns]
       ray.sNperp = sNperp(1:iabs).';% Ray perpendicular wave number [1,ns]
       ray.sdNpar = dNpar(ir)*ones(1,iabs);% Ray spectral width in Npar [1,ns] 
%       if sdNpar is real -> gaussian spectrum, if sdNpar is imag. ->
%       square spectrum (centered on sNpar)
       ray.sepol_pmz = sepol_pmz(1:iabs,:).';% polarization vector [3,ns] complex
       ray.sphi_xyz = sphi_xyz(1:iabs,:).';% normalized power flow [3,ns]
%
       wave.omega_rf = omega_rf;
       wave.opt_rf = opt_rf(ir);%option for FLR calculations [1,1]
       wave.opt_disp = 0+i;  % option for solving the wave equation, which gives (ray.sepol_pmz, ray.sphi, ray.sNperp) 
       wave.equil_id = id_equil;
       wave.rays{ir} = ray;
       clear tout yout
       info_dke_yp(2,['Ray #',int2str(ir),' processed']);
   else
       warning('kpsin has a non nul imaginary part !');        
   end
end
%
save_str = ['WAVE_',id_equil,'_',id_wave,'.mat'];
eval(['save ',save_str,' wave']);
%
info_dke_yp(2,'Wave parameters saved');

