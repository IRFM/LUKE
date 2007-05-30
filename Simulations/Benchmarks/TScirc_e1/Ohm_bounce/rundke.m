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
rho_S = [linspace(0.005,0.02,10),linspace(0.025,0.95,20)];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil_cyl = 'TScyl';%For plasma equilibrium
id_equil = 'TScirc_e1';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'BOUNCE3D_MUMPS';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = 'OHM_p001_flat';%For Ohmic electric contribution
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
[dkepath_cyl,equil_cyl,dkeparam_cyl,dkedisplay_cyl,ohm_cyl,waves_cyl,transpfaste_cyl,ripple_cyl] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil_cyl,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam_cyl.invproc = -2;dkeparam.invproc = -2;end
%
[Znorm_cyl,Zcurr_cyl,ZP0_cyl] = main_dke_yp(id_simul,psin_S,0,dkepath_cyl,equil_cyl,dkeparam_cyl,dkedisplay_cyl,ohm_cyl,waves_cyl,transpfaste_cyl,ripple_cyl,[],[]);
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%	    
%************************************************************************************************************************************
%
epsi_circ = equilDKE.xrho*equilDKE.ap/equilDKE.Rp;%Circular inverse aspect ratio
sigman_luke = Zcurr.x_tot_fsav/Zcurr_cyl.x_tot_fsav;
sigman_sc = 1 - 1.95*sqrt(epsi_circ) + 0.95*epsi_circ;
figure(1),clf,graph1D_jd(epsi_circ,1./sigman_luke,0,1,'Inverse aspect ratio','Normalized conductivity','Normalized conductivity',NaN,'','','none','+','r',2,20,gca,1,0.6,0.6);hold on
graph1D_jd(epsi_circ,1./sigman_sc,0,1,'Inverse aspect ratio','Normalized resistivity','Normalized resistivity',NaN,'','','-','non','b',1,20,gca,1,0.6,0.6);
legend('DKE code','Sigmar-Coppi')
savefig_dke_yp('ohm_bounce','Figures/')
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
