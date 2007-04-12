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
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'Zero_test';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.05:0.02:0.2,0.22:0.03:0.6,0.62:0.05:0.95];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'JETh77';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'BOUNCE3D_MUMPS';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = 'OHM_p005_flat';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney_offaxis_2'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = 'magneticturbulence';%For fast electron radial transport
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
%**************************************************************************
%**************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
transpfaste.Dr0 = 5;
%
[Znorm_p,Zcurr_p,ZP0_p,dke_out_p,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
ohm.epsi = -ohm.epsi;%The Ohmic electric field is reversed
waves{1}.rays{1}.sNpar = -waves{1}.rays{1}.sNpar;%The wave direction is reversed
[Znorm_m,Zcurr_m,ZP0_m,dke_out_m] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
figure(1),clf,graph1D_jd(gridDKE.xrho,Zcurr_p.x_tot_fsav,0,0,'\rho','Current density','',NaN,'','','-','none','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(gridDKE.xrho,Zcurr_m.x_tot_fsav,0,0,'\rho','Current density','',NaN,'','','-','none','b',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(gridDKE.xrho,Zcurr_p.x_tot_fsav+Zcurr_m.x_tot_fsav,0,0,'\rho','Current density','',NaN,'','','none','*','g',2,20,gca,0.85,0.7,0.5);
legend('N_{||} > 0, E_{field} > 0','N_{||}< 0, E_{field} < 0','Sum')
savefig_dke_yp('profcurr_testzero')
%
figure(2),clf,graph1D_jd(gridDKE.xrho,ZP0_p.x_rf_fsav,0,0,'','','',NaN,'','','-','none','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(gridDKE.xrho,ZP0_p.x_c_fsav,0,0,'','','',NaN,'','','--','none','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(gridDKE.xrho,ZP0_m.x_rf_fsav,0,0,'','','',NaN,'','','none','+','b',2,20,gca,0.85,0.7,0.5);
graph1D_jd(gridDKE.xrho,ZP0_m.x_c_fsav,0,0,'\rho','Power','',NaN,'','','none','*','b',2,20,gca,0.85,0.7,0.5);
legend('P_{LH}: N_{||} > 0, E_{field} > 0','P_{coll}: N_{||} > 0, E_{field} > 0','P_{LH}: N_{||} < 0, E_{field} < 0','P_{coll}: N_{||} < 0, E_{field} < 0')
savefig_dke_yp('profP_testzero')
%
figure(3),clf,graph1D_jd(gridDKE.xrho,Znorm_p.x_0_fsav,0,0,'','','',NaN,'','','-','none','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(gridDKE.xrho,Znorm_m.x_0_fsav,0,0,'\rho','Density','',NaN,'','','none','*','b',2,20,gca,0.85,0.7,0.5);
legend('N_{||} > 0, E_{field} > 0','N_{||} < 0, E_{field} < 0')
savefig_dke_yp('profne_testzero')
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);