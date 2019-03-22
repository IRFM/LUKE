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
permission = test_permissions_yp;
%
if ~permission 
    disp('Please move the script to a local folder where you have write permission before to run it')
    return;
end
%
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_Zi_ADAS';%Simulation ID
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
wavestruct.yvparmin_lh = [4];%LH wave square N// Spectrum: Lower limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
wavestruct.yvparmax_lh = [7];%LH wave square N// Spectrum: Upper limit of the plateau (vth_ref or vth) [1,n_scenario_lh]
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
dkeparam.np_S = 201;
dkeparam.nmhu_S = 201;
dkeparam.pnmax_S = 30;
%
dkeparam.psin_S = psin_S;
dkeparam.rho_S = rho_S;
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
pzni = equil.pzni;
pzTi = equil.pzTi;
%
Zi_list = [1:8,10,13,14,17,18,24,26,28,29,32,36,42,54,74];
%
nZi = length(Zi_list);
%
j_2 = NaN(1,nZi);
%
P_2 = NaN(1,nZi);
%
for iZi = 1:nZi,
    %
    Zi = Zi_list(iZi);
    %
    if Zi == 1,
        equil.zZi = [1,1,1];
        equil.zmi = [1,2,3];
        equil.pzni = pzni(1:3,:);
        equil.pzTi = pzTi(1:3,:);
    else
        equil.zZi = [1,1,1,Zi];
        equil.zmi = [1,2,3,12];
        equil.pzni = [0;0;0;1/Zi]*equil.pne;
        equil.pzTi = [equil.pzTi(1:3,:);equil.pzTi(1,:)];
    end
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker collision operator for ee with first order Legendre correction for momentum conservation, non-relativistic Maxwellian background for ei
    [dummy,Zcurr,ZP0,dke_out,~,equilDKE_2] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_2(iZi) = Zcurr.x_0;
        P_2(iZi) = ZP0.x_rf_fsav;
        Zeff_2(iZi) = equilDKE_2.xZeff;
    end
    %
    disp(['----> Calculations for Zi = ',int2str(Zi),' done. Fully stripped ion']);
    %
end
%
eta_2 = j_2./P_2;
%
j_2_rel_Karney_1 = 0.003732;
P_2_rel_Karney_1 = 0.0001256;
eta_2_rel_Karney_1 = 29.72;
%
eta_2_rel_Karney = eta_2_rel_Karney_1*6./(5 + Zi_list);
%
%************************************************************************************************************************************
%
figure,clf
%
leg = {'collmode = 2 [ee: Belaiev-Budker model + 1st Legendre, ei: nr Maxw. background]',...
       'collmode = 2 [Karney'' model, D_{LH} = (4,7,1), p_{max} = 30, 6/(5+Zi)]'};
