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
id_simul = 'Runaway_time';%Simulation ID
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
epsi = 0.04;%corresponds to pc/pT = 5
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = ones(length(equil.zZi),1)*equil.pTe;
%
ohm = ohm_flat(equil,epsi);
%
RR_kulsrud = 1.914*1e-6;%Kulsrud (PRL, 31, 11, (1972) 690)
%
dkeparam.timevol = 1;%to calculate moments at all internal times
%
tn = logspace(0,5,101);
nit = length(tn);
dtn = diff([0,tn]);
%
dkeparam.dtn = NaN;% time steps prescribed by vector tn
dkeparam.tn = tn;%when dtn is a vector of time steps
%
dkeparam.coll_mode = 0;% Relativistic Maxwellian background
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRv_0 = NaN(1,nit);
xRRs_0 = NaN(1,nit);
for it=1:nit,
    xRRv_0(it) = (dke_out_0.normf0{it}(1) - dke_out_0.normf0{it}(end))/dtn(it);
    xRRs_0(it) = dke_out_0.XxRR_fsav{it}(end,:);
end
%
dkeparam.boundary_mode_f = 1;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out_1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRv_1 = NaN(1,nit);
xRRs_1 = NaN(1,nit);
for it=1:nit,
    xRRv_1(it) = (dke_out_1.normf0{it}(1) - dke_out_1.normf0{it}(end))/dtn(it);
    xRRs_1(it) = dke_out_1.XxRR_fsav{it}(end,:);
end
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRv_2 = NaN(1,nit);
xRRs_2 = NaN(1,nit);
for it=1:nit,
    xRRv_2(it) = (dke_out_2.normf0{it}(1) - dke_out_2.normf0{it}(end))/dtn(it);
    xRRs_2(it) = dke_out_2.XxRR_fsav{it}(end,:);
end
%
dkeparam.coll_mode = 1;% High-velocity limit
%
[dummy,dummy,dummy,dke_out_2_1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRv_2_1 = NaN(1,nit);
xRRs_2_1 = NaN(1,nit);
for it=1:nit,
    xRRv_2_1(it) = (dke_out_2_1.normf0{it}(1) - dke_out_2_1.normf0{it}(end))/dtn(it);
    xRRs_2_1(it) = dke_out_2_1.XxRR_fsav{it}(end,:);
end
%
dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
%
[dummy,dummy,dummy,dke_out_2_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xresidue_2_2 = NaN(1,nit);
xRRv_2_2 = NaN(1,nit);
xRRs_2_2 = NaN(1,nit);
for it=1:nit,
    xresidue_2_2(it) = dke_out_2_2.residu_f{it}(end);
    xRRv_2_2(it) = (dke_out_2_2.normf0{it}(1) - dke_out_2_2.normf0{it}(end))/dtn(it);
    xRRs_2_2(it) = dke_out_2_2.XxRR_fsav{it}(end,:);
end
xRRv_2_2(xresidue_2_2 > dkeparam.prec0_f) = NaN;
xRRs_2_2(xresidue_2_2 > dkeparam.prec0_f) = NaN;
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'Free Mode','Fixed point','Normalization','Kulsrud'};
xlim = 10.^[2,5];
ylim = 10.^[-7,-5];
xlab = 't/\tau_c';
ylab = '\Gamma_R\tau_c';
tit = '';
siz = 20+14i;
%
graph1D_jd(tn,xRRs_0,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(tn,xRRs_1,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(tn,xRRs_2,1,1,'','','',NaN,xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],1,1,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'xtick',10.^[2:5])
set(gca,'ytick',10.^[-7:-5])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(2),clf
%
leg = {'Linearized','High v limit','Maxwellian'};
%
graph1D_jd(tn,xRRs_2_2,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(tn,xRRs_2_1,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(tn,xRRs_2,1,1,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
%
set(gca,'xtick',10.^[2:5])
set(gca,'ytick',10.^[-7:-5])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(3),clf
xlim = 10.^[0,5];
ylim = 10.^[-8,-4.99];
%
mask = xRRv_0 > 0;
%
leg = {'Volumic losses','Boundary losses','Runaway rate'};
%
graph1D_jd(tn(mask),xRRv_0(mask),1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(tn,xRRs_0,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],1,1,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
graph1D_jd(tn(~mask),-xRRv_0(~mask),1,1,xlab,ylab,tit,NaN,xlim,ylim,'--','none','r',2,siz,gca);
%
set(gca,'ytick',[1e-010 1e-09 1e-08 1e-07 1e-06 1e-05])
set(gca,'xtick',[1 10 100 1000 10000 100000])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(p_opt,'fig_runaway_time_vs','.',1)
print_jd(p_opt,'fig_runaway_time_coll','.',2)
print_jd(p_opt,'fig_runaway_time_mode','.',3)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
