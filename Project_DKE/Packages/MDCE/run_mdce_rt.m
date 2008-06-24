%LUKE - Script for testing the distributed calculations within MatLab with call to MEX-files (using the distributed MatLab toolbox)
%
%Script for testing the distributed calculations within MatLab with call to MEX-files (using the distributed MatLab toolbox)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
dkepath = path_LUKE_LOCAL;
%
display.display_mode = 0;%no display
%
ver = version;
ver = str2num(ver(1:3));
%
N = 10;%number of jobs
nprocmax1 = 1;%maximum number of processors involved
nprocmax4 = 4;%maximum number of processors involved
nprocmax8 = 8;%maximum number of processors involved
%
time_seq = NaN*ones(1,N);flag_seq = NaN*ones(1,N);
%
time_mdce1 = NaN*ones(1,N);
time_mdce4 = NaN*ones(1,N);
time_mdce8 = NaN*ones(1,N);
%
time_ldce = NaN*ones(1,N);
%
flag_mode1 = 0;
flag_mode2 = 0;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initial ray conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
load('EQUIL_JETliketest.mat')
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
% C3PO computing parameters
%
C3POparam.clustermode.multithreading = 'automatic';%Intrinsic distributed computing with multicore machines (MatLab > R2007a). Can be set to 'automatic', or enforced to any value from 1 to more threads. WARNING: if the number of threads is larger than the number of cores, performances may be reduced.
C3POparam.clustermode.main_C3PO_jd.mode = 0;%MatLab distributed computing environment disabled (0), enabled with the dedicated toolbox (1), enabled with a private method (2)for the function main_C3PO_jd.m (MDC toolbox must be installed for option 1)
C3POparam.clustermode.main_C3PO_jd.timeout = 300;%MatLab distributed computing environment time out (s). after time out is reached, calculations are performed in a sequential mode on a single processor
C3POparam.clustermode.main_C3PO_jd.size = 1;%MatLab distributed computing environment cluster size. Can be Inf is all the processors of the cluster are free for distributed calculations
%
% Display parameters
%
C3POdisplay.ray = 0;
C3POdisplay.equilibrium = 0;
C3POdisplay.p_opt = 0;%Printing or saving option of the figures
C3POdisplay.mdce = 0;%for distributed computing
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
fitparam.method = 'pchip';%nearest,spline,pchip,cubic
fitparam.nharm = 32;%Number of harmonics in the magnetic equilibrium interpolation (less than ntheta_equil/2)
fitparam.ngridresample = 1001;%Number of grid points for resampling the radial profile of magnetic equilibrium parameters
fitparam.opt_load = 1;%Reload existing vectorial magnetic equilibrium (1) or overwrite it (0).
%
% Global parameters for the ray-tracing
%
rayparam.testmode = 0;
rayparam.tensortype = waveparam.kmode;%(0:cold,1:warm,2:hot;3:weak realtivistic,4:full relativistic)
rayparam.t0 = 0;
rayparam.tfinal = 10000;
rayparam.dt0 = 1.e-4;
rayparam.dS = 1.e-4;
rayparam.tol = 1e-12;%when tolerance is increased (less accurate calculation of D=0), tfinal must be increased accordingly
rayparam.kmax = 60000;
rayparam.ncyclharm = 3;%number of cyclotron harmonics (just for hot and relativistic dielectric tensors)
rayparam.reflection = 0;%1:Enforce wave reflection at plasma boundary, 0: the code calculates itself if the ray must leave of not the plasma
rayparam.rel_opt = 1;%option for (1) relativistic or (0) non-relativistic calculations
rayparam.nperp = 1000;%number of points in pperp integration for damping calculations
rayparam.pperpmax = 10;%maximum value of pperp in damping calculations
rayparam.tau_lim = 20;%value of optical depth beyond which the wave is considered absorbed
%
% -------------------------------------------------------------------------
%
% Load structures
%
[dkepath] = load_structures_yp('dkepath','','');
%
% =========================================================================
%
% C3P0 ray tracing
%
[equil_fit] = fitequil_yp(equil,fitparam.mode_equil,fitparam.method,fitparam.ngridresample,fitparam.nharm);%Build vectorized magnetic equilibrium structure
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
%
% Loop for performances of the cluster
%
for n=1:N,
    %
    disp(['- n = ',num2str(n),' calculations'])
    %
    % Sequential job case
    %
    for j = 1:n,
    	rayinit.yrho0 = repmat(rho0,1,n);%Initial radial position at launch
		rayinit.ytheta0 = repmat(theta0,1,n);%Initial poloidal position at launch
		rayinit.yphi0 = repmat(phi0,1,n);%Initial toroidal position at launch
		rayinit.ym0 = repmat(m0,1,n);%Initial poloidal mode number
		rayinit.yn0 = repmat(n0,1,n);%Initial toroidal mode number
		rayinit.yNpar0 = repmat(Npar0,1,n);%Initial index of refraction
		rayinit.ydNpar0 = repmat(dNpar0,1,n);%initial Ray spectral width
		rayinit.yP0_2piRp = repmat(P0_2piRp,1,n);%Lineic initial power density initial power in the ray (W/m)
	end
    %
	C3POparam.clustermode.main_C3PO_jd.mode = 0;
	C3POparam.clustermode.main_C3PO_jd.size = nprocmax1;
    tic;wave = main_C3PO_jd('test',equil,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,'',0);clear mex;clear functions;;time_seq(n) = toc;
    %
    disp(['   --> time for consecutive calculations (1 proc.) : ',num2str(time_seq(n)),' s'])
    disp('-------------------------------------------------------------------------')
    %
    % Distributed job case (1 processor)
    %
	C3POparam.clustermode.main_C3PO_jd.mode = 1;
	C3POparam.clustermode.main_C3PO_jd.size = nprocmax1;
    if ver >= 7.4 & C3POparam.clustermode.main_C3PO_jd.mode == 1,%(MDCE only with 1 processor called)
    	tic;wave = main_C3PO_jd('test',equil,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,'',0);clear mex;clear functions;time_mdce1(n) = toc;
		flag_mode1 = 1;
    end
    %
    C3POparam.clustermode.main_C3PO_jd.mode = 2;
    %C3POparam.clustermode.main_C3PO_jd.size = 3;
	C3POparam.clustermode.main_C3PO_jd.size = n;
    if ver < 7.4 & C3POparam.clustermode.main_C3PO_jd.mode == 2,
    	tic;wave = main_C3PO_jd('test',equil,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,'',0);clear mex;clear functions;;time_ldce(n) = toc;
        flag_mode2 = 1;
    end
    %
    if ver >= 7.4 & C3POparam.clustermode.main_C3PO_jd.mode == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (1 processor) : ',num2str(time_mdce1(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
    %
    if C3POparam.clustermode.main_C3PO_jd.mode == 2,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the LUKE distributed computing toolbox using ',num2str(n),' jobs in batch queueing mode: ',num2str(time_ldce(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
    %
    % Distributed job case (MDCE only with 4 processors called)
    %
	C3POparam.clustermode.main_C3PO_jd.mode = 1;
	C3POparam.clustermode.main_C3PO_jd.size = nprocmax4;
    if ver >= 7.4 & C3POparam.clustermode.main_C3PO_jd.mode == 1,
    	tic;wave = main_C3PO_jd('test',equil,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,'',0);clear mex;clear functions;;time_mdce4(n) = toc;
    end
    %
    if ver >= 7.4 & C3POparam.clustermode.main_C3PO_jd.mode == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (4 processors) : ',num2str(time_mdce4(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
    %
    % Distributed job case (MDCE only with 8 processors called)
    %
	C3POparam.clustermode.main_C3PO_jd.mode = 1;
	C3POparam.clustermode.main_C3PO_jd.size = nprocmax8;
    if ver >= 7.4 & C3POparam.clustermode.main_C3PO_jd.mode == 1,
        tic;wave = main_C3PO_jd('test',equil,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,'',0);clear mex;clear functions;;time_mdce8(n) = toc;
    end
    %
    if ver >= 7.4 & C3POparam.clustermode.main_C3PO_jd.mode == 1,
        disp(['- n = ',num2str(n),' distributed calculations'])
        disp(['--> time for distributed calculation with the MatLab distributed computing toolbox (8 processors) : ',num2str(time_mdce8(n)),' s'])
        disp('-------------------------------------------------------------------------')
    end