%
xlim = [0,max(Zi_list)];
ylim = [0,0.1];
xlab = 'Z_i';
ylab = 'j';
tit = ['Relativistice case, T_{e} = ',num2str(round(equil.pTe(1)*100)/100),' keV, ion fully stripped'];
siz = 20+14i;
%
graph1D_jd(Zi_list,j_2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(1,j_2_rel_Karney_1,0,0,'','','',leg,xlim,ylim,'none','o','r',2,siz,gca);
%
set(gca,'ytick',[0:0.1:1]*ylim(2))
set(gca,'xtick',[1:5:xlim(2)])
%
figure,clf
%
ylim = [0,0.03];
ylab = 'P';
%
graph1D_jd(Zi_list,P_2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(1,P_2_rel_Karney_1,0,0,'','','',leg,xlim,ylim,'none','o','r',2,siz,gca);
%
set(gca,'ytick',[0:0.1:1]*ylim(2))
set(gca,'xtick',[1:5:xlim(2)])
%
figure,clf
%
ylim = [0,30];
ylab = 'j/P';
%
graph1D_jd(Zi_list,eta_2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(Zi_list,eta_2_rel_Karney,0,0,'','','',leg,xlim,ylim,':','none','r',2,siz,gca);
%
set(gca,'ytick',[0:0.1:1]*ylim(2))
set(gca,'xtick',[1:5:xlim(2)])
%
print_jd(p_opt,'fig_j_Zi','./figures',1)
print_jd(p_opt,'fig_P_Zi','./figures',2)
print_jd(p_opt,'fig_eta_Zi','./figures',3)
%
equil.ADAS = [dkepath.luke_root,'project_DKE/Modules/ADAS/ADAS.mat'];%Atomic Data and Analysis Structure (ADAS). 
%
j_2_ADAS = NaN(1,nZi);
%
P_2_ADAS = NaN(1,nZi);
%
for iZi = 1:nZi,
    %
    Zi = Zi_list(iZi);
    %
    if Zi == 1,
        equil.zZi = [1,1,1];
        equil.zmi = [1,2,3];
        equil.pzni = pzni(1:3,:);
        equil.pzTi = pzTi(1:3,:);
    else
        equil.zZi = [1,1,1,Zi];
        equil.zmi = [1,2,3,12];
        equil.pzni = [0;0;0;1/Zi]*equil.pne;
        equil.pzTi = [pzTi(1:3,:);pzTi(1,:)];
    end
    %
    waves{1} = make_idealLHwave_jd(equil,wavestruct);
    %
    dkeparam.coll_mode = 2;% Linearized Belaiev-Budker collision operator for ee with first order Legendre correction for momentum conservation, non-relativistic Maxwellian background for ei
    [dummy,Zcurr,ZP0,dke_out,~,equilDKE_2_ADAS] = main_dke_yp(id_simul,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    if dke_out.residu_f{end}(end) <= dkeparam.prec0_f,
        j_2_ADAS(iZi) = Zcurr.x_0;
        P_2_ADAS(iZi) = ZP0.x_rf_fsav;
        Zeff_2_ADAS(iZi) = equilDKE_2_ADAS.xZeff;
    end
    %
    disp(['----> Calculations for Zi = ',int2str(Zi),' done. Ionization state from ADAS']);
    %
end
%
eta_2_ADAS = j_2_ADAS./P_2_ADAS;
%
%************************************************************************************************************************************
%
figure,clf
%
leg = {'collmode = 2 [ee: Belaiev-Budker model + 1st Legendre, ei: nr Maxw. background]',...
       'collmode = 2 [Karney'' model, D_{LH} = (4,7,1), p_{max} = 30, 6/(5+Zi)]'};
%
xlim = [0,max(Zi_list)];
ylim = [0,0.1];
xlab = 'Z_i';
ylab = 'j';
tit = ['Relativistic case, T_{e} = ',num2str(round(equil.pTe(1)*100)/100),' keV, ADAS'];
siz = 20+14i;
%
graph1D_jd(Zi_list,j_2_ADAS,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(1,j_2_rel_Karney_1,0,0,'','','',leg,xlim,ylim,'none','o','r',2,siz,gca);
%
set(gca,'ytick',[0:0.1:1]*ylim(2))
set(gca,'xtick',[1:5:xlim(2)])
%
figure,clf
%
ylim = [0,0.03];
ylab = 'P';
%
graph1D_jd(Zi_list,P_2_ADAS,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(1,P_2_rel_Karney_1,0,0,'','','',leg,xlim,ylim,'none','o','r',2,siz,gca);
%
set(gca,'ytick',[0:0.1:1]*ylim(2))
set(gca,'xtick',[1:5:xlim(2)])
%
figure,clf
%
ylim = [0,30];
ylab = 'j/P';
%
graph1D_jd(Zi_list,eta_2_ADAS,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(Zi_list,eta_2_rel_Karney,0,0,'','','',leg,xlim,ylim,':','none','r',2,siz,gca);
%
set(gca,'ytick',[0:0.1:1]*ylim(2))
set(gca,'xtick',[1:5:xlim(2)])
%
print_jd(p_opt,'fig_j_Zi_ADAS','./figures',4)
print_jd(p_opt,'fig_P_Zi_ADAS','./figures',5)
print_jd(p_opt,'fig_eta_Zi_ADAS','./figures',6)
%
figure,clf
%
ylim = [0,30];
ylab = 'j/P';
%
tit = ['Relativistic case, T_{e} = ',num2str(round(equil.pTe(1)*100)/100),' keV, collmode = 2'];
leg = {'Fully stripped ion',...
       'Partially ionised ion (ADAS)'};
%
graph1D_jd(Zi_list,eta_2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(Zi_list,eta_2_ADAS,0,0,xlab,ylab,tit,leg,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.1:1]*ylim(2))
set(gca,'xtick',[1:5:xlim(2)])
%
print_jd(p_opt,'fig_eta_Zi_Zi_ADAS','./figures',7)
%
figure,clf
%
ylim = [0,max(Zi_list)];
ylab = 'Z_{eff}';
tit = ['Relativistic case, T_{e} = ',num2str(round(equil.pTe(1)*100)/100),' keV'];
%
graph1D_jd(Zi_list,Zeff_2,0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
graph1D_jd(Zi_list,Zeff_2_ADAS,0,0,xlab,ylab,tit,leg,xlim,ylim,'none','+','r',2,siz,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:5:xlim(2)])
set(gca,'xtick',[0:5:xlim(2)])
%
print_jd(p_opt,'fig_Zeff_Zi_Zi_ADAS','./figures',8)
%
%************************************************************************************************************************************
%
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
