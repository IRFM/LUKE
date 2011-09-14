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
id_simul = 'LH_karney_grid';%Simulation ID
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
np_list = round(logspace(1,3,41));
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
nnp = length(np_list);
%
j_rel_50 = NaN(1,nnp);
j_rel_100 = NaN(1,nnp);
j_rel_200 = NaN(1,nnp);
p_rel_50 = NaN(1,nnp);
p_rel_100 = NaN(1,nnp);
p_rel_200 = NaN(1,nnp);
%
j_nr_50 = NaN(1,nnp);
j_nr_100 = NaN(1,nnp);
j_nr_200 = NaN(1,nnp);
p_nr_50 = NaN(1,nnp);
p_nr_100 = NaN(1,nnp);
p_nr_200 = NaN(1,nnp);
%
for inp = 1:nnp,
    %
    dkeparam.np_S = np_list(inp) + 1;
    %
    % RELATIVISTIC CASE
    %
    betath = 0.1;
    equil.pTe = betath^2*mc2*ones(size(equil.pTe));
    equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
    %
    wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.pnmax_S = 30;
    %
    dkeparam.nmhu_S = 51;
    %
    [dummy,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_rel_50(inp) = Zcurr.x_0;
        p_rel_50(inp) = ZP0.x_rf_fsav;
    end
    %
    dkeparam.nmhu_S = 101;
    %
    [dummy,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_rel_100(inp) = Zcurr.x_0;
        p_rel_100(inp) = ZP0.x_rf_fsav;
    end
    %
    dkeparam.nmhu_S = 201;
    %
    [dummy,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_rel_200(inp) = Zcurr.x_0;
        p_rel_200(inp) = ZP0.x_rf_fsav;
    end
    %
    % NON-RELATIVISTIC CASE
    %
    betath = 0.001;
    equil.pTe = betath^2*mc2*ones(size(equil.pTe));
    equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
    %
    wavestruct.yvparmin_lh = [3];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    wavestruct.yvparmax_lh = [5];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.pnmax_S = 20;
    %
    dkeparam.nmhu_S = 51;
    %
    [dummy,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_nr_50(inp) = Zcurr.x_0;
        p_nr_50(inp) = ZP0.x_rf_fsav;
    end
    %
    dkeparam.nmhu_S = 101;
    %
    [dummy,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_nr_100(inp) = Zcurr.x_0;
        p_nr_100(inp) = ZP0.x_rf_fsav;
    end
    %
    dkeparam.nmhu_S = 201;
    %
    [dummy,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_nr_200(inp) = Zcurr.x_0;
        p_nr_200(inp) = ZP0.x_rf_fsav;
    end
    %
end
%
j_rel_k = 0.003732;
p_rel_k = 0.0001256;
eta_rel_k = 29.72;
%
j_nr_k = 0.07092;
p_nr_k = 0.004294;
eta_nr_k = 16.52;
%
eta_rel_50 = j_rel_50./p_rel_50;
eta_rel_100 = j_rel_100./p_rel_100;
eta_rel_200 = j_rel_200./p_rel_200;
eta_nr_50 = j_nr_50./p_nr_50;
eta_nr_100 = j_nr_100./p_nr_100;
eta_nr_200 = j_nr_200./p_nr_200;
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'n_{\xi} = 50','n_{\xi} = 100','n_{\xi} = 200'};
xlim = 10.^[1,3];
ylim = [0,0.01];
xlab = 'n_p';
ylab = 'j';
tit = '';
siz = 20+14i;
%
graph1D_jd(np_list,j_rel_50,1,0,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(np_list,j_rel_100,1,0,'','','',NaN,xlim,ylim,'none','+','b',2,siz,gca);
graph1D_jd(np_list,j_rel_200,1,0,'','','',leg,xlim,ylim,'none','+','g',2,siz,gca);
graph1D_jd(xlim,[j_rel_k,j_rel_k],0,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[10,100,1000])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(2),clf
%
ylim = [0,0.0005];
ylab = 'P';
%
graph1D_jd(np_list,p_rel_50,1,0,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(np_list,p_rel_100,1,0,'','','',NaN,xlim,ylim,'none','+','b',2,siz,gca);
graph1D_jd(np_list,p_rel_200,1,0,'','','',leg,xlim,ylim,'none','+','g',2,siz,gca);
graph1D_jd(xlim,[p_rel_k,p_rel_k],0,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[10,100,1000])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(3),clf
%
ylim = [0,50];
ylab = 'j/P';
tit = '';
%
graph1D_jd(np_list,eta_rel_50,1,0,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(np_list,eta_rel_100,1,0,'','','',NaN,xlim,ylim,'none','+','b',2,siz,gca);
graph1D_jd(np_list,eta_rel_200,1,0,'','','',leg,xlim,ylim,'none','+','g',2,siz,gca);
graph1D_jd(xlim,[eta_rel_k,eta_rel_k],0,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[10,100,1000])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(4),clf
%
ylim = [0,0.1];
ylab = 'j';
tit = '';
%
graph1D_jd(np_list,j_nr_50,1,0,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(np_list,j_nr_100,1,0,'','','',NaN,xlim,ylim,'none','+','b',2,siz,gca);
graph1D_jd(np_list,j_nr_200,1,0,'','','',leg,xlim,ylim,'none','+','g',2,siz,gca);
graph1D_jd(xlim,[j_nr_k,j_nr_k],0,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[10,100,1000])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(5),clf
%
ylim = [0,0.01];
ylab = 'P';
%
graph1D_jd(np_list,p_nr_50,1,0,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(np_list,p_nr_100,1,0,'','','',NaN,xlim,ylim,'none','+','b',2,siz,gca);
graph1D_jd(np_list,p_nr_200,1,0,'','','',leg,xlim,ylim,'none','+','g',2,siz,gca);
graph1D_jd(xlim,[p_nr_k,p_nr_k],0,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[10,100,1000])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(6),clf
%
ylim = [0,30];
ylab = 'j/P';
tit = '';
%
graph1D_jd(np_list,eta_nr_50,1,0,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(np_list,eta_nr_100,1,0,'','','',NaN,xlim,ylim,'none','+','b',2,siz,gca);
graph1D_jd(np_list,eta_nr_200,1,0,'','','',leg,xlim,ylim,'none','+','g',2,siz,gca);
graph1D_jd(xlim,[eta_nr_k,eta_nr_k],0,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[10,100,1000])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(p_opt,'fig_j_rel_grid','.',1)
print_jd(p_opt,'fig_P_rel_grid','.',2)
print_jd(p_opt,'fig_eta_rel_grid','.',3)
print_jd(p_opt,'fig_j_nr_grid','.',4)
print_jd(p_opt,'fig_P_nr_grid','.',5)
print_jd(p_opt,'fig_eta_nr_grid','.',6)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
