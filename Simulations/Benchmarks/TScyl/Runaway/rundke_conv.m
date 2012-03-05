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
id_simul = 'Runaway_conv';%Simulation ID
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
id_display = 'NO_DISPLAY';%For output code display
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
if exist('dmumpsmex','file');dkeparam.invproc = -2;end
%
betath = 0.001;%validated for NR limit
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
%
epsi = 0.04;%corresponds to pc/pT = 5
%
ohm = ohm_flat(equil,epsi);
%
% Building the distribution function to a quasi steady-state for the
% runaway problem : tn = 10000
%
nit_f = 500;%number of Legendre iterations
dtn = 100000;%single time step for Legendre convergence studies
%
dkeparam.tn = 100000;%time for asymptotic solution with norm_mode_f = 1
dkeparam.dtn = dtn;
dkeparam.nit_f = nit_f;
dkeparam.prec0_f = -1;%to reach end of Legendre iterations
%
[dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRs = dke_out.XxRR_fsav(end,:);
xRRv = NaN(1,nit_f);
for it=1:nit_f,
    xRRv(it) = (dke_out.normf0{end}(1) - dke_out.normf0{end}(it+1))/dtn;    
end
dcurr = abs(dke_out.curr0{end} - dke_out.curr0{end}(end))/dke_out.curr0{end}(end);
dnorm = abs(dke_out.normf0{end} - dke_out.normf0{end}(end))/dke_out.normf0{end}(end);
%
%************************************************************************************************************************************
%
%
figure(1),clf
%
leg = {'Volumic losses','Boundary losses'};
xlim = [0,nit_f];
ylim = [0,5]*1e-6;
xlab = '# iterations';
ylab = '\Gamma_R';
tit = '';
siz = 20+14i;
%
graph1D_jd(1:nit_f,xRRv,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(xlim,[xRRs,xRRs],0,0,'','','',leg,xlim,ylim,'--','none','b',2,siz,gca);
%
set(gca,'ytick',[0:5]*1e-6)
%
figure(2),clf
%
ylim = 10.^[-24,-8];
ylab = 'R_f';
%
graph1D_jd(1:nit_f,dke_out.residu_f{end},0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*xlim(2))
set(gca,'ytick',[1e-24 1e-20 1e-16 1e-12 1e-8])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(3),clf
%
ylim = 10.^[-20,0];
ylab = '(j-j_f)/j_f';
%
graph1D_jd(0:nit_f,dcurr,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'xtick',[0:0.2:1]*xlim(2))
set(gca,'ytick',[1e-20 1e-15 1e-10 1e-5 1])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
figure(4),clf
%
ylim = 10.^[-20,0];
ylab = '(n-n_f)/n_f';
%
graph1D_jd(0:nit_f,dnorm,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
%
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
print_jd(2,'fig_runaway_RR_conv_ss','./figures',1)
print_jd(2,'fig_runaway_Rf_conv_ss','./figures',2)
print_jd(2,'fig_runaway_jn_conv_ss','./figures',3)
print_jd(2,'fig_runaway_nn_conv_ss','./figures',4)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
