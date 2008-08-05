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
id_simul = 'LH_bounce_val';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%
id_path = '';%For all paths used by DKE solver
path_path = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_equil_cyl = 'TScyl';%For plasma equilibrium
id_equil = 'TScirc_e1';%For plasma equilibrium
path_equil = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
id_dkeparam = 'NONUNIFORM10010020';%For DKE code parameters
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
[equil_cyl] = load_structures_yp('equil',id_equil_cyl,path_equil);
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
dkeparam.prec0_f = 1e-15;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
iar_list = [0.1,0.2,0.3,0.5,0.8];
%
% RELATIVISTIC CASE
%
dkeparam.pnmax_S = 30;
dkeparam.np_S = 201;
%
wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
waves_cyl{1} = make_idealLHwave_jd(equil_cyl,wavestruct);
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
dkeparam.bounce_mode = 0;
dkeparam.nmhu_S = 201;
rho_S = 0.5;
%
[Znorm_rel_cyl,Zcurr_rel_cyl,ZP0_rel_cyl] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil_cyl,dkeparam,dkedisplay,ohm,waves_cyl,transpfaste,ripple,[],[]);
%
dkeparam.bounce_mode = 1;
dkeparam.nmhu_S = 174;
%
ap = equil.ptx(end,1);
rho_list = iar_list*equil.Rp/ap;
%
for irho = 1:length(rho_list),
    %
    rho_S = rho_list(irho);
    %
    [Znorm_rel,Zcurr_rel,ZP0_rel] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    j_rel(irho) = Zcurr_rel.x_0_vfsav;
    p_rel(irho) = ZP0_rel.x_rf_fsav.';
    %
end
%
% NON-RELATIVISTIC CASE
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
betath = 0.001;%validated for NR limit
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
equil_cyl.pTe = betath^2*mc2*ones(size(equil_cyl.pTe));
equil_cyl.pzTi = betath^2*mc2*ones(size(equil_cyl.pzTi));
%equil_cyl.pzTi = 1e-10*ones(size(equil_cyl.pzTi));
%
wavestruct.yvparmin_lh = [3];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [5];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
%
waves_cyl{1} = make_idealLHwave_jd(equil_cyl,wavestruct);
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
dkeparam.pnmax_S = 10;
dkeparam.nmhu_S = 201;
rho_S = 0.5;
%
dkeparam.bounce_mode = 0;
%
[Znorm_nr_cyl,Zcurr_nr_cyl,ZP0_nr_cyl] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil_cyl,dkeparam,dkedisplay,ohm,waves_cyl,transpfaste,ripple,[],[]);
%
dkeparam.bounce_mode = 1;
dkeparam.nmhu_S = 174;
%
for irho = 1:length(rho_list),
    %
    rho_S = rho_list(irho);
    %
    [Znorm_nr,Zcurr_nr,ZP0_nr] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    j_nr(irho) = Zcurr_nr.x_0_vfsav;
    p_nr(irho) = ZP0_nr.x_rf_fsav.';
    %
end
%
% j_r_k = '0.003732';
% p_r_k = '0.0001256';
% eta_r_k = '29.72';
% %
% j_nr_k = '0.07092';
% p_nr_k = '0.004294';
% eta_nr_k = '16.52';
%	    
j_rel_cyl = Zcurr_rel_cyl.x_0;
p_rel_cyl = ZP0_rel_cyl.x_rf_fsav.';
eta_rel_cyl = j_rel_cyl./p_rel_cyl;
%
% j_rel = Zcurr_rel.x_0_vfsav;
% p_rel = ZP0_rel.x_rf_fsav.';
eta_rel = j_rel./p_rel;
%
j_nr_cyl = Zcurr_nr_cyl.x_0;
p_nr_cyl = ZP0_nr_cyl.x_rf_fsav.';
eta_nr_cyl = j_nr_cyl./p_nr_cyl;
%
% j_nr = Zcurr_nr.x_0_vfsav;
% p_nr = ZP0_nr.x_rf_fsav.';
eta_nr = j_nr./p_nr;
%
%************************************************************************************************************************************
%
format
%
delete res_LH_bounce_val
%
diary res_LH_bounce_val
%
disp(['Case 1 (NR)'])
disp(['----------------------'])
disp(['--> eps = 0.0 : eta/eta_cyl = ',num2str(eta_nr_cyl)]) 
disp(['--> eps = 0.1 : eta/eta_cyl = ',num2str(eta_nr(1))]) 
disp(['--> eps = 0.2 : eta/eta_cyl = ',num2str(eta_nr(2))]) 
disp(['--> eps = 0.3 : eta/eta_cyl = ',num2str(eta_nr(3))]) 
disp(['--> eps = 0.5 : eta/eta_cyl = ',num2str(eta_nr(4))]) 
disp(['--> eps = 0.8 : eta/eta_cyl = ',num2str(eta_nr(5))]) 
%
%
disp(' ')
disp(['Case 2 (FR)'])
disp(['----------------------'])
disp(['--> eps = 0.0 : eta/eta_cyl = ',num2str(eta_rel_cyl)]) 
disp(['--> eps = 0.1 : eta/eta_cyl = ',num2str(eta_rel(1))]) 
disp(['--> eps = 0.2 : eta/eta_cyl = ',num2str(eta_rel(2))]) 
disp(['--> eps = 0.3 : eta/eta_cyl = ',num2str(eta_rel(3))]) 
disp(['--> eps = 0.5 : eta/eta_cyl = ',num2str(eta_rel(4))]) 
disp(['--> eps = 0.8 : eta/eta_cyl = ',num2str(eta_rel(5))]) 
%
diary off
%
%************************************************************************************************************************************
%
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
