%Script for running the DKE solver (can be modified by the user for specific simulations)
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clc
close all
clear all
clear mex
clear functions
warning off
global nfig
%
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_remote';%Simulation ID
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
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
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
dkeparam.rt_mode = 1;% necessary to use run_lukert
%
% Distributed compting options on the remote computer (or cluster)
% Syntax 'cluster:scheduler' with:
%   - cluster: 'local','cephee','saturne','macproyves','macbookyves' (see make_path_LOCAL.m)
%   - scheduler: 'xgrid','condor','pbs' (NOTE: for TORQUE or LFS, use pbs) (see make_path_LOCAL.m)
% If scheduler is empty, the first remote structure is considered (default or local)
% If remotename is empty, sequential calculations
%
remotename = 'macbookyves:condor';%'macproyves:condor','macproyves:xgrid','local';
%
dkeparam.clustermode.coll_dke_jd.scheduler.type = 'local';
dkeparam.clustermode.eecoll_dke_yp.scheduler.type = 'local';
dkeparam.clustermode.coll_dke_jd.scheduler.mode = 2;
dkeparam.clustermode.eecoll_dke_yp.scheduler.mode = 2;
%
%debugmode = 0;%set to 1 in case of problem
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
% all profiles in dkepath.remote are tested
%
if isfield(dkepath,'remote'),
    nrem = length(dkepath.remote);
else
    nrem = 0;
end
%
Znorm = cell(1,nrem+1);
Zcurr = cell(1,nrem+1);
ZP0 = cell(1,nrem+1);
%
% local calculation
%
disp('--> Local calculation')
%
[Znorm_0,Zcurr_0,ZP0_0] = run_lukert(id_simul,'',waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
%
dkepath.remtimout = 10;% timeout in minutes
dkepath.remenforce = 0;% exit if remote calculation failed 
%
for remnum = 1:nrem,
    dkepath.remnum = remnum;
    %
    disp(['--> Calculation with remote number ',num2str(remnum)])
    %
    [rZnorm,rZcurr,rZP0] = run_lukert(id_simul,'',waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
    %
    if ~isempty(rZcurr),
        Znorm{remnum} = rZnorm;
        Zcurr{remnum} = rZcurr;
        ZP0{remnum} = rZP0;
    end
end
%
j_r_k = '0.003732';
p_r_k = '0.0001256';
eta_r_k = '29.72';
%
%************************************************************************************************************************************
%
format
%
delete res_karney_remote
%
diary res_karney_remote
%
disp(['----------------------'])
disp(['Comparison LUKE/Karney - Relativistic case (4,7,1) - with tn = ',int2str(dkeparam.tn),', dtn = ',int2str(dkeparam.dtn),' and nit_f = ',int2str(dkeparam.nit_f)])
disp(['----------------------'])
%
disp(['Local calculation : j = ',num2str(Zcurr_0.x_0),'/',j_r_k,' ; P = ',num2str(ZP0_0.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(Zcurr_0.x_0./ZP0_0.x_rf_fsav),'/',eta_r_k]) 
%
for remnum = 1:nrem,
    if ~isempty(Zcurr{remnum}),
        disp(['Remote calc.  # ',num2str(remnum),' : j = ',num2str(Zcurr{remnum}.x_0),'/',j_r_k,' ; P = ',num2str(ZP0{remnum}.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(Zcurr{remnum}.x_0./ZP0{remnum}.x_rf_fsav),'/',eta_r_k]) 
    end
end
%
diary off
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'LUKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'LUKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
