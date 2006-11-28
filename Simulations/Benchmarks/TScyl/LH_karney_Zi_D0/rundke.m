%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
clear mex
clear functions
close all
warning off
close all
global nfig
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_Zi_D0';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [0.001];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = 'PC_DRFC_YVES';%For all paths used by DKE solver
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
id_ohm = '';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
ids_wave = {'LH_karney_g'};%For RF waves contribution (put all the type of waves needed)
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
    path.temppath = [path.temppathroot,filesep,timeid_jd(clock)];
end
%
if exist([path_equil,'EQUIL_',id_equil,'.mat']) == 0,%Magnetic equilibrium
	info_dke_yp(2,[path_equil,'EQUIL_',id_equil,'.mat does not exist']);
	return
else
	eval(['load ',path_equil,'EQUIL_',id_equil,'.mat']);
	info_dke_yp(2,'Structure ''equil'' successfully loaded');
end
%
if exist([path_dkeparam,'DKEPARAM_',id_dkeparam,'.mat']) == 0,%DKE simulation parameters 
	info_dke_yp(2,[path_dkeparam,'DKEPARAM_',id_dkeparam,'.mat does not exist']);
	return
else
	eval(['load ',path_dkeparam,'DKEPARAM_',id_dkeparam,'.mat']);
	info_dke_yp(2,'Structure ''dkeparam'' successfully loaded');
