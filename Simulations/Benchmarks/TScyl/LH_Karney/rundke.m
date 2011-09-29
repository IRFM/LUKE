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
id_simul = 'LH_karney_test';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0.5];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
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
id_ohm = '';%For Ohmic electric contribution
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
wavestruct.omega_lh = [4]*2*pi*1e9; %(GHz -> rad/s). Wave frequency [1,1] Indicative, no effect in small FLR limit opt_lh > 0
%Option parameter for cross-comparison between old LH code: 
%	- (1): 1/vpar dependence
%	- (2): no 1/vpar dependence and old grid technique for Dlh calculations (Karney, Shoucri) (see rfdiff_dke_jd)
wavestruct.opt_lh = 2; % [1,1]
%
% Choose (vparmin_lh,vparmax_lh) or (Nparmin_lh,Nparmax_lh) for square n// LH wave power spectrum,
% or (Npar_lh,dNpar_lh) for Gaussian shape
%
wavestruct.norm_ref = 1;%Normalization procedure for the LH quasilinear diffusion coefficient and spectrum boundaries
%
wavestruct.yNparmin_lh = [NaN];%LH wave square N// Spectrum: Lower limit [1,n_scenario_lh]
wavestruct.yNparmax_lh = [NaN];%LH wave square N// Spectrum: Upper limit [1,n_scenario_lh]
wavestruct.yNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: peak [1,n_scenario_lh]
wavestruct.ydNpar_lh = [NaN];%LH wave Gaussian N// Spectrum: width [1,n_scenario_lh]
%
%   Note: this diffusion coefficient is different from the general QL D0. It has a benchmarking purpose only 
wavestruct.yD0_in_c_lh = [1];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
wavestruct.yD0_in_lh_prof = [0];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
wavestruct.ypeak_lh = [NaN];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
wavestruct.ywidth_lh = [NaN];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
%
wavestruct.ythetab_lh = [0]*pi/180;%(deg -> rad). Poloidal location of LH beam [0..2pi] [1,n_scenario_lh]
%               (0) from local values Te and ne, (1) from central values Te0 and ne0 
%
%************************************************************************************************************************************
%
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.tn = [50000,100000];% 2 time steps to tn=100000 best for asymptotic solution
%
%dkeparam.prec0_f = 1e-11;%to retrieve early LUKE 1.9.0 results
%dkeparam.tn = 10000;%to retrieve early LUKE 1.9.0 results
%dkeparam.dtn = 10000;%to retrieve early LUKE 1.9.0 results
%
% RELATIVISTIC CASE
%
dkeparam.pnmax_S = 30;
%
wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
[Znorm_rel,Zcurr_rel,ZP0_rel] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
% NON-RELATIVISTIC CASE
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
betath = 0.001;%validated for NR limit
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%
wavestruct.yvparmin_lh = [3];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [5];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
dkeparam.coll_mode = 0;%For comparison with theoretical results
%
dkeparam.nmhu_S = 101;
dkeparam.np_S = 101;
dkeparam.pnmax_S = 10;
%
[Znorm_nr_0_10,Zcurr_0_10,ZP0_0_10] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
dkeparam.nmhu_S = 201;
dkeparam.np_S = 201;
dkeparam.pnmax_S = 20;
%
[Znorm_nr_0_20,Zcurr_0_20,ZP0_0_20] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
dkeparam.coll_mode = 2;%For comparison with theoretical results
%
[Znorm_nr_2_20,Zcurr_2_20,ZP0_2_20] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
%
j_r_k = '0.003732';
p_r_k = '0.0001256';
eta_r_k = '29.72';
%
j_nr_0_10_k = '0.05754';
p_nr_0_10_k = '0.004011';
eta_nr_0_10_k = '14.34';
%
j_nr_0_20_k = '0.05759';
p_nr_0_20_k = '0.004012';
eta_nr_0_20_k = '14.35';
%
j_nr_2_20_k = '0.07092';
p_nr_2_20_k = '0.004294';
eta_nr_2_20_k = '16.52';
%
%************************************************************************************************************************************
%
format
%
delete res_karney
%
diary res_karney
%
disp(['Comparison LUKE/Karney with tn = ',int2str(dkeparam.tn),', dtn = ',int2str(dkeparam.dtn),' and nit_f = ',int2str(dkeparam.nit_f)])
disp(['----------------------'])
%
disp(['Relativistic case (4,7,1) : j = ',num2str(Zcurr_rel.x_0),'/',j_r_k,' ; P = ',num2str(ZP0_rel.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(Zcurr_rel.x_0./ZP0_rel.x_rf_fsav),'/',eta_r_k]) 
disp(['Non Relativistic case (3,5,1) pmax = 10, coll_mode = 0 : j = ',num2str(Zcurr_0_10.x_0),'/',j_nr_0_10_k,' ; P = ',num2str(ZP0_0_10.x_rf_fsav),'/',p_nr_0_10_k,' ; j/P = ',num2str(Zcurr_0_10.x_0./ZP0_0_10.x_rf_fsav),'/',eta_nr_0_10_k]) 
disp(['Non Relativistic case (3,5,1) pmax = 20, coll_mode = 0 : j = ',num2str(Zcurr_0_20.x_0),'/',j_nr_0_20_k,' ; P = ',num2str(ZP0_0_20.x_rf_fsav),'/',p_nr_0_20_k,' ; j/P = ',num2str(Zcurr_0_20.x_0./ZP0_0_20.x_rf_fsav),'/',eta_nr_0_20_k]) 
disp(['Non Relativistic case (3,5,1) pmax = 20, coll_mode = 2 : j = ',num2str(Zcurr_2_20.x_0),'/',j_nr_2_20_k,' ; P = ',num2str(ZP0_2_20.x_rf_fsav),'/',p_nr_2_20_k,' ; j/P = ',num2str(Zcurr_2_20.x_0./ZP0_2_20.x_rf_fsav),'/',eta_nr_2_20_k]) 
%
diary off
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'LUKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
