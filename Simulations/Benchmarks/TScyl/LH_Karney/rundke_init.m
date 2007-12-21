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
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_init';%Simulation ID
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
%
dkeparam.np_S = 201;
dkeparam.nmhu_S = 201;
%
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
betath_list = [logspace(-3,-2,7),logspace(-1.85,-0.35,11)];betath_list = betath_list(1:15);
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
for ibetath = 1:length(betath_list),
    %
    betath = betath_list(ibetath);
    %
    equil.pTe = betath^2*mc2*ones(size(equil.pTe));
    equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    dkeparam.initguess_f =  0;
    [Znorm,Zcurr_M0,ZP0_M0,dke_out_M0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkeparam.initguess_f =  1; 
    [Znorm,Zcurr_NM0,ZP0_NM0,dke_out_NM0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    dkeparam.coll_mode = 1;% High-velocity limit
    dkeparam.initguess_f =  0;
    [Znorm,Zcurr_M1,ZP0_M1,dke_out_M1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkeparam.initguess_f =  1;
    [Znorm,Zcurr_NM1,ZP0_NM1,dke_out_NM1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    dkeparam.initguess_f =  0;
    [Znorm,Zcurr_M2,ZP0_M2,dke_out_M2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkeparam.initguess_f =  1;
    if ibetath == 14,
        dkedisplay.display_init = 1;%Display the initial distribution function only
    end
    [Znorm,Zcurr_NM2,ZP0_NM2,dke_out_NM2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkedisplay.display_init = 0;
    %
    j_M0(ibetath) = Zcurr_M0.x_0;
    j_M1(ibetath) = Zcurr_M1.x_0;
    j_M2(ibetath) = Zcurr_M2.x_0;
    %
    P_M0(ibetath) = ZP0_M0.x_rf_fsav;
    P_M1(ibetath) = ZP0_M1.x_rf_fsav;
    P_M2(ibetath) = ZP0_M2.x_rf_fsav;
    %
    cur_M0(ibetath,1) = dke_out_M0.curr0(1);
    cur_M0(ibetath,2) = dke_out_M0.curr0(find(dke_out_M0.curr0~=0,1,'last'));    
    cur_M0(ibetath,3) = find(dke_out_M0.curr0~=0,1,'last');    
    %
    cur_M1(ibetath,1) = dke_out_M1.curr0(1);
    cur_M1(ibetath,2) = dke_out_M1.curr0(find(dke_out_M1.curr0~=0,1,'last'));    
    cur_M1(ibetath,3) = find(dke_out_M1.curr0~=0,1,'last');    
    %
    cur_M2(ibetath,1) = dke_out_M2.curr0(1);
    cur_M2(ibetath,2) = dke_out_M2.curr0(find(dke_out_M2.curr0~=0,1,'last'));    
    cur_M2(ibetath,3) = find(dke_out_M2.curr0~=0,1,'last');    
%
    j_NM0(ibetath) = Zcurr_NM0.x_0;
    j_NM1(ibetath) = Zcurr_NM1.x_0;
    j_NM2(ibetath) = Zcurr_NM2.x_0;
    %
    P_NM0(ibetath) = ZP0_NM0.x_rf_fsav;
    P_NM1(ibetath) = ZP0_NM1.x_rf_fsav;
    P_NM2(ibetath) = ZP0_NM2.x_rf_fsav;
    %
    cur_NM0(ibetath,1) = dke_out_NM0.curr0(1);
    cur_NM0(ibetath,2) = dke_out_NM0.curr0(find(dke_out_NM0.curr0~=0,1,'last'));    
    cur_NM0(ibetath,3) = find(dke_out_NM0.curr0~=0,1,'last');    
    %
    cur_NM1(ibetath,1) = dke_out_NM1.curr0(1);
    cur_NM1(ibetath,2) = dke_out_NM1.curr0(find(dke_out_NM1.curr0~=0,1,'last'));    
    cur_NM1(ibetath,3) = find(dke_out_NM1.curr0~=0,1,'last');    
    %
    cur_NM2(ibetath,1) = dke_out_NM2.curr0(1);
    cur_NM2(ibetath,2) = dke_out_NM2.curr0(find(dke_out_NM2.curr0~=0,1,'last'));    
    cur_NM2(ibetath,3) = find(dke_out_NM2.curr0~=0,1,'last');   
end
%
eta_M0 = j_M0./P_M0;
eta_M1 = j_M1./P_M1;
eta_M2 = j_M2./P_M2;
%
eta_NM0 = j_NM0./P_NM0;
eta_NM1 = j_NM1./P_NM1;
eta_NM2 = j_NM2./P_NM2;
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
leg0 = {'Linearized (f_{M0})','High v limit (f_{M0})','Maxwellian (f_{M0})','Linearized (f_{NM0})','High v limit (f_{NM0})','Maxwellian (f_{NM0})'};
leg1 = {'Linearized (f_{NM}(end))','High v limit (f_{NM}(end))','Maxwellian (f_{NM}(end))','LH model (f_{NM}(1))'};
xlim = 10.^[-3,0];
ylim = [0,0.1];
xlab = '\beta_T';
ylab = 'j';
ylab1 = 'Number of iterations';
tit = '';
%
figure('Name','Final LH current solutions');clf
%
graph1D_jd(betath_list,j_M2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,j_M1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(betath_list,j_M0,1,0,'','','',NaN,xlim,ylim,'-','none','g',2,20,gca);
%
graph1D_jd(betath_list,j_NM2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'none','*','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,j_NM1,1,0,'','','',NaN,xlim,ylim,'none','*','b',2,20,gca);
graph1D_jd(betath_list,j_NM0,1,0,'','','',leg0,xlim,ylim,'none','*','g',2,20,gca);
%
graph1D_jd(xlim,[j_2_nr_Karney,j_2_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(xlim,[j_0_nr_Karney,j_0_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure('Name','Initial & final LH current solutions');clf
%
graph1D_jd(betath_list,cur_NM2(:,2),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,cur_NM1(:,2),1,0,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(betath_list,cur_NM0(:,2),1,0,'','','',NaN,xlim,ylim,'-','none','g',2,20,gca);
%
graph1D_jd(betath_list,cur_NM0(:,1),1,0,'','','',leg1,xlim,ylim,'none','*','r',2,20,gca);
%
graph1D_jd(xlim,[j_2_nr_Karney,j_2_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(xlim,[j_0_nr_Karney,j_0_nr_Karney],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure('Name','Convergence rate');clf
%
graph1D_jd(betath_list,cur_M2(:,3),1,0,xlab,ylab1,tit,NaN,xlim,[0,20],'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,cur_M1(:,3),1,0,'','','',NaN,xlim,[0,20],'-','none','b',2,20,gca);
graph1D_jd(betath_list,cur_M0(:,3),1,0,'','','',NaN,xlim,[0,20],'-','none','g',2,20,gca);
%
graph1D_jd(betath_list,cur_NM2(:,3),1,0,xlab,ylab1,tit,NaN,xlim,[0,20],'none','*','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,cur_NM1(:,3),1,0,'','','',NaN,xlim,[0,20],'none','*','b',2,20,gca);
graph1D_jd(betath_list,cur_NM0(:,3),1,0,'','','',leg1,xlim,[0,20],'none','*','g',2,20,gca);
%
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
