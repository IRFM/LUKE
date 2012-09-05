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
%
% Distributed compting options on the remote computer (or cluster)
% Syntax 'cluster:scheduler' with:
%   - cluster: 'local','cephee','saturne','macproyves','macbookyves' (see make_path_LOCAL.m)
%   - scheduler: 'xgrid','condor','pbs' (NOTE: for TORQUE or LFS, use pbs) (see make_path_LOCAL.m)
% If scheduler is empty, the first remote structure is considered (default or local)
% If remotename is empty, sequential calculations
%
remotename = 'macproyves:xgrid';
%
dkeparam.clustermode.coll_dke_jd.scheduler.type = 'local';
dkeparam.clustermode.eecoll_dke_yp.scheduler.type = 'local';
dkeparam.clustermode.coll_dke_jd.scheduler.mode = 2;
dkeparam.clustermode.eecoll_dke_yp.scheduler.mode = 2;
%
debugmode = 0;%set to 1 in case of problem
%
if isempty(remotename),%local non distributed calculations
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
    tic
    %[nondist(1).Znorm,nondist(1).Zcurr,nondist(1).ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    dkeparam.rt_mode = 1;
    [nondist(1).Znorm,nondist(1).Zcurr,nondist(1).ZP0] = run_lukert(id_simul,'',waves,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,transpfaste,ripple,[],[]);
    time_without_dist = toc;
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
    tic
    [nondist(2).Znorm,nondist(2).Zcurr,nondist(2).ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    time_without_dist = time_without_dist + toc;
    %
    dkeparam.nmhu_S = 201;
    dkeparam.np_S = 201;
    dkeparam.pnmax_S = 20;
    %
    tic
    [nondist(3).Znorm,nondist(3).Zcurr,nondist(3).ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    time_without_dist = time_without_dist + toc;
    %
    dkeparam.coll_mode = 2;%For comparison with theoretical results
    %
    tic
    [nondist(4).Znorm,nondist(4).Zcurr,nondist(4).ZP0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    time_without_dist = time_without_dist + toc;
    %
else,%remote distributed calculations (may be distributed on the remote machine or cluster)
    [flag,remote] = check_remote_yp(dkepath,remotename);
    if ~flag,return,end,%no remote connection
    %
    luke_input = [];
    %
    dkeparam.rt_mode = 1;
    dkeparam.psin_S = psin_S;
    dkeparam.rho_S = rho_S;
    %
    dkeparam_rel = dkeparam;
    dkeparam_nonrel_0_10 = dkeparam;
    dkeparam_nonrel_0_20 = dkeparam;
    dkeparam_nonrel_2_20 = dkeparam;
    %
    wavestruct_rel = wavestruct;
    wavestruct_nonrel = wavestruct;
    %    
    equil_rel = equil;
    equil_nonrel = equil;
    %
    % RELATIVISTIC CASE
    %
    dkeparam_rel.pnmax_S = 30;
    %
    wavestruct_rel.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    wavestruct_rel.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    %
    waves_rel{1} = make_idealLHwave_jd(equil_rel,wavestruct_rel);
    %
    % NON-RELATIVISTIC CASE   
    %
    betath = 0.001;%validated for NR limit
    %
    equil_nonrel.pTe = betath^2*mc2*ones(size(equil_nonrel.pTe));
    equil_nonrel.pzTi = betath^2*mc2*ones(size(equil_nonrel.pzTi));
    %
    wavestruct_nonrel.yvparmin_lh = [3];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    wavestruct_nonrel.yvparmax_lh = [5];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    %
    waves_nonrel{1} = make_idealLHwave_jd(equil_nonrel,wavestruct_nonrel);
    %
    dkeparam_nonrel_0_10.coll_mode = 0;%For comparison with theoretical results
    dkeparam_nonrel_0_20.coll_mode = 0;%For comparison with theoretical results
    dkeparam_nonrel_2_20.coll_mode = 2;%For comparison with theoretical results
    %
    dkeparam_nonrel_0_10.nmhu_S = 101;
    dkeparam_nonrel_0_10.np_S = 101;
    dkeparam_nonrel_0_10.pnmax_S = 10;
    %
    dkeparam_nonrel_0_20.nmhu_S = 201;
    dkeparam_nonrel_0_20.np_S = 201;
    dkeparam_nonrel_0_20.pnmax_S = 20;
    %
    dkeparam_nonrel_2_20.nmhu_S = 201;
    dkeparam_nonrel_2_20.np_S = 201;
    dkeparam_nonrel_2_20.pnmax_S = 20;
    %
    luke_input(1).id_simul = '_rel';
    luke_input(2).id_simul = '_nonrel_0_10';
    luke_input(3).id_simul = '_nonrel_0_20';
    luke_input(4).id_simul = '_nonrel_2_20';
    %
    luke_input(1).dkeparam = dkeparam_rel;
    luke_input(2).dkeparam = dkeparam_nonrel_0_10;
    luke_input(3).dkeparam = dkeparam_nonrel_0_20;
    luke_input(4).dkeparam = dkeparam_nonrel_2_20;
    %
    luke_input(1).equil = equil_rel;
    luke_input(2).equil = equil_nonrel;
    luke_input(3).equil = equil_nonrel;
    luke_input(4).equil = equil_nonrel;
    %
    luke_input(1).waves = waves_rel;
    luke_input(2).waves = waves_nonrel;
    luke_input(3).waves = waves_nonrel;
    luke_input(4).waves = waves_nonrel;
    %
    for i_simul = 1:4,
        luke_input(i_simul).wavestructs = '';
        luke_input(i_simul).dkedisplay = dkedisplay;
        luke_input(i_simul).ohm = ohm;
        luke_input(i_simul).transpfaste = transpfaste;
        luke_input(i_simul).ripple = ripple;
    end
    %
    tic
    for i_simul = 1:4,
        [tid,jid] = runluke_remote_jd(luke_input(i_simul),remote,debugmode);%Job submission
         timeid(i_simul) = {tid};
         jobid(i_simul) = {jid};
    end
    %
    i_simul = 1;
    flag = ones(4,1);
    %
    disp('Wait until each job is done (set ''debugmode'' variable to 1 for investing the logfiles in case of problems)...');
    %
    while 1,
        if flag(i_simul)
            output = getluke_remote_jd(timeid{i_simul},jobid{i_simul},remote,debugmode);
            if ~isempty(output)
                withdist(i_simul) = output;
                flag(i_simul) = 0;
            end
        end
        %
        i_simul = i_simul + 1;
        if i_simul > 4, i_simul = 1;end
        %
        if sum(flag) == 0;break;end
    end
    time_with_dist = toc;
end
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
delete res_karney_remote
%
diary res_karney_remote
%
disp(['----------------------'])
disp(['Comparison LUKE/Karney with tn = ',int2str(dkeparam.tn),', dtn = ',int2str(dkeparam.dtn),' and nit_f = ',int2str(dkeparam.nit_f)])
disp(['----------------------'])
%
if isempty(remotename),
    info_dke_yp(2,['Calculations time without distributed computing, elapsed time: ',num2str(time_without_dist),' s'],'','Green');
    disp(['----------------------'])
    disp(['Relativistic case (4,7,1) : j = ',num2str(nondist(1).Zcurr.x_0),'/',j_r_k,' ; P = ',num2str(nondist(1).ZP0.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(nondist(1).Zcurr.x_0./nondist(1).ZP0.x_rf_fsav),'/',eta_r_k]) 
    disp(['Non Relativistic case (3,5,1) pmax = 10, coll_mode = 0 : j = ',num2str(nondist(2).Zcurr.x_0),'/',j_nr_0_10_k,' ; P = ',num2str(nondist(2).ZP0.x_rf_fsav),'/',p_nr_0_10_k,' ; j/P = ',num2str(nondist(2).Zcurr.x_0./nondist(2).ZP0.x_rf_fsav),'/',eta_nr_0_10_k]) 
    disp(['Non Relativistic case (3,5,1) pmax = 20, coll_mode = 0 : j = ',num2str(nondist(3).Zcurr.x_0),'/',j_nr_0_20_k,' ; P = ',num2str(nondist(3).ZP0.x_rf_fsav),'/',p_nr_0_20_k,' ; j/P = ',num2str(nondist(3).Zcurr.x_0./nondist(3).ZP0.x_rf_fsav),'/',eta_nr_0_20_k]) 
    disp(['Non Relativistic case (3,5,1) pmax = 20, coll_mode = 2 : j = ',num2str(nondist(4).Zcurr.x_0),'/',j_nr_2_20_k,' ; P = ',num2str(nondist(4).ZP0.x_rf_fsav),'/',p_nr_2_20_k,' ; j/P = ',num2str(nondist(4).Zcurr.x_0./nondist(4).ZP0.x_rf_fsav),'/',eta_nr_2_20_k]) 
else
    info_dke_yp(2,['Calculations time with distributed computing, elapsed time: ',num2str(time_with_dist),' s'],'','Green');
    disp(['----------------------'])
    disp(['Relativistic case (4,7,1) : j = ',num2str(withdist(1).Zcurr.x_0),'/',j_r_k,' ; P = ',num2str(withdist(1).ZP0.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(withdist(1).Zcurr.x_0./withdist(1).ZP0.x_rf_fsav),'/',eta_r_k]) 
    disp(['Non Relativistic case (3,5,1) pmax = 10, coll_mode = 0 : j = ',num2str(withdist(2).Zcurr.x_0),'/',j_nr_0_10_k,' ; P = ',num2str(withdist(2).ZP0.x_rf_fsav),'/',p_nr_0_10_k,' ; j/P = ',num2str(withdist(2).Zcurr.x_0./withdist(2).ZP0.x_rf_fsav),'/',eta_nr_0_10_k]) 
    disp(['Non Relativistic case (3,5,1) pmax = 20, coll_mode = 0 : j = ',num2str(withdist(3).Zcurr.x_0),'/',j_nr_0_20_k,' ; P = ',num2str(withdist(3).ZP0.x_rf_fsav),'/',p_nr_0_20_k,' ; j/P = ',num2str(withdist(3).Zcurr.x_0./withdist(3).ZP0.x_rf_fsav),'/',eta_nr_0_20_k]) 
    disp(['Non Relativistic case (3,5,1) pmax = 20, coll_mode = 2 : j = ',num2str(withdist(4).Zcurr.x_0),'/',j_nr_2_20_k,' ; P = ',num2str(withdist(4).ZP0.x_rf_fsav),'/',p_nr_2_20_k,' ; j/P = ',num2str(withdist(4).Zcurr.x_0./withdist(4).ZP0.x_rf_fsav),'/',eta_nr_2_20_k]) 
    disp(['----------------------'])
end
%
diary off
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