end
%
leg = ['Single                                        '];
graph1D_jd(1:N,time_seq,0,0,'','','',leg,[0,N+1],NaN,'none','o','b',2,20,gca,0.9,0.7,0.7);
%
if flag_mode1,
	leg = [leg;'Distributed, MatLab toolbox (1 proc.)         '];
	graph1D_jd(1:N,time_mdce1',0,0,'N','time (s)','',leg,[0,N],NaN,'none','s','g',2,20,gca,0.9,0.7,0.7);
	%
	leg = [leg;'Distributed, MatLab toolbox (4 proc.)         '];
	graph1D_jd(1:N,time_mdce4',0,0,'N','time (s)','',leg,[0,N],NaN,'none','+','g',2,20,gca,0.9,0.7,0.7);
	%
	leg = [leg;'Distributed, MatLab toolbox (8 proc.)         '];
	graph1D_jd(1:N,time_mdce8',0,0,'N','time (s)','',leg,[0,N],NaN,'none','x','g',2,20,gca,0.9,0.7,0.7);
end
%
if flag_mode2,
	leg = [leg;'Distributed, LUKE toolbox                     '];
	graph1D_jd(1:N,time_ldce',0,0,'N','time (s)','',leg,[0,N],NaN,'none','d','g',2,20,gca,0.9,0.7,0.7);	
end
%
leg = [leg;'Time out level                                '];
graph1D_jd(0:N,C3POparam.clustermode.main_C3PO_jd.timeout*ones(N+1,1),0,0,'N','time (s)','',leg,[0,N],NaN,'--','none','r',2,20,gca,0.9,0.7,0.7);
%
if flag_mode1 & flag_mode2,
	print_jd(2,'fig_rt_mcde_lcde','.');
elseif ~flag_mode1 & flag_mode2,
	print_jd(2,'fig_rt_lcde','.');
elseif flag_mode1 & ~flag_mode2,
	print_jd(2,'fig_rt_mcde','.');
elseif ~flag_mode1 & ~flag_mode2,
	print_jd(2,'fig_rt_seq','.');
end
