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
p_opt = 2;
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_betath';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.5];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
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
wavestruct.yvparmin_lh = [3];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [5];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
wavestruct.yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
wavestruct.yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
wavestruct.yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
wavestruct.ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
wavestruct.yD0_in_c_lh = [1];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
wavestruct.yD0_in_lh_prof = [0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
wavestruct.ypeak_lh = [NaN];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
wavestruct.ywidth_lh = [NaN];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
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
dkeparam.np_S = 201;
dkeparam.nmhu_S = 201;
%
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
betath_list = [logspace(-5,-2,7),logspace(-1.85,-0.35,11)];
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
nbetath = length(betath_list);
%
j_0 = NaN(1,nbetath);
j_1 = NaN(1,nbetath);
j_2 = NaN(1,nbetath);
P_0 = NaN(1,nbetath);
P_1 = NaN(1,nbetath);
P_2 = NaN(1,nbetath);
%
for ibetath = 1:nbetath,
    %
    betath = betath_list(ibetath);
    %
    equil.pTe = betath^2*mc2*ones(size(equil.pTe));
    equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    [dummy,Zcurr,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    j_0(ibetath) = Zcurr.x_0;
    P_0(ibetath) = ZP0.x_rf_fsav;
    %
    dkeparam.coll_mode = 1;% High-velocity limit
    [dummy,Zcurr,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    j_1(ibetath) = Zcurr.x_0;
    P_1(ibetath) = ZP0.x_rf_fsav;
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    [dummy,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_2(ibetath) = Zcurr.x_0;
        P_2(ibetath) = ZP0.x_rf_fsav;
    end        
    %
    %dkeparam.coll_mode = 4;% Linearized Belaiev-Budker
    %[Znorm,Zcurr_4,ZP0_4] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %j_4(ibetath) = Zcurr_4.x_0;
    %P_4(ibetath) = ZP0_4.x_rf_fsav;
    %
end
%
eta_0 = j_0./P_0;
eta_1 = j_1./P_1;
eta_2 = j_2./P_2;
%eta_4 = j_4./P_4;
%
j_0_nr_Karney = 0.05759;
P_0_nr_Karney = 0.004012;
eta_0_nr_Karney = 14.35;
%
j_2_nr_Karney = 0.07092;
P_2_nr_Karney = 0.004294;
eta_2_nr_Karney = 16.52;
%
%************************************************************************************************************************************
%
figure(1),clf
%
%leg = {'Linearized','High v limit','Maxwellian NR','Maxwellian'};
leg = {'Linearized','High v limit','Maxwellian'};
xlim = 10.^[-5,0];
ylim = [0,0.1];
xlab = '\beta_T';
ylab = 'j';
tit = '';
siz = 20+14i;
%
graph1D_jd(betath_list,j_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,j_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
%graph1D_jd(betath_list,j_4,1,0,'','','',NaN,xlim,ylim,'-','none','m',2,siz,gca);
graph1D_jd(betath_list,j_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(xlim,[j_2_nr_Karney,j_2_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(xlim,[j_0_nr_Karney,j_0_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(2),clf
%
ylim = [0,0.005];
ylab = 'P';
%
graph1D_jd(betath_list,P_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,P_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
%graph1D_jd(betath_list,P_4,1,0,'','','',NaN,xlim,ylim,'-','none','m',2,siz,gca);
graph1D_jd(betath_list,P_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(xlim,[P_2_nr_Karney,P_2_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(xlim,[P_0_nr_Karney,P_0_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(3),clf
%
ylim = [0,20];
ylab = 'j/P';
%
graph1D_jd(betath_list,eta_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,eta_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
%graph1D_jd(betath_list,eta_4,1,0,'','','',NaN,xlim,ylim,'-','none','m',2,siz,gca);
graph1D_jd(betath_list,eta_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(xlim,[eta_2_nr_Karney,eta_2_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(xlim,[eta_0_nr_Karney,eta_0_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(p_opt,'fig_j_betath','.',1)
print_jd(p_opt,'fig_P_betath','.',2)
print_jd(p_opt,'fig_eta_betath','.',3)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
