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
id_simul = 'LH_karney_transp_bounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.05:0.02:0.2,0.22:0.03:0.6,0.62:0.05:0.95];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'BOUNCE3D_MUMPS';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
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
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
% 
% Dpsipsi scan (0 -> 100 m2/s)
%
transpfaste.Dr0 = 0;
[Znorm0,Zcurr0,ZP0_0,dke_out0,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
disp('D=0 m2/s done');
transpfaste.Dr0 = 0.1;
[Znorm01,Zcurr01,ZP0_01,dke_out01] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
disp('D=0.1 m2/s done');
transpfaste.Dr0 = 0.2;
%[Znorm02,Zcurr02,ZP0_02,dke_out02] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=0.2 m2/s done');
%transpfaste.Dr0 = 0.5;
%[Znorm05,Zcurr05,ZP0_05,dke_out05] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=0.5 m2/s done');
transpfaste.Dr0 = 1;
[Znorm1,Zcurr1,ZP0_1,dke_out1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
disp('D=1 m2/s done');
%transpfaste.Dr0 = 2;
%[Znorm2,Zcurr2,ZP0_2,dke_out2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=2 m2/s done');
%transpfaste.Dr0 = 5;
%[Znorm5,Zcurr5,ZP0_5,dke_out5] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=5 m2/s done');
transpfaste.Dr0 = 10;
[Znorm10,Zcurr10,ZP0_10,dke_out10] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
disp('D=10 m2/s done');
transpfaste.Dr0= 20;
[Znorm20,Zcurr20,ZP0_20,dke_out20] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
disp('D=20 m2/s done');
%[Znorm50,Zcurr50,ZP0_50,dke_out50] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=50 m2/s done');
%[Znorm100,Zcurr100,ZP0_100,dke_out100] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=100 m2/s done');%	    
%
% Nprocessor scan for Dpsipsi = 10 m2/s (1-> 10)
%
transpfaste.Dr0 = 10;
%
if strcmp(computer,'GLNXA64'),%Test parallel processing performances (on the cluster only)
   dkeparam.invproc = -1;
%
   Znorm10_4 = Znorm10;%Calculations already done
   Zcurr10_4 = Zcurr10;
   ZP0_10_4 = ZP0_10;
   dke_out10_4 = dke_out10;
%
   dkeparam.MUMPSparam.nproc = 1;%Number of processors
   [Znorm10_1,Zcurr10_1,ZP0_10_1,dke_out10_1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 1 done');
   dkeparam.MUMPSparam.nproc = 2;%Number of processors
   [Znorm10_2,Zcurr10_2,ZP0_10_2,dke_out10_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nprocs = 2 done');
   dkeparam.MUMPSparam.nproc = 3;%Number of processors
   [Znorm10_3,Zcurr10_3,ZP0_10_3,dke_out10_3] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nprocs = 3 done');
   dkeparam.MUMPSparam.nproc = 5;%Number of processors
   [Znorm10_5,Zcurr10_5,ZP0_10_5,dke_out10_5] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 5 done');
   dkeparam.MUMPSparam.nproc = 6;%Number of processors
   [Znorm10_6,Zcurr10_6,ZP0_10_6,dke_out10_6] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 6 done');
   dkeparam.MUMPSparam.nproc = 7;%Number of processors
   [Znorm10_7,Zcurr10_7,ZP0_10_7,dke_out10_7] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 7 done');
   dkeparam.MUMPSparam.nproc = 8;%Number of processors
   [Znorm10_8,Zcurr10_8,ZP0_10_8,dke_out10_8] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 8 done');
   dkeparam.MUMPSparam.nproc = 9;%Number of processors
   [Znorm10_9,Zcurr10_9,ZP0_10_9,dke_out10_9] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 9 done');
   dkeparam.MUMPSparam.nproc = 10;%Number of processors
   [Znorm10_10,Zcurr10_10,ZP0_10_10,dke_out10_10] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 10 done');
  end  
%  
Dpsipsi=[0,0.1,1,10];
tCPU = [dke_out0.time_out,dke_out01.time_out,dke_out1.time_out,dke_out10.time_out];
tCPU1 = [dke_out10_1.time_out,dke_out10_2.time_out,dke_out10_3.time_out,dke_out10_4.time_out,dke_out10_5.time_out,dke_out10_6.time_out,dke_out10_7.time_out,dke_out10_8.time_out,dke_out10_9.time_out,dke_out10_10.time_out];
%
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
%
figure(1),clf,graph1D_jd(Dpsipsi,tCPU,1,0,'D_{\psi\psi} (m^{2}/s)','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','r',2,20,gca,1,0.6,0.6);
axis([0.1,10,0,300])
savefig_dke_yp('tCPU_Dpsipsi')
%
figure(2),clf,graph1D_jd([1:10],tCPU1,0,0,'Number of processors)','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2),', D_{\psi\psi}  = 10 (m^{2}/s)'],NaN,'','','-','none','r',2,20,gca,1,0.6,0.6);
axis([1,10,0,400])
savefig_dke_yp('tCPUDpsipsi10_Nproc')
%
figure(3),clf,graph1D_jd(equilDKE.xrho,Zcurr0.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','r',2,20,gca,1,0.6,0.6);hold on
graph1D_jd(equilDKE.xrho,Zcurr01.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','b',2,20,gca,1,0.6,0.6);hold on
%graph1D_jd(equilDKE.xrho,Zcurr02.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','g',1,20,gca,1,0.6,0.6);hold on
%graph1D_jd(equilDKE.xrho,Zcurr05.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','c',1,20,gca,1,0.6,0.6);hold on
graph1D_jd(equilDKE.xrho,Zcurr1.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','g',2,20,gca,1,0.6,0.6);hold on
%graph1D_jd(equilDKE.xrho,Zcurr2.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','k',1,20,gca,1,0.6,0.6);hold on
%graph1D_jd(equilDKE.xrho,Zcurr5.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','--','none','r',1,20,gca,1,0.6,0.6);hold on
graph1D_jd(equilDKE.xrho,Zcurr10.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','m',2,20,gca,1,0.6,0.6);hold on
graph1D_jd(equilDKE.xrho,Zcurr20.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','k',2,20,gca,1,0.6,0.6);hold on
graph1D_jd(equilDKE.xrho,besselj(0,2.4*equilDKE.xrho)*Zcurr20.x_tot_fsav(1),0,0,'\rho','current density',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','none','+','r',2,20,gca,1,0.6,0.6);
legend('D_{\psi\psi} = 0 (m^{2}/s)','D_{\psi\psi} = 0.1 (m^{2}/s)','D_{\psi\psi} = 1 (m^{2}/s)','D_{\psi\psi} = 10 (m^{2}/s)','D_{\psi\psi} = 20 (m^{2}/s)','J_{0}(2.4*\rho)')
savefig_dke_yp('Jprof_Dpsipsi')

%
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
