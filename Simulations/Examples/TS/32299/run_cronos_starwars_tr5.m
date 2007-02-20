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
id_simul = 'MIXTE_tr2.0_a0.05';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
load gigajoule_pouryves_luke.mat;%data file from cronos
%
p_opt = 2;%Printing or saving option of the figures
filename = id_simul;
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
if exist([path_path,'PATH_',id_path,'.mat']) == 0,%Paths
	error([path_path,'PATH_',id_path,'.mat does not exist']);
else
	eval(['load ',path_path,'PATH_',id_path,'.mat']);
	info_dke_yp(2,'Structure ''path'' successfully loaded');
    if ~strcmp(dkepath.computer,computer),error('The path structure is not consistent with the computer !'),end
    dkepath.temppath = [dkepath.temppathroot,filesep,timeid_jd(clock)];
end
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.05:0.05:0.6,0.7,0.8,0.9];;%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
wavestructs{1}.rayparam.tfinal = 10000;
wavestructs{2}.rayparam.tfinal = 10000;
%
wavestructs{1}.launch.bNpar0 = -wavestructs{1}.launch.bNpar0;%Co-current since both Bphi and Ip are counter-clockwise in TS
wavestructs{2}.launch.bNpar0 = -wavestructs{2}.launch.bNpar0;%Co-current since both Bphi and Ip are counter-clockwise in TS
%
equil.ptBPHI = -equil.ptBPHI;%Bphi is counter-clockwise in TS
equil.ptBx = -equil.ptBx;%Ip is counter-clockwise in TS
equil.ptBy = -equil.ptBy;%Ip is counter-clockwise in TS
equil.psi_apRp = -equil.psi_apRp;%Ip is counter-clockwise in TS
%
transpfaste.Dr0 = 2;%Fast electron radial transport
transpfaste.vparmin = 3.5;
%
dkeparam.rt_mode = 4;%Quasilinear iteration
dkeparam.invproc = -1;%MUMPS or (-30 PETSc)
dkeparam.PETScparam.nproc = 1;%number of processor used by PETSc (depends of the computer framework). Default is 1
dkeparam.PETScparam.matrixtype = '-matload_type superlu_dist';%Matrix type used by PETSc. For SUPERLU use '-matload_type superlu_dist' otherwise ' '. See PETSc documentation
dkeparam.PETScparam.kspmethod = '-ksp_type preonly';%KSP method used by PETSc. '-ksp_type preonly': no iteration, direct matrix solve. Otherwise '-ksp_type bicg' or '-ksp_type bcgs'  for example. See PETSc documentation
dkeparam.PETScparam.pcmethod = '-pc_type lu';%Preconditioning method used by PETSc. '-pc_type lu' for SUPERLU or '-pc-type hypre' for HYPRE.  See PETSc documentation
dkeparam.PETScparam.cloop = 1;%First order collision selfconsistency is done internaly in C (1) or in MatLab (0)
%
reloadrays = 1;%Reload or not ray trajectories
wavestructs{1}.raydisplay.p_opt = 2;%Save ray figures
wavestructs{2}.raydisplay.p_opt = 2;%Save ray figures
wavestructs{1}.a_sdNpar = 0.05;
wavestructs{2}.a_sdNpar = 0.05;
%
% ---------------------------------------------- Run LUKE + RT ----------------------------------------------
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = run_lukert(id_simul,wavestructs,psin_S,rho_S,dkepath,equil,dkeparam,display,ohm,transpfaste,ripple,[],[],reloadrays);
%	    
% ---------------------------------------------- Save results ----------------------------------------------
%
eval(['save ',path_simul,'DKE_RESULTS_',equil.id,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',equil.id,'_',id_simul,'.mat']);
%	    
% ---------------------------------------------- Graphic output ----------------------------------------------
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

