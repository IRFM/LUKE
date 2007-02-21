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
id_simul = 'LH_karney_transp_bounce_JETh77';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.05:0.02:0.2,0.22:0.03:0.6,0.62:0.05:0.95];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'JETh77';%For plasma equilibrium
path_equil = '../../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'BOUNCE3D_MUMPS';%For DKE code parameters
path_dkeparam = '../../../Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '../../../Database/DISPLAY_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney_offaxis_2'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'../../../Database/WAVE_files/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = 'nomagneticturbulence';%For fast electron radial transport
path_transpfaste = '../../../Database/TRANSP_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = '';%For fast electron magnetic ripple losses
path_ripple = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'display',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%************************************************************************************************************************************
%
dkeparam.MUMPSparam.nproc = 4;%Number of processors
dkeparam.opt_load = 0;
dkeparam.opt_save = 0;
%
equil.pTe = equil.pTe(1) + equil.pTe*0;%Uniform profile enforced for comparison with TScirc case
equil.pne = equil.pne(1) + equil.pne*0;%Uniform profile enforced for comparison with TScirc case
equil.pzni(1,:) = equil.pzni(1,1) + equil.pzni(1,:)*0;%Uniform profile enforced for comparison with TScirc case
equil.pzni(2,:) = equil.pzni(2,1) + equil.pzni(2,:)*0;%Uniform profile enforced for comparison with TScirc case
equil.pzni(3,:) = equil.pzni(3,1) + equil.pzni(3,:)*0;%Uniform profile enforced for comparison with TScirc case
equil.pzni(4,:) = equil.pzni(4,1) + equil.pzni(4,:)*0;%Uniform profile enforced for comparison with TScirc case
equil.pzTi(1,:) = equil.pzTi(1,1) + equil.pzTi(1,:)*0;%Uniform profile enforced for comparison with TScirc case
equil.pzTi(2,:) = equil.pzTi(2,1) + equil.pzTi(2,:)*0;%Uniform profile enforced for comparison with TScirc case
equil.pzTi(3,:) = equil.pzTi(3,1) + equil.pzTi(3,:)*0;%Uniform profile enforced for comparison with TScirc case
equil.pzTi(4,:) = equil.pzTi(4,1) + equil.pzTi(4,:)*0;%Uniform profile enforced for comparison with TScirc case
% 
transpfaste.Dr0 = 0;
[Znorm0,Zcurr0,ZP0_0,dke_out0,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=0 m2/s done');
transpfaste.Dr0 = 0.1;
[Znorm01,Zcurr01,ZP0_01,dke_out01] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=0.1 m2/s done');
transpfaste.Dr0 = 1;
[Znorm1,Zcurr1,ZP0_1,dke_out1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=1 m2/s done');
transpfaste.Dr0 = 10;
[Znorm10,Zcurr10,ZP0_10,dke_out10] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=10 m2/s done');
%
vparmin = round(1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref);
vparmax = round(1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref);
%
figure(1),graph1D_jd(gridDKE.xrho,Zcurr0.x_tot_fsav,0,0,'','','',NaN,'','','-','none','r',2);hold on
graph1D_jd(gridDKE.xrho,Zcurr01.x_tot_fsav,0,0,'','','',NaN,'','','-','none','m',1);hold on
graph1D_jd(gridDKE.xrho,Zcurr1.x_tot_fsav,0,0,'','','',NaN,'','','-','none','m',1);hold on
graph1D_jd(gridDKE.xrho,Zcurr10.x_tot_fsav,0,0,'\rho','J_{LH}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','--','none','b',1);hold on
legend('D_{\psi\psi} = 0 (m^{2}/s)','D_{\psi\psi} = 0.1 (m^{2}/s)','D_{\psi\psi} = 1 (m^{2}/s)','D_{\psi\psi} = 10 (m^{2}/s)')
savefig_dke_yp('profcurr_Dpsipsi')
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
%
proc_rundke_yp(1,'DKE_RESULTS_JETh77_LH_karney_transp_bounce_JETh77.mat',1,1)
proc_rundke_yp(1,'DKE_RESULTS_JETh77_LH_karney_transp_bounce_JETh77.mat',14,1)
proc_rundke_yp(1,'DKE_RESULTS_JETh77_LH_karney_transp_bounce_JETh77.mat',24,1)
