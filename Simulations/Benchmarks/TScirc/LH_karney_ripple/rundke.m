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
id_simul = 'LH_karney_ripple';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [linspace(0.1,0.3,3),linspace(0.35,0.65,12),linspace(0.7,0.9,3)];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScirc_peak';%For plasma equilibrium
path_equil = '../../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'BOUNCE3D_MUMPS';%For DKE code parameters
path_dkeparam = '../../../Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '../../../Database/DISPLAY_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney_uniform'};%For RF waves contribution (put all the type of waves needed)
paths_wave = {'../../../Database/WAVE_files/'};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_transpfaste = '';%For fast electron radial transport
path_transpfaste = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ripple = 'TScirc';%For fast electron magnetic ripple losses
path_ripple = '../../../Database/RIPPLE_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
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
dkeparam.nmhu_S = 151;
dkeparam.np_S = 151;
dkeparam.opt_load = 0;
dkeparam.opt_save = 0;
%
[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
%
figure(1),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,dke_out.xMRR_flux,0,0,'','','',NaN,'','','-','non','r',2);
graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,dke_out.xMRR_tau,0,0,'R(m)','Magnetic ripple loss rate',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','--','non','b',2);hold on
legend('Flux calculations','\tau calculations')
savefig_dke_yp(['ripplelossrate'])
%
figure(2),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,ZP0.x_rf_fsav,0,0,'R(m)','P_{lh}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,-ZP0.x_c_fsav,0,0,'R(m)','P_{lh}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','b',1);
legend('P_{lh}','P_{coll}')
savefig_dke_yp(['powerdensity'])
%
figure(3),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,Zmripple.xthetabanana,0,0,'R(m)','Angle (deg.)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,Zmripple.xthetaloss,0,0,'R(m)','Angle (deg.)',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','--','non','b',2);
legend('Banana cone angle','Loss cone angle')
savefig_dke_yp(['losscone'])
%
figure(4),graph1D_jd(gridDKE.xrho*equilDKE.ap+equilDKE.Rp,Zmripple.xpndetrap,0,0,'R(m)','Magnetic ripple p_{detrap}/p_{th-ref}',['v_{||min} = ',num2str(vparmin),', v_{||max} = ',num2str(vparmax),num2str(vparmax),', D_{||lh} = ',num2str(1),', Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
savefig_dke_yp(['detrap'])
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
%
proc_rundke_yp(4,'DKE_RESULTS_TScirc_peak_LH_karney_ripple.mat',10,1);% 


