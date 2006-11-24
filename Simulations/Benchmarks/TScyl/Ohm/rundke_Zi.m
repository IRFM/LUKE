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
id_simul = 'ohm_nobounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [0.001];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'LAPTOP_YVES';%For all paths used by DKE solver
path_path = '../../../Database/PATH_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '../../../Database/EQUIL_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '../../../Database/DKEPARAM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '../../../Database/DISPLAY_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = 'OHM_p001_flat';%For Ohmic electric contribution
path_ohm = '../../../Database/OHM_files/';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {''};%For RF waves contribution (put all the type of waves needed)
paths_wave = {''};%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
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
		ii = ii + 1;
		clear wave
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
%Case Zeff = 1 (in make_equil)
%
dkeparam.opt_load = 0;
dkeparam.opt_save = 0;
%
dkeparam.coll_mode = 0;
[Znorm,Zcurr0,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
dkeparam.coll_mode = 1;
[Znorm,Zcurr1,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
dkeparam.coll_mode = 2;
[Znorm,Zcurr2,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
dkeparam.coll_mode = 4;
[Znorm,Zcurr4,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%
sigma0 = Zcurr0.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
sigma1 = Zcurr1.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
sigma2 = Zcurr2.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
sigma4 = Zcurr4.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
%
dkeparam.coll_mode = 2;
equil.zZi = [1,1,1,2];equil.pzni = species_dke_yp(equil.pne,2*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 2
[Znorm,Zcurr_Z2,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,5];equil.pzni = species_dke_yp(equil.pne,5*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 5
[Znorm,Zcurr_Z5,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,10];equil.pzni = species_dke_yp(equil.pne,10*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 10
[Znorm,Zcurr_Z10,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,20];equil.pzni = species_dke_yp(equil.pne,20*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 20
[Znorm,Zcurr_Z20,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%
sigma_Z1 = sigma2;
sigma_Z2 = Zcurr_Z2.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
sigma_Z5 = Zcurr_Z5.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
sigma_Z10 = Zcurr_Z10.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
sigma_Z20 = Zcurr_Z20.x_tot_fsav/(ohm.epsi(gridDKE.ir_display_out)/mksa.Edreicer_ref);
%
disp('-------------------------------------------------------------------------------------------------------------------');
disp('-------------------------------------------------------------------------------------------------------------------');
disp(['Ohmic conductivity for the relativistic Maxwellian background collision operator : ',num2str(sigma0),', Karney = 3.773']);
disp(['Ohmic conductivity for the high velocity limit collision operator : ',num2str(sigma1),', Karney = 2.837']);
disp(['Ohmic conductivity for the linearized Belaiev-Budker collision operator : ',num2str(sigma2),', Karney = 7.429']);
disp(['Ohmic conductivity for the non-relativistic Maxwellian background collision operator : ',num2str(sigma4),', Karney = 3.773']);
%
disp('-------------------------------------------------------------------------------------------------------------------');
%
disp(['Ohmic conductivity for the linearized Belaiev-Budker collision operator (Zeff = 1) : ',num2str(sigma_Z1)]);
disp(['Ohmic conductivity for the linearized Belaiev-Budker collision operator (Zeff = 2) : ',num2str(sigma_Z2)]);
disp(['Ohmic conductivity for the linearized Belaiev-Budker collision operator (Zeff = 5): ',num2str(sigma_Z5)]);
disp(['Ohmic conductivity for the linearized Belaiev-Budker collision operator (Zeff = 10) : ',num2str(sigma_Z10)]);
disp(['Ohmic conductivity for the linearized Belaiev-Budker collision operator (Zeff = 20) : ',num2str(sigma_Z20)]);
disp(['Approximate analytical Ohmic conductivity for the non-relativistic Lorentz collision operator (Zeff = 20): ',num2str(12.766/20)]);
%
Zi_DKE = [1,2,5,10,20];
Zi_Lor = [20];
sigma_DKE = [sigma_Z1,sigma_Z2,sigma_Z5,sigma_Z10,sigma_Z20];
sigma_Lor = [12.766/20];
Zi_Karney = [1,2,5,10];
sigma_Karney= [7.429,4.377,2.078,1.133];
%
figure(1),graph1D_jd(Zi_DKE,sigma_DKE,0,0,'Main ion charge Z_{i}','','E_{||}/E_{Dreicer} = 0.001',NaN,'','','-','none','r',2);hold on
graph1D_jd(Zi_Karney,sigma_Karney,0,0,'Main ion charge Z_{i}','Normalized conductivity \sigma','E_{||}/E_{Dreicer} = 0.001',NaN,'','','none','*','g',2);hold on
graph1D_jd(Zi_Lor,sigma_Lor,0,0,'Main ion charge Z_{i}','','E_{||}/E_{Dreicer} = 0.001',NaN,'','','none','+','b',2);hold on
legend('DKE','Karney','Z_{i} = \infty')
savefig_dke_yp('conductivity_Zi')
%
disp('-------------------------------------------------------------------------------------------------------------------');	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
