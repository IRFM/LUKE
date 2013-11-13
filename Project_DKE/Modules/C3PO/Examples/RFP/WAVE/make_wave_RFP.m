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
flag_analytic = 6;
p_opt = -1;
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
C3POdisplay_numeric.ray = 1;
C3POdisplay_numeric.equilibrium = 0;
C3POdisplay_numeric.p_opt = 2;%Printing or saving option of the figures
%
C3POdisplay_analytic.ray = 0;
C3POdisplay_analytic.equilibrium = 0;
C3POdisplay_analytic.p_opt = 2;%Printing or saving option of the figures
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
fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
fitparam.method = 'pchip';%nearest,spline,pchip
fitparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
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
equil_fit = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
info_dke_yp(2,['Vectorial form of the magnetic equilibrium ',equil.id,' is calculated.']);
if C3POdisplay_numeric.equilibrium,testfitequil_yp(equil,equil_fit);end
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd = clustermode_luke(0,'',dkepath);%All cluster parameters and paths
%
% C3P0 ray tracing
%
wave_numeric = main_C3PO_jd(dkepath,[id_wave,'_numeric'],equil,'',rayinits{1},waveparam,fitparam,rayparam,C3POdisplay_numeric,C3POparam,[],[],0);
%
info_dke_yp(2,'Ray trajectories calculated (interpolated magnetic equilibrium)');
%
rayparam.tfinal = 600;
wave_analytic = main_C3PO_jd(dkepath,[id_wave,'_analytic'],equil,'',rayinits{1},waveparam,fitparam,rayparam,C3POdisplay_analytic,C3POparam,[],[],flag_analytic);
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
opt.p_opt = C3POdisplay_numeric.p_opt;
opt.ntheta_fit = 65;
opt.nrho_fit = 15;
opt.propvar = 1;   
%
graph_comp_RT_jd(rays,legs,'',filename,opt)
%
% diary some results for CVS validation
%
diaryname = ['res_',id_wave,'.log'];
[LUKEversion,matver] = LUKEversion_jd;
%
if exist(diaryname,'file'),
    delete(diaryname)
end
%
diary(diaryname)
%
disp(['Simulation id: ',id_wave]);
disp(['Simulation date: ',timeid_jd(timeid_jd(clock))]);
disp(['User id: ',userid_jd]);
disp(['LUKE Version: ',LUKEversion]);
disp(['MATLAB Version: ',matver]);
disp(['MACHINE: ',dkepath.hostname]);
%
disp(['----------------------'])
%
for iray = 1:10,
    disp(['Npar(numeric) = ',num2str(wave_numeric.rays{1}.sNpar(iray),'%17.15f'),' - Npar(analytic) = ',num2str(wave_analytic.rays{1}.sNpar(iray),'%17.15f')])
end
disp(['----------------------'])
%
diary off
