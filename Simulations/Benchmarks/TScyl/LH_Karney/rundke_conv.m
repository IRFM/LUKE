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
id_simul = 'LH_karney_conv';%Simulation ID
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
dkeparam.prec0_f = -1;
%
dkeparam.nmhu_S = 201;
dkeparam.np_S = 201;
dkeparam.pnmax_S = 20;
%
tnmax = 500000;%5000;
dtn = 10000;%100;
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
betath = 0.001;%validated for NR limit
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%
wavestruct.yvparmin_lh = [3];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [5];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
dkeparam.dtn = dtn;
dkeparam.nit_f = round(tnmax/dtn);
%
dkeparam.coll_mode = 0;
%
[Znorm,Zcurr,ZP0,dke_out_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
dkeparam.coll_mode = 2;
%
[Znorm,Zcurr,ZP0,dke_out_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
j_k_0 = 0.05759;
j_k_2 = 0.07092;
%
dcurr_0 = abs(dke_out_0.curr0 - dke_out_0.curr0(end))/dke_out_0.curr0(end);
dcurr_2 = abs(dke_out_2.curr0 - dke_out_2.curr0(end))/dke_out_2.curr0(end);
%
dnorm_0 = abs(dke_out_0.normf0 - dke_out_0.normf0(end))/dke_out_0.normf0(end);
dnorm_2 = abs(dke_out_2.normf0 - dke_out_2.normf0(end))/dke_out_2.normf0(end);
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'Linearized','Maxwellian'};
xlim = [0,tnmax];
ylim = [0,0.1];
xlab = 't/\tau_c';
ylab = 'j';
tit = '';
%
graph1D_jd(0:dtn:tnmax,dke_out_2.curr0,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(0:dtn:tnmax,dke_out_0.curr0,0,0,'','','',leg,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(xlim,[j_k_2,j_k_2],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(xlim,[j_k_0,j_k_0],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[0:0.2:1]*xlim(2))
%
figure(2),clf
%
leg = {'Linearized','Maxwellian'};
xlim = [0,tnmax];
ylim = 10.^[-20,0];
xlab = 't/\tau_c';
ylab = 'R_f';
tit = '';
%
graph1D_jd(dtn:dtn:tnmax,dke_out_2.residu_f,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(dtn:dtn:tnmax,dke_out_0.residu_f,0,1,'','','',leg,xlim,ylim,'-','none','b',2,20,gca);
set(gca,'xtick',[0:0.2:1]*xlim(2))
set(gca,'ytick',[1e-20 1e-15 1e-10 1e-5 1])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(3),clf
%
leg = {'Linearized','Maxwellian'};
xlim = [0,tnmax];
ylim = 10.^[-20,0];
xlab = 't/\tau_c';
ylab = '(j-j_f)/j_f';
tit = '';
%
graph1D_jd(0:dtn:tnmax,dcurr_2,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(0:dtn:tnmax,dcurr_0,0,1,'','','',leg,xlim,ylim,'-','none','b',2,20,gca);
set(gca,'xtick',[0:0.2:1]*xlim(2))
set(gca,'ytick',[1e-20 1e-15 1e-10 1e-5 1])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(4),clf
%
leg = {'Linearized','Maxwellian'};
xlim = [0,tnmax];
ylim = 10.^[-20,0];
xlab = 't/\tau_c';
ylab = '(n-n_f)/n_f';
tit = '';
%
graph1D_jd(0:dtn:tnmax,dnorm_2,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(0:dtn:tnmax,dnorm_0,0,1,'','','',leg,xlim,ylim,'-','none','b',2,20,gca);
set(gca,'xtick',[0:0.2:1]*xlim(2))
set(gca,'ytick',[1e-20 1e-15 1e-10 1e-5 1])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
% print_jd(2,'fig_j_conv','.',1)
% print_jd(2,'fig_Rf_conv','.',2)
% print_jd(2,'fig_jn_conv','.',3)
% print_jd(2,'fig_nn_conv','.',4)
%
print_jd(2,'fig_j_conv_ss','.',1)
print_jd(2,'fig_Rf_conv_ss','.',2)
print_jd(2,'fig_jn_conv_ss','.',3)
print_jd(2,'fig_nn_conv_ss','.',4)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
