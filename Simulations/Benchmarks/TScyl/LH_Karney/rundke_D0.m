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
id_simul = 'LH_karney_D0';%Simulation ID
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
%wavestruct.yD0_in_c_lh = [1];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
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
dkeparam.prec0_f = 1e-15;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
dkeparam.np_S = 401;
dkeparam.nmhu_S = 401;
dkeparam.pnmax_S = 10;
%
betath = 0.001;
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
D0_list = [logspace(-6,-2,9),logspace(-1.75,2,16)];
%
for iD0 = 1:length(D0_list),
    %
    wavestruct.yD0_in_c_lh = [D0_list(iD0)];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    dkeparam.oldcross_mode = 0;%Cross-derivatives as given in paper Peysson-Shoucri CPC 98
    [Znorm,Zcurr_0,ZP0_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkeparam.oldcross_mode = 1;%Cross-derivatives as given in paper Peysson-Shoucri CPC 98
    [Znorm,Zcurr_0a,ZP0_0a] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    dkeparam.coll_mode = 1;% High-velocity limit
    dkeparam.oldcross_mode = 0;%Cross-derivatives as given in paper Peysson-Shoucri CPC 98
    [Znorm,Zcurr_1,ZP0_1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkeparam.oldcross_mode = 1;%Cross-derivatives as given in paper Peysson-Shoucri CPC 98
    [Znorm,Zcurr_1a,ZP0_1a] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    dkeparam.oldcross_mode = 0;%Cross-derivatives as given in paper Peysson-Shoucri CPC 98
    [Znorm,Zcurr_2,ZP0_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkeparam.oldcross_mode = 1;%Cross-derivatives as given in paper Peysson-Shoucri CPC 98
    [Znorm,Zcurr_2a,ZP0_2a] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    j_0(iD0) = Zcurr_0.x_0;
    j_1(iD0) = Zcurr_1.x_0;
    j_2(iD0) = Zcurr_2.x_0;
    %
    j_0a(iD0) = Zcurr_0a.x_0;
    j_1a(iD0) = Zcurr_1a.x_0;
    j_2a(iD0) = Zcurr_2a.x_0;
    %
    P_0(iD0) = ZP0_0.x_rf_fsav;
    P_1(iD0) = ZP0_1.x_rf_fsav;
    P_2(iD0) = ZP0_2.x_rf_fsav;
	%
	P_0a(iD0) = ZP0_0a.x_rf_fsav;
    P_1a(iD0) = ZP0_1a.x_rf_fsav;
    P_2a(iD0) = ZP0_2a.x_rf_fsav;
    %
    Pc_0(iD0) = -ZP0_0.x_c_fsav;
    Pc_1(iD0) = -ZP0_1.x_c_fsav;
    Pc_2(iD0) = -ZP0_2.x_c_fsav;
    %
    Pc_0a(iD0) = -ZP0_0a.x_c_fsav;
    Pc_1a(iD0) = -ZP0_1a.x_c_fsav;
    Pc_2a(iD0) = -ZP0_2a.x_c_fsav; 
end
%
eta_0 = j_0./P_0;
eta_1 = j_1./P_1;
eta_2 = j_2./P_2;
%
eta_0a = j_0a./P_0a;
eta_1a = j_1a./P_1a;
eta_2a = j_2a./P_2a;
%
%************************************************************************************************************************************
%
figure(1),clf
%
%leg = {'Linearized','High v limit','Maxwellian NR','Maxwellian'};
leg = {'Linearized','High v limit','Maxwellian'};
xlim = 10.^[-5,1];
xticks = [1e-06 1e-5 0.0001 0.001 0.01 0.1 1 10 100];
ylim = 10.^[-6,-1];
xlab = 'D_0';
ylab = 'j';
tit = '';
%
graph1D_jd(D0_list,j_2,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(D0_list,j_1,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(D0_list,j_0,1,1,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
set(gca,'ytick',[1e-06 1e-05 0.0001 0.001 0.01 0.1])
set(gca,'xtick',xticks)
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(2),clf
%
ylim = 10.^[-7,-2];
ylab = 'P';
%
graph1D_jd(D0_list,P_2,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(D0_list,P_1,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(D0_list,P_0,1,1,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
graph1D_jd(D0_list,Pc_2,1,1,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(D0_list,Pc_1,1,1,'','','',NaN,xlim,ylim,'--','none','b',2,20,gca);
graph1D_jd(D0_list,Pc_0,1,1,'','','',leg,xlim,ylim,'--','none','g',2,20,gca);
set(gca,'ytick',[1e-07 1e-06 1e-05 0.0001 0.001 0.01])
set(gca,'xtick',xticks)
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(3),clf
%
ylim = [0,20];
ylab = 'j/P';
%
graph1D_jd(D0_list,eta_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(D0_list,eta_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(D0_list,eta_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',xticks)
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(4),clf
%
%leg = {'Linearized','High v limit','Maxwellian NR','Maxwellian'};
leg = {'Linearized','High v limit','Maxwellian'};
xlim = 10.^[-5,1];
xticks = [1e-06 1e-5 0.0001 0.001 0.01 0.1 1 10 100];
ylim = 10.^[-6,-1];
xlab = 'D_0';
ylab = 'j';
tit = '';
%
graph1D_jd(D0_list,j_2a,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(D0_list,j_1a,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(D0_list,j_0a,1,1,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
set(gca,'ytick',[1e-06 1e-05 0.0001 0.001 0.01 0.1])
set(gca,'xtick',xticks)
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(5),clf
%
ylim = 10.^[-7,-2];
ylab = 'P';
%
graph1D_jd(D0_list,P_2a,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(D0_list,P_1a,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(D0_list,P_0a,1,1,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
graph1D_jd(D0_list,Pc_2a,1,1,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(D0_list,Pc_1a,1,1,'','','',NaN,xlim,ylim,'--','none','b',2,20,gca);
graph1D_jd(D0_list,Pc_0a,1,1,'','','',leg,xlim,ylim,'--','none','g',2,20,gca);
set(gca,'ytick',[1e-07 1e-06 1e-05 0.0001 0.001 0.01])
set(gca,'xtick',xticks)
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(6),clf
%
ylim = [0,20];
ylab = 'j/P';
%
graph1D_jd(D0_list,eta_2a,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(D0_list,eta_1a,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(D0_list,eta_0a,1,0,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',xticks)
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(2,'fig_j_D0','.',1)
print_jd(2,'fig_P_D0','.',2)
print_jd(2,'fig_eta_D0','.',3)
%
print_jd(2,'fig_j_D0_oldcross','.',4)
print_jd(2,'fig_P_D0_oldcross','.',5)
print_jd(2,'fig_eta_D0_oldcross','.',6)

%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
