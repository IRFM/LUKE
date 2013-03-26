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
id_simul = 'Runaway_norm';%Simulation ID
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
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
betath = 0.001;%validated for NR limit
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
dkeparam.coll_mode = 0;% Relativistic Maxwellian background
dkeparam.timevol = 1;%to calculate moments at all internal times
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
dtn = 100;% time step
nit = 100;% number of iterations
tn_max = dtn*nit;% total time
%
epsi = 0.04;%corresponds to pc/pT = 5
%
ohm = ohm_flat(equil,epsi);
%
RR_kulsrud = 1.914*1e-6;%Kulsrud (PRL, 31,11, (1972) 690)
%
% Different conservation schemes
%
dkeparam.dtn = dtn; 
dkeparam.tn = tn_max; 
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out_0] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRv_0 = NaN(1,nit);
xRRs_0 = NaN(1,nit);
for it=1:nit,
    xRRv_0(it) = (dke_out_0.normf0{it}(1) - dke_out_0.normf0{it}(end))/dtn;
    xRRs_0(it) = dke_out_0.XxRR_fsav{it}(end,:);
end
%
dkeparam.boundary_mode_f = 1;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out_1] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRv_1 = NaN(1,nit);
xRRs_1 = NaN(1,nit);
for it=1:nit,
    xRRv_1(it) = (dke_out_1.normf0{it}(1) - dke_out_1.normf0{it}(end))/dtn;
    xRRs_1(it) = dke_out_1.XxRR_fsav{it}(end,:);
end
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
[dummy,dummy,dummy,dke_out_2] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
xRRv_2 = NaN(1,nit);
xRRs_2 = NaN(1,nit);
for it=1:nit,
    xRRv_2(it) = (dke_out_2.normf0{it}(1) - dke_out_2.normf0{it}(end))/dtn;
    xRRs_2(it) = dke_out_2.XxRR_fsav{it}(end,:);
end
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'Volumic losses','Boundary losses','Runaway losses'};
xlim = [0,tn_max];
ylim = [1.5e-6,2e-6];
xlab = 't/\tau_c';
ylab = '\Gamma_R';
tit = '';
siz = 20+14i;
%
graph1D_jd(dtn:dtn:tn_max,xRRv_0,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(dtn:dtn:tn_max,xRRs_0,0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],0,0,'','','',leg,xlim,ylim,'--','none','k',2,siz,gca);
graph1D_jd(dtn:dtn:tn_max,xRRv_1,0,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(dtn:dtn:tn_max,xRRs_1,0,0,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
graph1D_jd(dtn:dtn:tn_max,xRRv_2,0,0,'','','',NaN,xlim,ylim,'-','none','g',2,siz,gca);
graph1D_jd(dtn:dtn:tn_max,xRRs_2,0,0,'','','',NaN,xlim,ylim,'--','none','g',2,siz,gca);
%
print_jd(p_opt,'fig_runaway_norm','./figures',1)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
