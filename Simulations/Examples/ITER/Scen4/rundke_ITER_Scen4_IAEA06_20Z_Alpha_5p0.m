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
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = '20Z_Alpha_5p0';%Simulation ID
%id_simul = '20Z_Alpha_5p0_noBounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0,0.6:0.02:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_dkepath = 'DRFC_JOAN';%For all paths used by DKE solver
path_dkepath = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'ITER_Scen4_IAEA06';%For plasma equilibrium
path_equil = 'EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'LH_RT';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkedisplay = 'PARTIAL_VISUAL';%For output code display
path_dkedisplay = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'20Z_Alpha_5p0'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'WAVE/C3PO/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_dkepath,path_dkepath,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_dkedisplay,path_dkedisplay,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
dkeparam.rt_mode = 1;
dkeparam.delta_rt = 0.25;
%dkeparam.bounce_mode = 0;
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,[],waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[],0)
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
