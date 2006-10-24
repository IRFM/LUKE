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
[s,dossier,machine] = comput_dke_yp;
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_transp_nobounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.05:0.02:0.2,0.22:0.03:0.6,0.62:0.05:0.95];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc_flatprof_cyl';%For plasma equilibrium
path_equil = '../../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020_MUMPS';%For DKE code parameters
path_dkeparam = '../../../Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '../../../Database/DISPLAY_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '../../../Database/OHM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
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
if exist([path_path,'PATH_',id_path,'.mat']) == 0,%Paths
	info_dke_yp(2,[path_path,'PATH_',id_path,'.mat does not exist']);
	break
else
	eval(['load ',path_path,'PATH_',id_path,'.mat']);
	info_dke_yp(2,'Structure ''path'' successfully loaded');
    if ~strcmp(path.computer,computer),error('The path structure is not consistent with the computer !'),end
end
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	break
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
if exist([path_dkeparam,'DKEPARAM_',id_dkeparam,'.mat']) == 0,%DKE simulation parameters 
	info_dke_yp(2,[path_dkeparam,'DKEPARAM_',id_dkeparam,'.mat does not exist']);
	break
else
	eval(['load ',path_dkeparam,'DKEPARAM_',id_dkeparam,'.mat']);
	info_dke_yp(2,'Structure ''dkeparam'' successfully loaded');
end
%
if exist([path_display,'DISPLAY_',id_display,'.mat']) == 0,%DKE output display parameters
	info_dke_yp(2,[path_display,'DISPLAY_',id_display,'.mat does not exist']);
	break
else
	eval(['load ',path_display,'DISPLAY_',id_display,'.mat']);
	info_dke_yp(2,'Structure ''display'' successfully loaded');
end
%
if exist([path_ohm,'OHM_',id_equil,'_',id_ohm,'.mat']) == 0,%Ohmic electric field 
	info_dke_yp(2,['Simulations are performed without Ohmic Efield']);
	ohm = '';
else
	eval(['load ',path_ohm,'OHM_',id_equil,'_',id_ohm,'.mat']);
	info_dke_yp(2,['Structure ''ohm'' ',id_ohm,' successfully loaded']);
end
%
ii=1;
waves = '';%List of structure for multiple RF waves
for iw = 1:length(ids_wave),
	if exist([paths_wave{iw},'WAVE_',id_equil,'_',ids_wave{iw},'.mat']) == 0,%RF waves
		info_dke_yp(2,['Simulations are performed without the RF wave number: ',int2str(iw)]);
	else
		eval(['load ',paths_wave{iw},'WAVE_',id_equil,'_',ids_wave{iw},'.mat']);
		info_dke_yp(2,['Structure ''wave'' ',ids_wave{iw},' successfully loaded']);
		waves{ii} = wave;
		clear wave
		ii = ii + 1;
	end
end
%
if exist([path_transpfaste,'TRANSP_',id_transpfaste,'.mat']) == 0,%Fast electron radial transport 
	info_dke_yp(2,'Simulations are performed without fast electron radial transport');
	transpfaste = '';
else
	eval(['load ',path_transpfaste,'TRANSP_',id_transpfaste,'.mat']);
	info_dke_yp(2,'Structure ''transpfaste'' successfully loaded');
end
%
if exist([path_ripple,'RIPPLE_',id_ripple,'.mat']) == 0,%Magnetic ripple losses
	info_dke_yp(2,'Simulations are performed without fast electron magnetic ripple losses');
	ripple = '';
else
	eval(['load ',path_ripple,'RIPPLE_',id_ripple,'.mat']);
	info_dke_yp(2,'Structure ''ripple'' successfully loaded');
