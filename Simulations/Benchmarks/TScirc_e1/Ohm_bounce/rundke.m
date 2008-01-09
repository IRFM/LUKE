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
id_simul = 'Ohm_bounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [linspace(0,0.2,11),linspace(0.25,0.9,14),linspace(0.925,1,5)];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil_cyl = 'TScyl';%For plasma equilibrium
id_equil = 'TScirc_e1';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
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
[equil_cyl] = load_structures_yp('equil',id_equil_cyl,path_equil);
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
epsi = 0.001;
betath = 0.01;%validated for NR limit
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
equil_cyl.pTe = betath^2*mc2*ones(size(equil_cyl.pTe));
equil_cyl.pzTi = betath^2*mc2*ones(size(equil_cyl.pzTi));
%equil_cyl.pzTi = 1e-10*ones(size(equil_cyl.pzTi));
%
ohm_cyl = ohm_flat(equil_cyl,epsi);
ohm = ohm_flat(equil,epsi);
%
[Znorm_cyl,Zcurr_cyl] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil_cyl,dkeparam,dkedisplay,ohm_cyl,waves,transpfaste,ripple,[],[]);
%
dkeparam.bounce_mode = 1;
dkeparam.nmhu_S = 76;
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%	    
%************************************************************************************************************************************
%
iar_luke = equilDKE.xrho*equilDKE.ap/equilDKE.Rp;%Circular inverse aspect ratio
sigman_luke = Zcurr.x_tot_fsav./Zcurr_cyl.x_tot_fsav;
%
[iar,sigman_sc] = conductivity_model_yp(equil,1);%Sigmar-Coppi model (low inverse aspect ratio limit)
[iar,sigman_cghk] = conductivity_model_yp(equil,2);%Connor et al. model (arbitrary inverse aspect ratio)
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'LUKE','Sigmar-Coppi','Connor et al.','Location','NorthWest'};
xlim = [0,1];
ylim = [1,10000];
xlab = 'r/R_p';
ylab = '\sigma_{cyl}/\sigma';
tit = '';
graph1D_jd(iar_luke,1./sigman_luke,0,1,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(iar,1./sigman_sc,0,0,'','','',leg,xlim,ylim,'-','none','b',2,20,gca);
graph1D_jd(iar,1./sigman_cghk,0,0,'','','',leg,xlim,ylim,'--','none','g',2,20,gca);
set(gca,'xtick',[0:0.2:1])
set(gca,'ytick',[1 10 100 1000 10000])
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
print_jd(2,'fig_sigma_bounce','.',1)
%
%************************************************************************************************************************************
%
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
