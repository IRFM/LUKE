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
id_simul = 'LH_karney_3D_num';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc';%For plasma equilibrium
path_equil = '../../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '../../../Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'NO_DISPLAY';%For output code display
path_display = '../../../Database/DISPLAY_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'../../../Database/WAVE_files/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
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
nit = 6;
dludroptol = logspace(-6,-2,nit);
%
dkeparam.invproc = 1;%CGS  
dkeparam.mlprecinv = 1-4;
dkeparam.mlmaxitinv = 4;
%
dmesh = 5;
nmesh = 6;
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   for i = 1:nit,%droptolerance scan       
      dkeparam.ludroptol = dludroptol(i);
      [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
% 
      memory_f(i,j) = dke_out.memoryLU_f_out;
      time_f(i,j) = dke_out.time_out;
      norm_f{i,j} = Znorm.x_0_fsav.*mksa.ne_ref;
      curr_f{i,j} = Zcurr.x_0_fsav.*mksa.j_ref;
      Prf_f{i,j} = ZP0.x_rf_fsav.*mksa.P_ref;
      Pcoll_f{i,j} = ZP0.x_c_fsav.*mksa.P_ref;
%
      disp(['Incomplete LU calculation #',int2str(i),' with radial mesh size #',int2str(j*dmesh),'  done'])
    end
end
%
dkeparam.invproc = -1;%MUMPS
%
for j = 1:nmesh,%Scan radial mesh size
   rho_S = linspace(0,1,j*dmesh);
   [Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
% 
   time_f_MUMPS(j) = dke_out.time_out;
   norm_f_MUMPS{j} = Znorm.x_0_fsav.*mksa.ne_ref;
   curr_f_MUMPS{j} = Zcurr.x_0_fsav.*mksa.j_ref;
   Prf_f_MUMPS{j} = ZP0.x_rf_fsav.*mksa.P_ref;
   Pcoll_f_MUMPS{j} = ZP0.x_c_fsav.*mksa.P_ref;
%
   disp(['Direct MUMPS calculation done with radial mesh size #',int2str(j*dmesh),'  done'])
end
%
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
%
figure(1),graph1D_jd(dludroptol,time_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',2);hold on
graph1D_jd(dludroptol,time_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',2);hold on
graph1D_jd(dludroptol,time_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',2);
graph1D_jd(dludroptol,time_f(:,4),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',1);
graph1D_jd(dludroptol,time_f(:,5),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',1);
graph1D_jd(dludroptol,time_f(:,6),1,0,'Drop tolerance parameter \delta_{LU}','Full computational time (s)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',1);
legend('n_{\psi} = 4','n_{\psi} = 9','n_{\psi} = 14','n_{\psi} = 19','n_{\psi} = 24','n_{\psi} = 29')
savefig_dke_yp('timeludroptol')
%
figure(2),graph1D_jd(dludroptol,memory_f(:,1),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',2);hold on
graph1D_jd(dludroptol,memory_f(:,2),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',2);hold on
graph1D_jd(dludroptol,memory_f(:,3),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',2);
graph1D_jd(dludroptol,memory_f(:,4),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-','none','r',1);
graph1D_jd(dludroptol,memory_f(:,5),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','--','none','b',1);
graph1D_jd(dludroptol,memory_f(:,6),1,0,'Drop tolerance parameter \delta_{LU}','LU matrix size (MBytes)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{|| ||LH} = ',num2str(1), ', D_{\psi\psi} = 0 '],NaN,'','','-.','none','g',1);
legend('n_{\psi} = 4','n_{\psi} = 9','n_{\psi} = 14','n_{\psi} = 19','n_{\psi} = 24','n_{\psi} = 29')
savefig_dke_yp('memoryludroptol')
%
disp('-------------------')
disp('Incomplete LU preconditionning, CGS iterative Krylov algorithm, npsi = 30')
disp(['droptolerance: ',num2str(dludroptol(end-1)),' - Full CPU time: ',num2str(time_f(end-1,6)),' (s) - LU memory size: ',num2str(memory_f(end-1,6)),' (MBytes)'])
disp(['ne(0): ',num2str(round(norm_f{end-1,6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f{end-1,6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f{end-1,6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f{end-1,6}(1)),' (MW/m3)'])
disp('-------------------')
disp('Direct matrix inversion MUMPS, npsi = 30')
disp(['droptolerance: ',num2str(0),' - Full CPU time: ',num2str(time_f_MUMPS(6)),' (s)'])
disp(['ne(0): ',num2str(round(norm_f_MUMPS{6}(1)/1e+16)/1e3),' (10+19 m-3) - Jlh(0): ',num2str(abs(curr_f_MUMPS{6}(1))),' (MA/m2) - Plh(0): ',num2str(Prf_f_MUMPS{6}(1)),' (MW/m3) - Pcoll(0): ',num2str(-Pcoll_f_MUMPS{6}(1)),' (MW/m3)'])
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);