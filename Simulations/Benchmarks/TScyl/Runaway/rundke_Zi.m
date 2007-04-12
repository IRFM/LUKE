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
id_simul = 'Runaway_Zi_nobounce';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [0.001];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl_lowTene';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020_coll0';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = 'OHM_p008_flat';%For Ohmic electric contribution
path_ohm = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
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
[dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display,'ohm',id_ohm,path_ohm,'waves',ids_wave,paths_wave,'transpfaste',id_transpfaste,path_transpfaste,'ripple',id_ripple,path_ripple);
%
%**************************************************************************
%**************************************************************************
%
%dkeparam.invproc = -2;
equil.zZi = [1,1,1,1];equil.pzni = species_dke_yp(equil.pne,ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 1
[Znorm,Zcurr,ZP0,dke_out_Z1,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,2];equil.pzni = species_dke_yp(equil.pne,2*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 2
[Znorm,Zcurr,ZP0,dke_out_Z2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,3];equil.pzni = species_dke_yp(equil.pne,3*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 3
[Znorm,Zcurr,ZP0,dke_out_Z3] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,4];equil.pzni = species_dke_yp(equil.pne,4*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 4
[Znorm,Zcurr,ZP0,dke_out_Z4] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,5];equil.pzni = species_dke_yp(equil.pne,5*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 5
[Znorm,Zcurr,ZP0,dke_out_Z5] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,6];equil.pzni = species_dke_yp(equil.pne,6*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 6
[Znorm,Zcurr,ZP0,dke_out_Z6] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,7];equil.pzni = species_dke_yp(equil.pne,7*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 7
[Znorm,Zcurr,ZP0,dke_out_Z7] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,8];equil.pzni = species_dke_yp(equil.pne,8*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 8
[Znorm,Zcurr,ZP0,dke_out_Z8] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,9];equil.pzni = species_dke_yp(equil.pne,9*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 9
[Znorm,Zcurr,ZP0,dke_out_Z9] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,10];equil.pzni = species_dke_yp(equil.pne,10*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 10
[Znorm,Zcurr,ZP0,dke_out_Z10] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
disp('-------------------------------------------------------------------------------------------------------------------');
disp('-------------------------------------------------------------------------------------------------------------------');
disp(['Runaway rate (Zeff = 1) : ',num2str(dke_out_Z1.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 2) : ',num2str(dke_out_Z2.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 3) : ',num2str(dke_out_Z3.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 4) : ',num2str(dke_out_Z4.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 5) : ',num2str(dke_out_Z5.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 6) : ',num2str(dke_out_Z6.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 7) : ',num2str(dke_out_Z7.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 8) : ',num2str(dke_out_Z8.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 9) : ',num2str(dke_out_Z9.XxRR_fsav(end,:))]);
disp(['Runaway rate (Zeff = 10) : ',num2str(dke_out_Z10.XxRR_fsav(end,:))]);
%
Z =[1:10];
RR = [dke_out_Z1.XxRR_fsav(end,:),dke_out_Z2.XxRR_fsav(end,:),dke_out_Z3.XxRR_fsav(end,:),dke_out_Z4.XxRR_fsav(end,:),dke_out_Z5.XxRR_fsav(end,:),dke_out_Z6.XxRR_fsav(end,:),dke_out_Z7.XxRR_fsav(end,:),dke_out_Z8.XxRR_fsav(end,:),dke_out_Z9.XxRR_fsav(end,:),dke_out_Z10.XxRR_fsav(end,:)];
Z_kulsrud =[1,2,3,10];
RR_kulsrud = [3.177,1.735,1.047,0.09]*1e-4;%Kulsrud (PRL, 31,11, (1972) 690
%
figure(1),clf,graph1D_jd(Z,RR,0,1,'Main ion charge (Z)','Runaway loss rate','',NaN,'','','-','non','r',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(Z_kulsrud,RR_kulsrud,0,1,'Main ion charge (Z)','Runaway loss rate','',NaN,'','','none','*','g',2,20,gca,0.85,0.7,0.5);hold on
graph1D_jd(1,3.177e-4,0,1,'Main ion charge (Z)','Runaway loss rate','',NaN,'','','none','+','b',2,20,gca,0.85,0.7,0.5);
legend('DKE','Kulsrud et al.','Kruskal-Bernstein');
savefig_dke_yp('runaway_Zi')
%
disp('-------------------------------------------------------------------------------------------------------------------');	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
