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
p_opt = 2;
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_init';%Simulation ID
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
id_display = 'NO_DISPLAY';%For output code display
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
wavestruct.yvparmin_lh = [3];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [5];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
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
%
dkeparam.np_S = 201;
dkeparam.nmhu_S = 201;
%
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
betath_list = [logspace(-3,-2,7),logspace(-1.85,-0.35,11)];betath_list = betath_list(1:15);
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
nbetath = length(betath_list);
%
j0_0 = NaN(1,nbetath);
jend_0 = NaN(1,nbetath);
nit_0 = NaN(1,nbetath);
%
j0_1 = NaN(1,nbetath);
jend_1 = NaN(1,nbetath);
nit_1 = NaN(1,nbetath);
%
for ibetath = 1:nbetath,
    %
    betath = betath_list(ibetath);
    %
    equil.pTe = betath^2*mc2*ones(size(equil.pTe));
    equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.initguess_f =  0;
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    j0_0(ibetath) = dke_out.curr0{end}(1);
    jend_0(ibetath) = dke_out.curr0{end}(end);
    nit_0(ibetath) = length(dke_out.curr0{end}) - 1;
    %
    dkeparam.initguess_f =  1;
    if ibetath == 14,
        dkedisplay.display_init = 1;%Display the initial distribution function only
    end
    [dummy,dummy,dummy,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    dkedisplay.display_init = 0;
    %
    j0_1(ibetath) = dke_out.curr0{end}(1);
    jend_1(ibetath) = dke_out.curr0{end}(end);
    nit_1(ibetath) = length(dke_out.curr0{end}) - 1;
    %
end
%
j_2_nr_Karney = 0.07092;
%
%************************************************************************************************************************************
%
leg = {'No guess (initial)','No guess (final)','LH guess (initial)','LH guess (final)'};
xlim = 10.^[-3,0];
ylim = [0,0.1];
xlab = '\beta_T';
ylab = 'j';
tit = '';
siz = 20+14i;
%
figure('Name','LH current');clf
%
graph1D_jd(betath_list,j0_0,1,0,xlab,ylab,tit,NaN,xlim,ylim,'--','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,jend_0,1,0,'','','',NaN,xlim,ylim,'-','none','r',2,siz,gca);
graph1D_jd(betath_list,j0_1,1,0,'','','',NaN,xlim,ylim,'--','none','b',2,siz,gca);
graph1D_jd(betath_list,jend_1,1,0,'','','',leg,xlim,ylim,'-','none','b',2,siz,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure('Name','Convergence rate');clf
%
leg = {'No guess','LH guess'};
ylab = 'Number of iterations';
ylim = [0,50];
%
graph1D_jd(betath_list,nit_0,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,nit_1,1,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
%
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(p_opt,'fig_f2D_init','./figures',1)
print_jd(p_opt,'fig_f1D_init','./figures',2)
print_jd(p_opt,'fig_vp_init','./figures',3)
print_jd(p_opt,'fig_j_init','./figures',4)
print_jd(p_opt,'fig_nit_init','./figures',5)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
