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
dkeparam.coll_mode = 0;% Relativistic Maxwellian background
dkeparam.nit_f = 1;%Enforcing a single iteration
%
dtn = 1000;
tn_max = 200000;
%
nit_f = round(tn_max/dtn);
%
epsi = 0.04;%corresponds to pc/pT = 5
%
ohm = ohm_flat(equil,epsi);
%
RR_kulsrud = 1.914*1e-6;%Kulsrud (PRL, 31,11, (1972) 690)
%
% Different conservation schemes
%
XXf0_0 = [];
XXf0_1 = [];
XXf0_2 = [];
%
dkeparam.dtn = dtn; 
%
for it = 1:nit_f,
    %
    dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
    dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
    %
	[Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_0,[]);
    %
    xRRv_0(it) = (dke_out.normf0(1) - dke_out.normf0(2))/dtn;
    xRRs_0(it) = dke_out.XxRR_fsav(end,:);
    XXf0_0 = dke_out.XXf0;
    %
    dkeparam.boundary_mode_f = 1;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
    dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
    %
	[Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_1,[]);
    %
    xRRv_1(it) = (dke_out.normf0(1) - dke_out.normf0(2))/dtn;
    xRRs_1(it) = dke_out.XxRR_fsav(end,:);
    XXf0_1 = dke_out.XXf0;
    %
    dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
    dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
    %
	[Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,XXf0_2,[]);
    %
    xRRv_2(it) = (dke_out.normf0(1) - dke_out.normf0(2))/dtn;
    xRRs_2(it) = dke_out.XxRR_fsav(end,:);
    XXf0_2 = dke_out.XXf0;
    %
end
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'Volumic losses','Boundary losses','Runaway losses'};
xlim = [dtn,tn_max];
ylim = 10.^[-7,-5];
xlab = '\Deltat';
ylab = '\Gamma_R';
tit = '';
graph1D_jd(dtn:dtn:tn_max,xRRv_0,1,1,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(dtn:dtn:tn_max,xRRs_0,1,1,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],1,1,'','','',leg,xlim,ylim,'--','none','k',2,20,gca);
graph1D_jd(dtn:dtn:tn_max,xRRv_1,1,1,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(dtn:dtn:tn_max,xRRs_1,1,1,'','','',NaN,xlim,ylim,'--','none','b',2,20,gca);
graph1D_jd(dtn:dtn:tn_max,xRRv_2,1,1,'','','',NaN,xlim,ylim,'-','none','g',2,20,gca);
graph1D_jd(dtn:dtn:tn_max,xRRs_2,1,1,'','','',NaN,xlim,ylim,'--','none','g',2,20,gca);
set(gca,'ytick',[1e-07 1e-06 1e-05])
%set(gca,'xtick',[1e-08 1e-06 1e-04 1e-02 1 1e2 1e4 1e6 1e8])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(2,'fig_runaway_norm','.',1)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
