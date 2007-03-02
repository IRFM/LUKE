%Script for running the LUKE solver + RT (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker CEA-DRFC (joan.decker@cea.fr)
%
clear all
clear mex
clear functions
close all
warning off
global nfig
pause(1)
%
% ---------------------------------------------- Simulation RT + LUKE ----------------------------------------------
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'tr5p0_a0p05';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
load ('gigajoule_pouryves_luke.mat','dkeparam','dkedisplay','transpfaste','ohm','ripple');
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.05:0.05:0.6,0.7,0.8,0.9];;%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'CRONOS_32299_k100';%For plasma equilibrium
path_equil = 'EQUIL/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'MIXTE_Coupleur_C2','MIXTE_Coupleur_C3'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'WAVE/C3PO/','WAVE/C3PO/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
[dkepath,equil,waves] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'waves',ids_wave,paths_wave);
%
%************************************************************************************************************************************
%
%
waves{1}.a_sdNpar = 0.05;
waves{2}.a_sdNpar = 0.05;
%
transpfaste.Dr0 = 5.0;%Fast electron radial transport
transpfaste.vparmin = 3.5;
%
dkeparam.rt_mode = 4;%Quasilinear iteration
dkeparam.invproc = -1;%MUMPS
%
p_opt = 2;%Printing or saving option of the figures
filename = id_simul;
%	    
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,[],waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
%	    
%************************************************************************************************************************************
%
I_tot = sum(Zcurr.x_0_fsav.*equilDKE.xdA_dke*mksa.j_ref);
figure('Name','Current profile'),
graph1D_jd(equilDKE.xrho,Zcurr.x_0_fsav*mksa.j_ref,0,0,'\rho','J_{tot} (MA/m^2)',['Tore Supra,I_{tot} = ',num2str(I_tot),' (MA)'],NaN,'','','-','none','r',2);drawnow
print_jd(p_opt,[filename,'_Curr']);
%
PLH_tot = sum(ZP0.x_rf_fsav.*equilDKE.xdV_2piRp_dke(:)*mksa.P_ref*2*pi*equilDKE.Rp);
figure('Name','LH Power'),
graph1D_jd(equilDKE.xrho,ZP0.x_rf_fsav*mksa.P_ref,0,0,'\rho','P_{LH} (MW/m^3)',['Tore Supra,P_{LH} = ',num2str(PLH_tot),' (MW)'],NaN,'','','-','none','r',2);drawnow
print_jd(p_opt,[filename,'_RF_Power']);
%
POHM_tot = sum(ZP0.x_e_fsav.*equilDKE.xdV_2piRp_dke*mksa.P_ref*2*pi*equilDKE.Rp);
figure('Name','Ohmic Power'),
graph1D_jd(equilDKE.xrho,ZP0.x_e_fsav*mksa.P_ref,0,0,'\rho','P_{OHM} (MW/m^3)',['Tore Supra,P_{OHM} = ',num2str(POHM_tot),' (MW)'],NaN,'','','-','none','r',2);drawnow
print_jd(p_opt,[filename,'_Ohm']);
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
%
