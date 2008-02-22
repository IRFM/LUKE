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
id_simul = 'LH_karney_3D_num';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0:0.05:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
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
id_transpfaste = 'nomagneticturbulence';%For fast electron radial transport
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
dkeparam.boundary_mode_f = 0;%Number of points where the Maxwellian distribution is enforced from p = 0 (p=0, free conservative mode but param_inv(1) must be less than 1e-4, otherwise 1e-3 is OK most of the time. Sensitive to the number of points in p)
dkeparam.norm_mode_f = 1;%Local normalization of f0 at each iteration: (0) no, the default value when the numerical conservative scheme is correct, (1) yes    
%
dkeparam.ludroptol = 1e-4;%droptolerance
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
np_list = 25:25:250;
nmhu_list = 25:25:250;
nr_list = [1,5:5:30];
Dr0_list = [0,0.001,0.01,0.1,0.3,1,3,10,30,100];
%
% Incomplete LU factorization
%
dkeparam.invproc  = 1;%Numerical method (CGS, BICG, QMR)
transpfaste.Dr0 = 0;
%
for inp = 1:length(np_list);
    %
    dkeparam.np_S = np_list(inp) + 1;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    % 
    memory_LUi_np(inp) = dke_out.memoryLU_f_out;
    time_LUi_np(inp) = dke_out.time_DKE;
    %
end
%
dkeparam.np_S = 101;
%
for inmhu = 1:length(nmhu_list);
    %
    dkeparam.nmhu_S = nmhu_list(inmhu) + 1;
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    % 
    memory_LUi_nmhu(inmhu) = dke_out.memoryLU_f_out;
    time_LUi_nmhu(inmhu) = dke_out.time_DKE;
    %
end
%
dkeparam.nmhu_S = 101;
%
for inr = 1:length(nr_list);
    %
    rho_S = linspace(0,1,nr_list(inr)+1);
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    % 
    memory_LUi_nr(inr) = dke_out.memoryLU_f_out;
    time_LUi_nr(inr) = dke_out.time_DKE;
    %
