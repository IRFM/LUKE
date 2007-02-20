%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
pause(1)
%[s,dossier,machine] = comput_dke_yp;
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = '20Z_Alpha_3p7_fineGrid';%Simulation ID
%id_simul = '20Z_Alpha_3p7_noBounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0,0.6:0.02:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'DRFC_JOAN';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'ITER_Scen4_IAEA06';%For plasma equilibrium
path_equil = 'EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'LH_RT';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'20Z_Alpha_3p7'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'WAVE/C3PO/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple] = load_structures_yp(id_path,path_path,id_equil,path_equil,id_dkeparam,path_dkeparam,id_display,path_display,id_ohm,path_ohm,ids_wave,paths_wave,id_transpfaste,path_transpfaste,id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
dkeparam.delta_rt = 0.25;
%dkeparam.bounce_mode = 0;
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
