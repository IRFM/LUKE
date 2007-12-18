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
id_simul = 'Runaway_init';%Simulation ID
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
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
betath = 0.001;%validated for NR limit
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
dkeparam.boundary_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes
dkeparam.prec0_f = -1;
%
dtn = 100;
tn_max = 10000;
%
nit_f = round(tn_max/dtn);
%
epsi = 0.04;%corresponds to pc/pT = 5
%
ohm = ohm_flat(equil,epsi);
%
RR_kulsrud = 1.914*1e-6;%Kulsrud (PRL, 31,11, (1972) 690)
%
dkeparam.dtn = dtn;    
dkeparam.nit_f = nit_f;%Enforcing a single iteration
%
dkeparam.coll_mode = 0;% Relativistic Maxwellian background
%
[Znorm_0,Zcurr_0,ZP0_0,dke_out_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
%
[Znorm_2,Zcurr_2,ZP0_2,dke_out_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
normf0_0 = dke_out_0.normf0;
RRv_end_0 = (normf0_0(end-1) - normf0_0(end))/dtn;
RRs_end_0 = dke_out_0.XxRR_fsav(end,:);
%
normf0_2 = dke_out_2.normf0;
RRv_end_2 = (normf0_2(end-1) - normf0_2(end))/dtn;
RRs_end_2 = dke_out_2.XxRR_fsav(end,:);
%
XXf0_0 = [];
XXf0_2 = [];
%
dkeparam.nit_f = 1;%Enforcing a single iteration
%
for it = 1:nit_f,
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    %
    [Znorm_0,Zcurr_0,ZP0_0,dke_out_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_0,[]);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    %
    [Znorm_2,Zcurr_2,ZP0_2,dke_out_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_2,[]);
    %
    xnormf0_0(it) = Znorm_0.x_0_fsav;
    xRRv_0(it) = (dke_out_0.normf0(1) - dke_out_0.normf0(2))/dtn;
    xRRs_0(it) = dke_out_0.XxRR_fsav(end,:);
    %
    xnormf0_2(it) = Znorm_2.x_0_fsav;
    xRRv_2(it) = (dke_out_2.normf0(1) - dke_out_2.normf0(2))/dtn;
    xRRs_2(it) = dke_out_2.XxRR_fsav(end,:);
    %
    XXf0_0 = dke_out_0.XXf0;
    %
    XXf0_2 = dke_out_2.XXf0;
    %
end
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'Single run','Multiple runs'};
xlim = [0,tn_max];
ylim = 10.^[-10,0];
xlab = '\Deltat';
ylab = '\Deltan/n_0';
tit = '';
graph1D_jd((0:nit_f)*dtn,1-normf0_0,0,1,xlab,ylab,tit,NaN,xlim,ylim,'--','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd((1:nit_f)*dtn,1-xnormf0_0,0,1,'','','',leg,xlim,ylim,'-','none','b',0.5,20,gca);
set(gca,'ytick',[1e-010 1e-08 1e-06 1e-04 1e-02 1e-00])
set(gca,'xtick',[0:tn_max/5:tn_max])
set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(2),clf
%
graph1D_jd((0:nit_f)*dtn,1-normf0_2,0,1,xlab,ylab,tit,NaN,xlim,ylim,'--','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd((1:nit_f)*dtn,1-xnormf0_2,0,1,'','','',leg,xlim,ylim,'-','none','b',0.5,20,gca);
set(gca,'ytick',[1e-010 1e-08 1e-06 1e-04 1e-02 1e-00])
set(gca,'xtick',[0:tn_max/5:tn_max])
set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(3),clf
%
leg = {'Volumic losses','Boundary losses','Runaway losses'};
xlim = [dtn,tn_max];
ylim = 10.^[-10,-5];
xlab = '\Deltat';
ylab = '\Gamma_R';
tit = '';
graph1D_jd((1:nit_f)*dtn,xRRv_0,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd((1:nit_f)*dtn,xRRs_0,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],1,1,'','','',leg,xlim,ylim,'--','none','k',0.5,20,gca);
graph1D_jd(xlim,[RRv_end_0,RRv_end_0],1,1,'','','',NaN,xlim,ylim,'--','none','r',0.5,20,gca);
graph1D_jd(xlim,[RRs_end_0,RRs_end_0],1,1,'','','',NaN,xlim,ylim,'--','none','b',0.5,20,gca);
set(gca,'ytick',[1e-010 1e-09 1e-08 1e-07 1e-06 1e-05])
set(gca,'xtick',[1 10 100 1000 10000])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(4),clf
%
graph1D_jd((1:nit_f)*dtn,xRRv_0,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd((1:nit_f)*dtn,xRRs_0,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],1,1,'','','',leg,xlim,ylim,'--','none','k',2,20,gca);
set(gca,'ytick',[1e-010 1e-09 1e-08 1e-07 1e-06 1e-05])
set(gca,'xtick',[1 10 100 1000 10000])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(5),clf
%
leg = {'Volumic losses','Boundary losses'};
graph1D_jd((1:nit_f)*dtn,xRRv_2,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd((1:nit_f)*dtn,xRRs_2,1,1,'','','',leg,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(xlim,[RRv_end_2,RRv_end_2],1,1,'','','',NaN,xlim,ylim,'--','none','r',0.5,20,gca);
graph1D_jd(xlim,[RRs_end_2,RRs_end_2],1,1,'','','',NaN,xlim,ylim,'--','none','b',0.5,20,gca);
set(gca,'ytick',[1e-010 1e-09 1e-08 1e-07 1e-06 1e-05])
set(gca,'xtick',[1 10 100 1000 10000])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(2,'fig_runaway_init_cons_coll0','.',1)
print_jd(2,'fig_runaway_init_cons_coll2','.',2)
print_jd(2,'fig_runaway_init_RR_coll0','.',3)
print_jd(2,'fig_runaway_init_RR_coll0_time','.',4)
print_jd(2,'fig_runaway_init_RR_coll2','.',5)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