end
%
%************************************************************************************************************************************
%
dkeparam.MUMPSparam.nproc = 4;%Number of processors
dkeparam.opt_load = 0;
dkeparam.opt_save = 0;
% 
% Dpsipsi scan (0 -> 100 m2/s
%
transpfaste.Dr_model = 0;
transpfaste.vparmin = 2.8;
%
transpfaste.Dr0 = 0;
[Znorm0,Zcurr0,ZP0_0,dke_out0,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=0 m2/s done');
transpfaste.Dr0 = 0.1;
[Znorm01,Zcurr01,ZP0_01,dke_out01,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=0.1 m2/s done');
transpfaste.Dr0 = 0.2;
%[Znorm02,Zcurr02,ZP0_02,dke_out02,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=0.2 m2/s done');
%transpfaste.Dr0 = 0.5;
%[Znorm05,Zcurr05,ZP0_05,dke_out05,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=0.5 m2/s done');
transpfaste.Dr0 = 1;
[Znorm1,Zcurr1,ZP0_1,dke_out1,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=1 m2/s done');
%transpfaste.Dr0 = 2;
%[Znorm2,Zcurr2,ZP0_2,dke_out2,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=2 m2/s done');
%transpfaste.Dr0 = 5;
%[Znorm5,Zcurr5,ZP0_5,dke_out5,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=5 m2/s done');
transpfaste.Dr0 = 10;
[Znorm10,Zcurr10,ZP0_10,dke_out10,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=10 m2/s done');
transpfaste.Dr0= 20;
[Znorm20,Zcurr20,ZP0_20,dke_out20,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
disp('D=20 m2/s done');
%[Znorm50,Zcurr50,ZP0_50,dke_out50,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=50 m2/s done');
%[Znorm100,Zcurr100,ZP0_100,dke_out100,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%disp('D=100 m2/s done');%	    
%
% Nprocessor scan for Dpsipsi = 10 m2/s (1-> 10)
%
transpfaste.Dr0 = 10;
%
if strcmp(computer,'GLNXA64'),
   Znorm10_4 = Znorm10;%Calculations already done
   Zcurr10_4 = Zcurr10;
   ZP0_10_4 = ZP0_10;
   dke_out10_4 = dke_out10;
%
   dkeparam.MUMPSparam.nproc = 1;%Number of processors
   [Znorm10_1,Zcurr10_1,ZP0_10_1,dke_out10_1,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 1 done');
   dkeparam.MUMPSparam.nproc = 2;%Number of processors
   [Znorm10_2,Zcurr10_2,ZP0_10_2,dke_out10_2,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nprocs = 2 done');
   dkeparam.MUMPSparam.nproc = 3;%Number of processors
   [Znorm10_3,Zcurr10_3,ZP0_10_3,dke_out10_3,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nprocs = 3 done');
   dkeparam.MUMPSparam.nproc = 5;%Number of processors
   [Znorm10_5,Zcurr10_5,ZP0_10_5,dke_out10_5,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 5 done');
   dkeparam.MUMPSparam.nproc = 6;%Number of processors
   [Znorm10_6,Zcurr10_6,ZP0_10_6,dke_out10_6,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 6 done');
   dkeparam.MUMPSparam.nproc = 7;%Number of processors
   [Znorm10_7,Zcurr10_7,ZP0_10_7,dke_out10_7,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 7 done');
   dkeparam.MUMPSparam.nproc = 8;%Number of processors
   [Znorm10_8,Zcurr10_8,ZP0_10_8,dke_out10_8,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 8 done');
   dkeparam.MUMPSparam.nproc = 9;%Number of processors
   [Znorm10_9,Zcurr10_9,ZP0_10_9,dke_out10_9,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
   disp('Nproc = 9 done');
   dkeparam.MUMPSparam.nproc = 10;%Number of processors
   [Znorm10_10,Zcurr10_10,ZP0_10_10,dke_out10_10,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
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
figure(1),graph1D_jd(Dpsipsi,tCPU,1,0,'D_{\psi\psi} (m^{2}/s)','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','r',2);
axis([0.1,10,0,300])
savefig_dke_yp('tCPU_Dpsipsi')
%
figure(2),graph1D_jd([1:10],tCPU1,0,0,'Number of processors)','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2),', D_{\psi\psi}  = 10 (m^{2}/s)'],NaN,'','','-','none','r',2);
axis([1,10,0,400])
savefig_dke_yp('tCPUDpsipsi10_Nproc')
%
figure(3),graph1D_jd(gridDKE.xrho,Zcurr0.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','r',2);hold on
graph1D_jd(gridDKE.xrho,Zcurr01.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','b',2);hold on
%graph1D_jd(gridDKE.xrho,Zcurr02.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','g',1);hold on
%graph1D_jd(gridDKE.xrho,Zcurr05.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','c',1);hold on
graph1D_jd(gridDKE.xrho,Zcurr1.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','g',2);hold on
%graph1D_jd(gridDKE.xrho,Zcurr2.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','k',1);hold on
%graph1D_jd(gridDKE.xrho,Zcurr5.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','--','none','r',1);hold on
graph1D_jd(gridDKE.xrho,Zcurr10.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','m',2);hold on
graph1D_jd(gridDKE.xrho,Zcurr20.x_tot_fsav,0,0,'\rho','CPU time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','-','none','k',2);hold on
graph1D_jd(gridDKE.xrho,besselj(0,2.4*gridDKE.xrho)*Zcurr20.x_tot_fsav(1),0,0,'\rho','current density',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(2)],NaN,'','','none','+','r',2);
legend('D_{\psi\psi} = 0 (m^{2}/s)','D_{\psi\psi} = 0.1 (m^{2}/s)','D_{\psi\psi} = 1 (m^{2}/s)','D_{\psi\psi} = 10 (m^{2}/s)','D_{\psi\psi} = 20 (m^{2}/s)','J_{0}(2.4*\rho)')
savefig_dke_yp('Jprof_Dpsipsi')
%
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);