end
%
if exist([path_display,'DISPLAY_',id_display,'.mat']) == 0,%DKE output display parameters
	info_dke_yp(2,[path_display,'DISPLAY_',id_display,'.mat does not exist']);
	return
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
%Study of the ion charge effect of the LHCD efficiency
%
%dkeparam.invproc = -1;
%dkeparam.np_S = 201;
%dkeparam.nmhu_S = 201;
dkeparam.opt_load = 0;
dkeparam.opt_save = 0;
%
equil.zZi = [1,1,1,1];equil.pzni = species_dke_yp(equil.pne,ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 1
[Znorm,Zcurr_Z1,ZP0_Z1,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,2];equil.pzni = species_dke_yp(equil.pne,2*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 2
[Znorm,Zcurr_Z2,ZP0_Z2,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,3];equil.pzni = species_dke_yp(equil.pne,3*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 3
[Znorm,Zcurr_Z3,ZP0_Z3,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,4];equil.pzni = species_dke_yp(equil.pne,4*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 4
[Znorm,Zcurr_Z4,ZP0_Z4,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,5];equil.pzni = species_dke_yp(equil.pne,5*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 5
[Znorm,Zcurr_Z5,ZP0_Z5,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,6];equil.pzni = species_dke_yp(equil.pne,6*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 6
[Znorm,Zcurr_Z6,ZP0_Z6,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,7];equil.pzni = species_dke_yp(equil.pne,7*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 7
[Znorm,Zcurr_Z7,ZP0_Z7,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,8];equil.pzni = species_dke_yp(equil.pne,8*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 8
[Znorm,Zcurr_Z8,ZP0_Z8,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,9];equil.pzni = species_dke_yp(equil.pne,9*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 9
[Znorm,Zcurr_Z9,ZP0_Z9,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,10];equil.pzni = species_dke_yp(equil.pne,10*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 10
[Znorm,Zcurr_Z10,ZP0_Z10,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%
Zi = [1:1:10];
jlh = [Zcurr_Z1.x_tot_fsav,Zcurr_Z2.x_tot_fsav,Zcurr_Z3.x_tot_fsav,Zcurr_Z4.x_tot_fsav,Zcurr_Z5.x_tot_fsav,Zcurr_Z6.x_tot_fsav,Zcurr_Z7.x_tot_fsav,Zcurr_Z8.x_tot_fsav,Zcurr_Z9.x_tot_fsav,Zcurr_Z10.x_tot_fsav];
plh = [ZP0_Z1.x_rf_fsav,ZP0_Z2.x_rf_fsav,ZP0_Z3.x_rf_fsav,ZP0_Z4.x_rf_fsav,ZP0_Z5.x_rf_fsav,ZP0_Z6.x_rf_fsav,ZP0_Z7.x_rf_fsav,ZP0_Z8.x_rf_fsav,ZP0_Z9.x_rf_fsav,ZP0_Z10.x_rf_fsav];
pcoll = -[ZP0_Z1.x_c_fsav,ZP0_Z2.x_c_fsav,ZP0_Z3.x_c_fsav,ZP0_Z4.x_c_fsav,ZP0_Z5.x_c_fsav,ZP0_Z6.x_c_fsav,ZP0_Z7.x_c_fsav,ZP0_Z8.x_c_fsav,ZP0_Z9.x_c_fsav,ZP0_Z10.x_c_fsav];
%
etalh = jlh./plh;
vparmin = 1/(waves{1}.rays{1}.sNpar(1)+imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
vparmax = 1/(waves{1}.rays{1}.sNpar(1)-imag(waves{1}.rays{1}.sdNpar(1))/2)/mksa.betath_ref;
etalh_th = 6*etalh(1)./(5+Zi);
%
figure(1),graph1D_jd(Zi,jlh,0,0,'Main ion charge','j_{LH}',['D_{|| ||LH} = ',num2str(1)],NaN,'','','-','non','r',2);
savefig_dke_yp('jLH_Zi')
%
figure(2),graph1D_jd(Zi,plh,0,0,'Main ion charge','p_{LH} and p_{coll}',['D_{|| ||LH} = ',num2str(1)],NaN,'','','-','non','r',2);hold on
graph1D_jd(Zi,pcoll,0,0,'Main ion charge','p_{LH} and p_{coll}','',NaN,'','','none','+','b',2);hold on
legend('LH power','Collision power')
savefig_dke_yp('PlhPcoll_Zi')
%
figure(3),graph1D_jd(Zi,etalh,0,0,'Main ion charge','LH CD efficiency \eta_{LH}',['D_{|| ||LH} = ',num2str(1)],NaN,'','','-','non','r',2);hold on
graph1D_jd(Zi,etalh_th,0,0,'Main ion charge','LH CD efficiency \eta_{LH}',[],NaN,'','','none','+','b',2);
legend('DKE code','4/(Z+5)')
axis([0,10,0,20])
savefig_dke_yp('effLH_Zi')
%
% Study of the D|| on the LHCD efficiency (Zeff = 1)
%
equil.zZi = [1,1,1,1];equil.pzni = species_dke_yp(equil.pne,ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 1
P0_2piRp_D1 = waves{1}.rays{1}.P0_2piRp;%for D|| = 1
%
waves{1}.rays{1}.P0_2piRp = 0.1*P0_2piRp_D1;%for D|| = 0.1
[Znorm,Zcurr_D01,ZP0_D01,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
waves{1}.rays{1}.P0_2piRp = 0.2*P0_2piRp_D1;%for D|| = 0.2
[Znorm,Zcurr_D02,ZP0_D02,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
waves{1}.rays{1}.P0_2piRp = 0.5*P0_2piRp_D1;%for D|| = 0.5
[Znorm,Zcurr_D05,ZP0_D05,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
waves{1}.rays{1}.P0_2piRp = P0_2piRp_D1;%for D|| = 1
[Znorm,Zcurr_D1,ZP0_D1,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
waves{1}.rays{1}.P0_2piRp = 2*P0_2piRp_D1;%for D|| = 2
[Znorm,Zcurr_D2,ZP0_D2,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
waves{1}.rays{1}.P0_2piRp = 5*P0_2piRp_D1;%for D|| = 5
[Znorm,Zcurr_D5,ZP0_D5,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
waves{1}.rays{1}.P0_2piRp = 10*P0_2piRp_D1;%for D|| = 10
[Znorm,Zcurr_D10,ZP0_D10,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
waves{1}.rays{1}.P0_2piRp = 20*P0_2piRp_D1;%for D|| = 20
[Znorm,Zcurr_D20,ZP0_D20,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,path,equil,dkeparam,display,ohm,waves,transpfaste,ripple,[],[]);
%
Dlh = [0.1,0.2,0.5,1,2,5,10,20];
jlh1 = [Zcurr_D01.x_tot_fsav,Zcurr_D02.x_tot_fsav,Zcurr_D05.x_tot_fsav,Zcurr_D1.x_tot_fsav,Zcurr_D2.x_tot_fsav,Zcurr_D5.x_tot_fsav,Zcurr_D10.x_tot_fsav,Zcurr_D20.x_tot_fsav];
plh1 = [ZP0_D01.x_rf_fsav,ZP0_D02.x_rf_fsav,ZP0_D05.x_rf_fsav,ZP0_D1.x_rf_fsav,ZP0_D2.x_rf_fsav,ZP0_D5.x_rf_fsav,ZP0_D10.x_rf_fsav,ZP0_D20.x_rf_fsav];
pcoll1 = -[ZP0_D01.x_c_fsav,ZP0_D02.x_c_fsav,ZP0_D05.x_c_fsav,ZP0_D1.x_c_fsav,ZP0_D2.x_c_fsav,ZP0_D5.x_c_fsav,ZP0_D10.x_c_fsav,ZP0_D20.x_c_fsav];
etalh1 = jlh1./plh1;
%
figure(4),graph1D_jd(Dlh,jlh1,0,0,'D_{|| ||LH}','j_{LH}',['Zi = ',num2str(1)],NaN,'','','-','non','r',2);
savefig_dke_yp('jLH_DLH')
%
figure(5),graph1D_jd(Dlh,plh1,0,0,'D_{|| ||LH}','p_{LH} and p_{coll}',['Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
graph1D_jd(Dlh,pcoll1,0,0,'D_{||LH}','p_{lh} and p_{coll}','',NaN,'','','none','+','b',2);hold on
legend('LH power','Collision power')
savefig_dke_yp('PLHPcoll_DLH')
%
figure(6),graph1D_jd(Dlh,etalh1,0,0,'D_{|| ||LH}','LH CD efficiency \eta_{LH}',['Zi = ',num2str(1)],NaN,'','','-','non','r',2);hold on
savefig_dke_yp('effLH_DLH')
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);