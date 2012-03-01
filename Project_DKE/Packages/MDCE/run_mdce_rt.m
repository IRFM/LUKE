%LUKE - Script for testing the distributed calculations within MatLab with call to MEX-files (using the distributed MatLab toolbox)
%
%Script for testing the distributed calculations within MatLab with call to MEX-files (using the distributed MatLab toolbox)
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
clear all
close all
%
dkepath = load_structures_yp('dkepath','','');
%
display.display_mode = 0;%no display
%
schedulertype = 'local';%'pbspro';%'' or 'local','xgrid',...
%
MDCE = 1;%Set to 1 if matlab MDCE is tested
LUKEDC = 0;%Set to 1 if batch DCLUKE is tested
PARLOOP = 1;%Set to 1 if parfor is tested
%
Nmax = Inf;%number of parallel jobs
N = 12;%number of iterations
%
time_seq = NaN*ones(1,N);test_seq = ones(1,N);
time_par = NaN*ones(1,N);test_par = NaN*ones(1,N);
time_mdce = NaN*ones(1,N);test_mdce = NaN*ones(1,N);
time_ldce = NaN*ones(1,N);test_ldce = NaN*ones(1,N);
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
waveparam.kmode = 0;%(0:cold,1:warm,2:hot;3:weak relativistic,4:full relativistic)
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
rayparam.tfinal = 2000;
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
C3POparam.clustermode.main_C3PO_jd.scheduler.enforce = 0;
C3POparam.clustermode.main_C3PO_jd.scheduler.display = 1;
%
% Loop for testing performances of the cluster
%
for n=1:N,
    %
    C3POparam.clustermode.main_C3PO_jd.scheduler.clustersize = min(n,Nmax);
    %
    for j = 1:n,
		rayinit.yNpar0 = Npar0 + 0.01*(1:n)/n;%Initial index of refraction
		%
		rayinit.yrho0 = repmat(rho0,1,n);%Initial radial position at launch
		rayinit.ytheta0 = repmat(theta0,1,n);%Initial poloidal position at launch
		rayinit.yphi0 = repmat(phi0,1,n);%Initial toroidal position at launch
		rayinit.ym0 = repmat(m0,1,n);%Initial poloidal mode number
		rayinit.yn0 = repmat(n0,1,n);%Initial toroidal mode number
		rayinit.ydNpar0 = repmat(dNpar0,1,n);%initial Ray spectral width
		rayinit.yP0_2piRp = repmat(P0_2piRp,1,n);%Lineic initial power density initial power in the ray (W/m)
	end
    %
    % Sequential job (for loop)
    % 
    C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 0;
    %
    tic;wave_seq = main_C3PO_jd(dkepath,'test',equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[]);clear mex;clear functions;time_seq(n) = toc;
    %
    figure('Name',['Sequential calculations (for loop) for n = ',int2str(n)]),
    graph1D_jd(wave_seq.rays{1}.ss,wave_seq.rays{1}.srho,0,0,'s','\rho',['Sequential computing (for loop) - ',int2str(n),' cycles, dt = ',num2str(time_seq(n)),' (s)'],'',[0,max(wave_seq.rays{1}.ss)],NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
    for j = 2:n,
        graph1D_jd(wave_seq.rays{j}.ss,wave_seq.rays{j}.srho,0,0,'','','',NaN,[0,max(wave_seq.rays{1}.ss)],NaN,'-','none','r',2,20);
    end   
    %
    disp(['   --> time for n = ',int2str(n),' serial (for loop) calculations on (',int2str(1),' proc.) : ',num2str(time_seq(n)),' s'])
    disp('-------------------------------------------------------------------------')
    %
    % Matlab Distributed Computing Environment (MDCE)
    %
    if MDCE == 1,
        %
        C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 1;
        %
        tic;wave_mdce = main_C3PO_jd(dkepath,'test',equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[]);clear mex;clear functions;time_mdce(n) = toc;
        test_mdce(n) = comp_struct_jd(wave_seq.rays,wave_mdce.rays,0);
        %
        figure('Name',['MDCE calculations for n = ',int2str(n)]),
        graph1D_jd(wave_mdce.rays{1}.ss,wave_mdce.rays{1}.srho,0,0,'s','\rho',['MDCE computing - ',int2str(n),' cycles, dt = ',num2str(time_mdce(n)),' (s)'],'',[0,max(wave_mdce.rays{1}.ss)],NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
        for j = 2:n,
            graph1D_jd(wave_mdce.rays{j}.ss,wave_mdce.rays{j}.srho,0,0,'','','',NaN,[0,max(wave_mdce.rays{1}.ss)],NaN,'-','none','r',2,20);
        end   
        %
        disp(['   --> time for n = ',int2str(n),' MDCE calculations on (',int2str(n),' proc.) : ',num2str(time_mdce(n)),' s'])
        if test_mdce(n) == 1,
            disp('   --> sequential and MDCE calculations give same outputs');
        else
            disp('   --> WARNING: sequential and MDCE calculations give different outputs');
        end
        disp('-------------------------------------------------------------------------')
    end
    %
    % LUKE Distributed Computing Environment (LDCE)
    %
    if LUKEDC == 1,%All matlab may be used with this technique based on an external batch-queuing
        %
        C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 2;
        %
        tic;wave_ldce = main_C3PO_jd(dkepath,'test',equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[]);clear mex;clear functions;time_ldce(n) = toc;
        test_ldce(n) = comp_struct_jd(wave_seq.rays,wave_ldce.rays,0);
        %
        figure('Name',['LDCE calculations for n = ',int2str(n)]),
        graph1D_jd(wave_ldce.rays{1}.ss,wave_ldce.rays{1}.srho,0,0,'s','\rho',['LDCE computing - ',int2str(n),' cycles, dt = ',num2str(time_ldce(n)),' (s)'],'',[0,max(wave_ldce.rays{1}.ss)],NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
        for j = 2:n,
            graph1D_jd(wave_ldce.rays{j}.ss,wave_ldce.rays{j}.srho,0,0,'','','',NaN,[0,max(wave_ldce.rays{1}.ss)],NaN,'-','none','r',2,20);
        end   
        %
        disp(['   --> time for n = ',int2str(n),' LDCE calculations on (',int2str(n),' proc.) : ',num2str(time_ldce(n)),' s'])
        if test_ldce(n) == 1,
            disp('   --> sequential and LDCE calculations give same outputs');
        else
            disp('   --> WARNING: sequential and LDCE calculations give different outputs');
        end
        disp('-------------------------------------------------------------------------')
    end
    %
    % Parallel job (parfor loop)
    %
    if PARLOOP == 1,
        %
        C3POparam.clustermode.main_C3PO_jd.scheduler.mode = 3;
        %
        tic;wave_par = main_C3PO_jd(dkepath,'test',equil,equil_fit,rayinit,waveparam,fitparam,rayparam,C3POdisplay,C3POparam,[]);clear mex;clear functions;time_par(n) = toc;
        matlabpool close force
        test_par(n) = comp_struct_jd(wave_seq.rays,wave_par.rays,0);
        %
        figure('Name',['Parallel calculations (parfor loop) for n = ',int2str(n)]),
        graph1D_jd(wave_par.rays{1}.ss,wave_par.rays{1}.srho,0,0,'s','\rho',['Parallel computing (parfor loop) - ',int2str(n),' cycles, dt = ',num2str(time_par(n)),' (s)'],'',[0,max(wave_par.rays{1}.ss)],NaN,'-','none','r',2,20,gca,0.9,0.7,0.7);
        for j = 2:n,
            graph1D_jd(wave_par.rays{j}.ss,wave_par.rays{j}.srho,0,0,'','','',NaN,[0,max(wave_par.rays{1}.ss)],NaN,'-','none','r',2,20);
        end   
        %    
        disp(['   --> time for n = ',int2str(n),' parallel (parfor loop) calculations on (',int2str(n),' proc.) : ',num2str(time_par(n)),' s'])
        if test_par(n) == 1,
            disp('   --> sequential and parallel (parfor loop) calculations give same outputs');
        else
            disp('   --> WARNING: sequential and parallel (parfor loop) calculations give different outputs');
        end
        disp('-------------------------------------------------------------------------')
    end
end
%
mask_par = find(test_par);
mask_mdce = find(test_mdce);
mask_ldce = find(test_ldce);
%
figure('Name','Distributed computing'),
%
leg = {};
%
if PARLOOP == 1,
    leg = [leg,'Parallel'];
    graph1D_jd(mask_par,time_par(mask_par),0,0,'','','',NaN,[0,N+1],NaN,'none','x','r',2,20,gca);
end
%
if MDCE == 1,
    leg = [leg;'MDCE'];
    graph1D_jd(mask_mdce,time_mdce(mask_mdce),0,0,'','','',NaN,[0,N],NaN,'none','s','g',2,20,gca);
end
%
if LUKEDC == 1,
    leg = [leg;'LDCE'];
    graph1D_jd(mask_ldce,time_ldce(mask_ldce),0,0,'','','',NaN,[0,N],NaN,'none','d','g',2,20,gca);
end
%
leg = ['Serial'];
graph1D_jd(1:N,time_seq,0,0,'N processors','time (s)','',leg,[0,N+1],NaN,'none','o','b',2,20,gca,0.9,0.7,0.7);
%