end
%
rho_S = 0:0.05:1;
%
for iDr0 = 1:length(Dr0_list),
    %
    transpfaste.Dr0 = Dr0_list(iDr0);
    %
    [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
    % 
    memory_LUi_Dr0(iDr0) = dke_out.memoryLU_f_out;
    time_LUi_Dr0(iDr0) = dke_out.time_DKE;
    %
end
%
transpfaste.Dr0 =  0;
%
disp('Incomplete LU calculation done')
%
% MUMPSMEX package
%
if exist('dmumpsmex'),
    dkeparam.invproc = -2;
    %
    for inp = 1:length(np_list);
        %
        dkeparam.np_S = np_list(inp) + 1;
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        % 
        memory_MX_np(inp) = dke_out.memoryLU_f_out;
        time_MX_np(inp) = dke_out.time_DKE;
        %
    end
    %
    dkeparam.np_S = 101;
    %
    for inmhu = 1:length(nmhu_list);
        %
        dkeparam.nmhu_S = nmhu_list(inmhu) + 1;
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        % 
        memory_MX_nmhu(inmhu) = dke_out.memoryLU_f_out;
        time_MX_nmhu(inmhu) = dke_out.time_DKE;
        %
    end
    %
    dkeparam.nmhu_S = 101;
    %
    for inr = 1:length(nr_list);
        %
        rho_S = linspace(0,1,nr_list(inr)+1);
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        % 
        memory_MX_nr(inr) = dke_out.memoryLU_f_out;
        time_MX_nr(inr) = dke_out.time_DKE;
        %
    end
    %
    rho_S = 0:0.05:1;
    %
    for iDr0 = 1:length(Dr0_list),
        %
        transpfaste.Dr0 = Dr0_list(iDr0);
        %
        [Znorm,Zcurr,ZP0,dke_out] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        % 
        memory_MX_Dr0(iDr0) = dke_out.memoryLU_f_out;
        time_MX_Dr0(iDr0) = dke_out.time_DKE;
        %
    end
    %
    transpfaste.Dr0 =  0;
    %
    disp(['MUMPSMEX calculation done'])
end
%
ratio_LUi_np = time_LUi_np./memory_LUi_np;
ratio_LUi_nmhu = time_LUi_nmhu./memory_LUi_nmhu;
ratio_LUi_nr = time_LUi_nr./memory_LUi_nr;
ratio_LUi_Dr0 = time_LUi_Dr0./memory_LUi_Dr0;
ratio_MX_np = time_MX_np./memory_MX_np;
ratio_MX_nmhu = time_MX_nmhu./memory_MX_nmhu;
ratio_MX_nr = time_MX_nr./memory_MX_nr;
ratio_MX_Dr0 = time_MX_Dr0./memory_MX_Dr0;
%
%************************************************************************************************************************************
%
figure(1),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0,300];
ylim = [0,250];
xlab = 'n_p';
ylab = 'FPE calculation time (s)';
tit = '';
%
graph1D_jd(np_list,time_LUi_np,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(np_list,time_MX_np,0,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
%set(gca,'xtick',[1e-7,1e-6,1e-5,1e-4,1e-3,1e-2,1e-1])
set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
%set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(2),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0,300];
ylim = [0,250];
xlab = 'n_{\xi}';
ylab = 'FPE calculation time (s)';
tit = '';
%
graph1D_jd(nmhu_list,time_LUi_nmhu,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(nmhu_list,time_MX_nmhu,0,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
%set(gca,'xtick',[1e-7,1e-6,1e-5,1e-4,1e-3,1e-2,1e-1])
set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
%set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(3),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0,30];
ylim = [0,250];
xlab = 'n_r';
ylab = 'FPE calculation time (s)';
tit = '';
%
graph1D_jd(nr_list,time_LUi_nr,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(nr_list,time_MX_nr,0,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
%set(gca,'xtick',[1e-7,1e-6,1e-5,1e-4,1e-3,1e-2,1e-1])
set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
%set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(4),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0.001,100];
ylim = [0,1500];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'FPE calculation time (s)';
tit = '';
%
graph1D_jd(Dr0_list(2:end),time_LUi_Dr0(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(Dr0_list(2:end),time_MX_Dr0(2:end),1,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
graph1D_jd(xlim,[time_LUi_Dr0(1),time_LUi_Dr0(1)],1,0,'','','',leg,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(xlim,[time_MX_Dr0(1),time_MX_Dr0(1)],1,0,'','','',leg,xlim,ylim,'--','none','b',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[0.001,0.01,0.1,1,10,100])
%set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
%
figure(5),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0,300];
ylim = [0,500];
xlab = 'n_p';
ylab = 'LU matrix size (MBytes)';
tit = '';
%
graph1D_jd(np_list,memory_LUi_np,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(np_list,memory_MX_np,0,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
%set(gca,'ytick',[0:0.2:1]*ylim(2))
%set(gca,'xtick',[1e-7,1e-6,1e-5,1e-4,1e-3,1e-2,1e-1])
set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
%set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(6),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0,300];
ylim = [0,500];
xlab = 'n_{\xi}';
ylab = 'LU matrix size (MBytes)';
tit = '';
%
graph1D_jd(nmhu_list,memory_LUi_nmhu,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(nmhu_list,memory_MX_nmhu,0,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
%set(gca,'ytick',[0:0.2:1]*ylim(2))
%set(gca,'xtick',[1e-7,1e-6,1e-5,1e-4,1e-3,1e-2,1e-1])
set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
%set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(7),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0,30];
ylim = [0,500];
xlab = 'n_r';
ylab = 'LU matrix size (MBytes)';
tit = '';
%
graph1D_jd(nr_list,memory_LUi_nr,0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(nr_list,memory_MX_nr,0,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
%set(gca,'ytick',[0:0.2:1]*ylim(2))
%set(gca,'xtick',[1e-7,1e-6,1e-5,1e-4,1e-3,1e-2,1e-1])
set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
%set(gca,'XMinorGrid','off')
%set(gca,'XMinorTick','on')
%
figure(8),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0.001,100];
ylim = [0,1000];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'LU matrix size (MBytes)';
tit = '';
%
graph1D_jd(Dr0_list(2:end),memory_LUi_Dr0(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(Dr0_list(2:end),memory_MX_Dr0(2:end),1,0,'','','',leg,xlim,ylim,'-','+','b',2,20,gca);
graph1D_jd(xlim,[memory_LUi_Dr0(1),memory_LUi_Dr0(1)],1,0,'','','',leg,xlim,ylim,'--','none','r',2,20,gca);
graph1D_jd(xlim,[memory_MX_Dr0(1),memory_MX_Dr0(1)],1,0,'','','',leg,xlim,ylim,'--','none','b',2,20,gca);
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[0.001,0.01,0.1,1,10,100])
%set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(9),clf
%
leg = {'MATLAB LUi','MUMPSMEX'};
xlim = [0.1,2000];
ylim = [0.05,5];
xlab = 'FPE time (s)';
ylab = 'FPE time/LU size  (s/MBytes)';
tit = '';
%
graph1D_jd(time_LUi_np,ratio_LUi_np,1,1,xlab,ylab,tit,NaN,xlim,ylim,'none','+','r',2,20,gca,0.9,0.7,0.7);
graph1D_jd(time_MX_np,ratio_MX_np,1,1,'','','',leg,xlim,ylim,'none','o','r',2,20,gca);
graph1D_jd(time_LUi_nmhu,ratio_LUi_nmhu,1,1,'','','',NaN,xlim,ylim,'none','+','b',2,20,gca);
graph1D_jd(time_LUi_nr,ratio_LUi_nr,1,1,'','','',NaN,xlim,ylim,'none','+','g',2,20,gca);
graph1D_jd(time_LUi_Dr0,ratio_LUi_Dr0,1,1,'','','',NaN,xlim,ylim,'none','+','m',2,20,gca);
graph1D_jd(time_MX_nmhu,ratio_MX_nmhu,1,1,'','','',NaN,xlim,ylim,'none','o','b',2,20,gca);
graph1D_jd(time_MX_nr,ratio_MX_nr,1,1,'','','',NaN,xlim,ylim,'none','o','g',2,20,gca);
graph1D_jd(time_MX_Dr0,ratio_MX_Dr0,1,1,'','','',NaN,xlim,ylim,'none','o','m',2,20,gca);
%set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'ytick',[1e-1,1])
set(gca,'xtick',[1e-1,1,10,100,1000])
%set(gca,'xtick',[0:0.2:1]*xlim(2))
%set(gca,'XTickLabel',{'10^{-5}','10^{-4}','10^{-3}','10^{-2}','10^{-1}','1'})
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
set(gca,'YMinorGrid','off')
set(gca,'YMinorTick','on')
%
%
print_jd(2,'fig_num_3D_np_time','.',1)
print_jd(2,'fig_num_3D_nmhu_time','.',2)
print_jd(2,'fig_num_3D_nr_time','.',3)
print_jd(2,'fig_num_3D_Dr0_time','.',4)
print_jd(2,'fig_num_3D_np_memory','.',5)
print_jd(2,'fig_num_3D_nmhu_memory','.',6)
print_jd(2,'fig_num_3D_nr_memory','.',7)
print_jd(2,'fig_num_3D_Dr0_memory','.',8)
print_jd(2,'fig_num_3D_ratio','.',9)
%	    
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);