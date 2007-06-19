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
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil = 'TScyl';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'UNIFORM10010020';%For DKE code parameters
path_dkeparam = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_display = 'PARTIAL_VISUAL';%For output code display
path_display = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_ohm = 'OHM_p001_flat';%For Ohmic electric contribution
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
%************************************************************************************************************************************
%
%Case Zeff = 1 (in make_equil)
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
ir_display_out = 1;
%
dkeparam.coll_mode = 0;%Zeff = 1
[Znorm,Zcurr0,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa,XXsinksource] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
dkeparam.coll_mode = 1;
[Znorm,Zcurr1,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
dkeparam.coll_mode = 2;
[Znorm,Zcurr2,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
dkeparam.coll_mode = 4;
[Znorm,Zcurr4,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
sigma0 = Zcurr0.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
sigma1 = Zcurr1.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
sigma2 = Zcurr2.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
sigma4 = Zcurr4.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
%
dkeparam.coll_mode = 2;
equil.zZi = [1,1,1,2];equil.pzni = species_dke_yp(equil.pne,2*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 2
[Znorm,Zcurr_Z2,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,5];equil.pzni = species_dke_yp(equil.pne,5*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 5
[Znorm,Zcurr_Z5,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,10];equil.pzni = species_dke_yp(equil.pne,10*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 10
[Znorm,Zcurr_Z10,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
equil.zZi = [1,1,1,20];equil.pzni = species_dke_yp(equil.pne,20*ones(size(equil.pne)),equil.zZi,equil.fi);%for Zeff = 20
[Znorm,Zcurr_Z20,ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
sigma_Z1s = 1e9*(equil.pTe(1))^1.5/1.65/mksa.lnc_e_ref/abs(mksa.j_ref*1e6/mksa.Edreicer_ref);%Spitzer conductivity (from 'Tokamaks' by J. Wesson, Oxford Science Publication, 3rd Eds., 2004)
%
sigma_Z1 = sigma2;
sigma_Z2 = Zcurr_Z2.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
sigma_Z5 = Zcurr_Z5.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
sigma_Z10 = Zcurr_Z10.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
sigma_Z20 = Zcurr_Z20.x_tot_fsav/(ohm.epsi(ir_display_out)/mksa.Edreicer_ref);
%
disp('-------------------------------------------------------------------------------------------------------------------');
disp('-------------------------------------------------------------------------------------------------------------------');
disp(['Ohmic conductivity for the relativistic Maxwellian background collision operator : ',num2str(sigma0),', Karney = 3.773']);
disp(['Ohmic conductivity for the high velocity limit collision operator : ',num2str(sigma1),', Karney = 2.837']);
disp(['Ohmic conductivity for the linearized Belaiev-Budker collision operator : ',num2str(sigma2),', Karney = 7.429, Spitzer = ',num2str(sigma_Z1s)]);
disp(['Ohmic conductivity for the non-relativistic Maxwellian background collision operator : ',num2str(sigma4),', Karney = 3.773']);
%
disp('-------------------------------------------------------------------------------------------------------------------');
%
disp(['Ohmic conductivity from Spitzer formula (Zeff = 1) : ',num2str(sigma_Z1s)]);
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
%sigma_highvelocity = sqrt(2/pi)*16*(3*Zi_DKE+13)./(Zi_DKE+3)./(Zi_DKE+5)/3;
sigma_Lor = [sqrt(2/pi)*16/20];
Zi_Karney = [1,2,5,10];
sigma_Karney= [7.429,4.377,2.078,1.133];
Zi_Spitzer = 1;
sigma_Spitzer = sigma_Z1s;
%
figure(1),clf,graph1D_jd(Zi_DKE,sigma_DKE,0,0,'Main ion charge Z_{i}','','E_{||}/E_{Dreicer} = 0.001',NaN,'','','-','none','r',2,20,gca,1,0.6,0.6);hold on
graph1D_jd(Zi_Karney,sigma_Karney,0,0,'Main ion charge Z_{i}','Normalized conductivity \sigma','E_{||}/E_{Dreicer} = 0.001',NaN,'','','none','*','g',2,20,gca,1,0.6,0.6);hold on
%graph1D_jd(Zi_DKE,sigma_highvelocity,0,0,'Main ion charge Z_{i}','','E_{||}/E_{Dreicer} = 0.001',NaN,'','','none','o','b',2,20,gca,1,0.6,0.6);hold on
graph1D_jd(Zi_Spitzer,sigma_Spitzer,0,0,'Main ion charge Z_{i}','','E_{||}/E_{Dreicer} = 0.001',NaN,'','','none','x','b',2,20,gca,1,0.6,0.6);hold on
graph1D_jd(Zi_Lor,sigma_Lor,0,0,'Main ion charge Z_{i}','','E_{||}/E_{Dreicer} = 0.001',NaN,'','','none','+','b',2,20,gca,1,0.6,0.6);hold on
legend('LUKE (Linearized coll.)','Karney (Linearized coll.)','Spitzer Z = 1','Z_{i} = \infty (Lorentz model)')
savefig_dke_yp('conductivity_Zi')
%
disp('-------------------------------------------------------------------------------------------------------------------');	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
