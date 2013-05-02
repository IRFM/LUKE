%
% C3PO RAY TRACING DEFAULT PARAMETERS
%
%
% Equilibrium parameters for the ray-tracing
%
fitparam.method = 'pchip';%nearest,spline,pchip
fitparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
fitparam.opt_load = 0;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
fitparam.mode_equil = 1;%Magnetic equilibrium grid type: (1): (psi-theta), (2): (x-y)
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 50000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-3;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 50000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 1;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
rayparam.kextra = 2000;%extra points if QL absorption is delayed
%
% C3PO computing parameters
%
C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2) for the function coll_dke_jd.m (MDC toolbox must be installed for option 1)
C3POparam.clustermode.main_C3PO_jd.scheduler.memory = 500;%required memory (in mb)
%
% C3PO Display parameters
%
C3POdisplay.ray = 0;
C3POdisplay.equilibrium = 0;
C3POdisplay.p_opt = -1;%Printing or saving option of the figures
%
% Wave parameters
%
waveparam.mmode = -1;%cold plasma mode [1] : (-1) m (1) p, p is the slow mode when kperp > 0 (slow/fast LH wave: -1/+1, O/X mode: -1/+1)
waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
%
%Option parameter for FLR effects and cross-comparison between old FP code: 
%	- (0): all FLR effects
%	- (1): small FLR effects and 1/vpar dependence
%	- (2): small FLR effects and no 1/vpar dependence and old grid technique for DQL calculations (Karney, Shoucri) (see rfdiff_dke_jd)
%
waveparam.opt_rf = 1;
%
waveparam.dsmin = 0.01;%minimum size for ray fragments
%
waveparam.nd = 1;%Number of transverse distance positions for beamlets
waveparam.nchi = 1;%Number of angular positions for beamlets
%
waveparam.n_rf_list = 0;
waveparam.ns = 1;%ray smoothing parameter
%
save('C3POPARAM_LH.mat','fitparam','rayparam','C3POparam','C3POdisplay','waveparam');

