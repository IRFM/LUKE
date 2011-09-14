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
id_simul = 'Runaway_betath';%Simulation ID
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
if exist('dmumpsmex');dkeparam.invproc = -2;end
%
dkeparam.boundary_mode_f = 0;%Enforcing the Maxwellian initial value at the first "boundary_mode_f" grid points
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
dkeparam.tn = 10000;%time for asymptotic solution with norm_mode_f = 1
dkeparam.dtn = 1000;%10 time steps required for accurate runaway solution - see rundke_dtn
%
epsi = 0.04;
%
equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
betath_list = [logspace(-5,-2,7),logspace(-1.85,-0.35,11)];
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
nbetath = length(betath_list);
%
RR_0 = NaN(1,nbetath);
RR_1 = NaN(1,nbetath);
RR_2 = NaN(1,nbetath);
%RR_4 = NaN(1,nbetath);
%
for ibetath = 1:nbetath,
    %
    betath = betath_list(ibetath);
    %
    equil.pTe = betath^2*mc2*ones(size(equil.pTe));
    %equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
    %
    ohm = ohm_flat(equil,epsi);
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    [dummy,dummy,dummy,dke_out_0] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    dkeparam.coll_mode = 1;% High-velocity limit
    [dummy,dummy,dummy,dke_out_1] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    [dummy,dummy,dummy,dke_out_2] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    %dkeparam.coll_mode = 4;% Maxwellian Background
    %[dummy,dummy,dummy,dke_out_4] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    %
    RR_0(ibetath) = dke_out_0.XxRR_fsav(end,:);
    RR_1(ibetath) = dke_out_1.XxRR_fsav(end,:);
    %
    if dke_out_2.residu_f{end}(end) <= dkeparam.prec0_f,
        RR_2(ibetath) = dke_out_2.XxRR_fsav(end,:);
    end
    %
%    RR_4(ibetath) = dke_out_4.XxRR_fsav(end,:);
    %
end
%
RR_kulsrud = 1.914*1e-6;%Kulsrud (PRL, 31,11, (1972) 690)
%
%************************************************************************************************************************************
%
figure(1),clf
%
%leg = {'Linearized','High v limit','Maxwellian','Maxwellian NR'};
leg = {'Linearized','High v limit','Maxwellian'};
xlim = 10.^[-5,0];
ylim = [0,5e-6];
xlab = '\beta_T';
ylab = '\Gamma_R';
tit = '';
siz = 20+14i;
%
graph1D_jd(betath_list,RR_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,RR_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
graph1D_jd(betath_list,RR_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
%graph1D_jd(betath_list,RR_4,1,0,'','','',leg,xlim,ylim,'-','none','m',2,siz,gca);
%
graph1D_jd(xlim,[RR_kulsrud,RR_kulsrud],1,0,'','','',NaN,xlim,ylim,'--','none','k',2,siz,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(p_opt,'fig_runaway_betath','.',1)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
