%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
%
opt_proc = 1;%test of numerical performances with number of processors at fixed Dpsipsi = 10 m2/s.
nproc_max = 10;%max number of processors
%
mdceparam.type = 'local';%'' or 'local', 'pbspro', 'xgrid' or otherwise
mdceparam.mode = 2;%distributed computing environment state: (0) disabled, (1) enabled with the dedicated Matlab toolbox which must be installed, (2) enabled with a private method (LDCE), (3) parfor parallel computing [1,1]
mdceparam.enforce = 1;%enforce sequential run if distributed computing failed
mdceparam.memory = 7500;%memory allocated to batch runs, in MB
%
p_opt = 2;
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_transp_bounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0:0.025:0.65,0.7:0.1:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'JETh77';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = 'magneticturbulence';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
wavestruct.omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit opt_lh > 0
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
wavestruct.opt_lh = 2; % [1,1]
%
% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
wavestruct.norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
%
wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
wavestruct.yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
wavestruct.yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
wavestruct.yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
wavestruct.ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
wavestruct.yD0_in_c_lh = [2];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
wavestruct.yD0_in_lh_prof = [1];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
wavestruct.ypeak_lh = [0.4];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
wavestruct.ywidth_lh = [0.1];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
wavestruct.ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.tn = [50000,100000];% 2 time steps to tn=100000 best for asymptotic solution
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
%betath = 0.001;
%
%[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
%equil.pTe = betath^2*mc2*ones(size(equil.pTe));
%equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
% Dpsipsi scan (0 -> 100 m2/s)
%
Dr0_list = [0,0.001,0.01,0.1,0.3,1,3,10,30,100];
Dr0_mask = [1,4,6,8];
iDr0_save = 8;
%
nDr0 = length(Dr0_list);
nr = length(rho_S) - 1;
%
mdceparam.clustersize = nDr0;
dkecluster = clustermode_luke(mdceparam,'',dkepath);
%
[flag,cZcurr,cZP0,cdke_out,cequilDKE,cmksa] = mdce_run(@loop_rundke,...
    {'',Dr0_list,iDr0_save,id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple},...
    1,1:nDr0,dkecluster);
%
j = NaN(nr,nDr0);
P = NaN(nr,nDr0);
tCPU_Dr0 = NaN(1,nDr0);
Itot = NaN(1,nDr0);
Ptot_2piRp = NaN(1,nDr0);
%
for iDr0 = 1:nDr0,
    %
    if cdke_out{iDr0}.residu_f{end}(end) <= dkeparam.prec0_f,
        j(:,iDr0) = cZcurr{iDr0}.x_0;
        %
        P(:,iDr0) = cZP0{iDr0}.x_rf_fsav;
        %
        tCPU_Dr0(iDr0) = cdke_out{iDr0}.time_out;
        %
        Itot(iDr0) = sum(cZcurr{iDr0}.x_0.*cequilDKE{iDr0}.xdA_dke*cmksa{iDr0}.j_ref);
        Ptot_2piRp(iDr0) = sum(cZP0{iDr0}.x_rf_fsav.'.*cequilDKE{iDr0}.xdV_2piRp_dke*cmksa{iDr0}.P_ref);
    end
    %
end
%
eta = j./P;
Eta = cequilDKE{1}.xne(1)*Itot./Ptot_2piRp/(2*pi)/1e19;
%
% N processors scan for Dpsipsi = 10 m2/s (1-> nproc_max)
%
if opt_proc > 0,
    %
    transpfaste.Dr0 = 10;
    %    
    nproc_list = [1:nproc_max];
    %
    for inproc = 1:length(nproc_list),
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        %
        tCPU_nproc(inproc) = dke_out.time_out;
        %
    end
end
%
%************************************************************************************************************************************
%
for iDr0 = 1:length(Dr0_mask),
    leg{iDr0} = ['D_{\psi\psi} = ',num2str(Dr0_list(Dr0_mask(iDr0))),' m^{2}/s'];
end
%
figure(1),clf
%
xlim = [0,1];
ylim = [0,0.0015];
xlab = 'r/a_p';
ylab = 'j';
tit = '';
siz = 20+14i;
%
%for iDr0 = 1:length(Dr0_list) - 1, 
%    graph1D_jd(cequilDKE{1}.xrho,j(:,iDr0),i,0,0,'','','',NaN,xlim,ylim,'-','none',NaN,2,20,gca);
%end
graph1D_jd(cequilDKE{1}.xrho,j(:,Dr0_mask),0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',NaN,2,siz,gca,0.9,0.7,0.7);
%graph1D_jd(cquilDKE{1}.xrho,besselj(0,2.4*equilDKE.xrho)*j(1,Dr0_mask(end)),0,0,'','','',NaN,xlim,ylim,'--','none','k',2,20);
%
set(gca,'ytick',[0:1/3:1]*ylim(2))
set(gca,'xtick',[0:0.2:1]*xlim(2))
%
figure(2),clf
%
xlim = [0.01,100];
ylim = [0,200];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'CPU time (s)';
%
graph1D_jd(Dr0_list(2:end),tCPU_Dr0(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(3),clf
%
ylim = [0,0.06];
ylab = 'I (MA)';
%
graph1D_jd(Dr0_list(2:end),-Itot(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.25:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(4),clf
%
ylim = [0,0.004];
ylab = 'P/(2\piR_p) (MW/m)';
%
graph1D_jd(Dr0_list(2:end),Ptot_2piRp(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.25:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(5),clf
%
ylim = [0,6];
ylab = 'n_{19}IR_p/P';
%
graph1D_jd(Dr0_list(2:end),-Eta(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.25:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(p_opt,'fig_JET_transp_nobounce_j','./figures',1)
print_jd(p_opt,'fig_JET_transp_nobounce_cpu','./figures',2)
print_jd(p_opt,'fig_JET_transp_nobounce_I','./figures',3)
print_jd(p_opt,'fig_JET_transp_nobounce_P','./figures',4)
print_jd(p_opt,'fig_JET_transp_nobounce_Eta','./figures',5)
%
if opt_proc > 0, 
    %
    figure(6),clf
    %
    xlim = [0,length(nproc_list)+1];
    ylim = [0,round(max(tCPU_nproc)*2)];
    xlab = 'Number of processors';
    ylab = 'CPU time (s)';
    tit = 'D_{\psi\psi} = 10 (m^{2}/s)';
    %
    graph1D_jd(nproc_list,tCPU_nproc,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
    %
    print_jd(p_opt,'fig_transp_nobounce_cpu_proc','./figures',6)
    %
end
%
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
