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
id_simul = 'Ohm_betath';%Simulation ID
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
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 0;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
epsi = 0.001;
%
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
betath_Karney = sqrt([0.01,0.02,0.05,0.1,0.2]);
sigma_Karney = [7.291,7.160,6.807,6.317,5.575];
sigma_Karney_nr_0 = 3.773;
sigma_Karney_nr_1 = 2.837;
sigma_Karney_nr_2 = 7.429;
%sigma_Karney_nr_4 = 3.773;
%
%
betath_list = [logspace(-5,-2,7),0.015,0.02,0.03,0.05,0.07,betath_Karney];
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
for ibetath = 1:length(betath_list),
    %
    betath = betath_list(ibetath);
    %
    equil.pTe = betath^2*mc2*ones(size(equil.pTe));
    equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
    %
    ohm = ohm_flat(equil,epsi);
    %
    dkeparam.coll_mode = 0;% Relativistic Maxwellian background
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if min(dke_out.residu_f) < dkeparam.prec0_f,
        sigma_0(ibetath) = Zcurr.x_0/epsi;
    else
        sigma_0(ibetath) = NaN;
    end        
    %
    dkeparam.coll_mode = 1;% High-velocity limit
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if min(dke_out.residu_f) < dkeparam.prec0_f,
        sigma_1(ibetath) = Zcurr.x_0/epsi;
    else
        sigma_1(ibetath) = NaN;
    end        
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if min(dke_out.residu_f) < dkeparam.prec0_f,
        sigma_2(ibetath) = Zcurr.x_0/epsi;
    else
        sigma_2(ibetath) = NaN;
    end        
    %
end
%
sigma_Z1s = 1/100*sqrt(me*qe/10)/(1.65*mu0*e0^2);%Spitzer conductivity (from 'Tokamaks' by J. Wesson, Oxford Science Publication, 3rd Eds., 2004)
%
%************************************************************************************************************************************
%
format
%
delete res_betath
%
diary res_betath
%
disp(['Comparison LUKE/Karney/Spitzer - NR calculations (betath = 0.01)'])
disp(['----------------------'])
%
disp(['Linearized operator : sigma = ',num2str(sigma_2(7)),'/',num2str(sigma_Karney_nr_2),'/',num2str(sigma_Z1s)]) 
disp(['Maxwellian operator : sigma = ',num2str(sigma_0(7)),'/',num2str(sigma_Karney_nr_0)]) 
disp(['High-Velocity operator : sigma = ',num2str(sigma_1(7)),'/',num2str(sigma_Karney_nr_1)]) 
%
disp(' ')
disp(['Comparison LUKE/Karney - FR calculations'])
disp(['----------------------'])
disp(['betath^2 = 0.01 : sigma = ',num2str(sigma_2(13)),'/',num2str(sigma_Karney(1))]) 
disp(['betath^2 = 0.02 : sigma = ',num2str(sigma_2(14)),'/',num2str(sigma_Karney(2))])
disp(['betath^2 = 0.05 : sigma = ',num2str(sigma_2(15)),'/',num2str(sigma_Karney(3))])
disp(['betath^2 = 0.10 : sigma = ',num2str(sigma_2(16)),'/',num2str(sigma_Karney(4))])
disp(['betath^2 = 0.20 : sigma = ',num2str(sigma_2(17)),'/',num2str(sigma_Karney(5))])
%
diary off
%
figure(1),clf
%
%leg = {'Linearized','High v limit','Maxwellian NR','Maxwellian'};
leg = {'Linearized','High v limit','Maxwellian'};
xlim = 10.^[-5,0];
ylim = [0,10];
xlab = '\beta_T';
ylab = '\sigma';
tit = '';
graph1D_jd(betath_list,sigma_2,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(betath_list,sigma_1,1,0,'','','',NaN,xlim,ylim,'-','none','b',2,20,gca);
%graph1D_jd(betath_list,sigma_4,1,0,'','','',NaN,xlim,ylim,'-','none','m',2,20,gca);
graph1D_jd(betath_list,sigma_0,1,0,'','','',leg,xlim,ylim,'-','none','g',2,20,gca);
graph1D_jd(xlim,[sigma_Z1s,sigma_Z1s],1,0,'','','',NaN,xlim,ylim,'-','none','k',0.5,20,gca);
graph1D_jd(betath_Karney,sigma_Karney,0,0,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,20,gca);
graph1D_jd(xlim,[sigma_Karney_nr_2,sigma_Karney_nr_2],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(xlim,[sigma_Karney_nr_1,sigma_Karney_nr_1],0,0,'','','',NaN,xlim,ylim,'--','none','b',2,20,gca);
%graph1D_jd(xlim,[sigma_Karney_nr_4,sigma_Karney_nr_4],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,20,gca);
graph1D_jd(xlim,[sigma_Karney_nr_0,sigma_Karney_nr_0],0,0,'','','',NaN,xlim,ylim,'--','none','g',2,20,gca);
set(gca,'ytick',[0:2:10])
set(gca,'xtick',[1e-05 0.0001 0.001 0.01 0.1 1])
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(2,'fig_sigma_betath','.',1)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
