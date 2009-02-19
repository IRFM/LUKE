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
opt_proc = 0;%test for numerical performance test with number of processors 
%
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_3D_splitting';%Simulation ID
path_simul = '';%if nothing is specified, the working directory is first used and then MatLab is looking in all the path
%
psin_S = [];%Normalized poloidal flux grid where calculations are performed (0 < psin_S < 1) (If one value: local calculation only, not used if empty)
%rho_S = [0,0.05:0.02:0.2,0.22:0.03:0.6,0.62:0.05:0.95,1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
rho_S = [0:0.025:0.65,0.7:0.1:1];%Normalized radial flux grid where calculations are performed (0 < rho_S < 1) (If one value: local calculation only, not used if empty)
%rho_S = [0:0.1:0.65,0.7:0.1:1];

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
wavestruct.yD0_in_c_lh = [2];%Central LH QL diffusion coefficient (nhuth_ref*pth_ref^2 or nhuth*pth^2) [1,n_scenario_lh]
%     
wavestruct.yD0_in_lh_prof = [1];%Quasilinear diffusion coefficient radial profile: (0) uniform, (1) gaussian radial profile [1,n_scenario_lh]
wavestruct.ypeak_lh = [0.4];%Radial peak position of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
wavestruct.ywidth_lh = [0.1];%Radial width of the LH quasi-linear diffusion coefficient (r/a on midplane) [1,n_scenario_lh]
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
%betath = 0.001;
%
%[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
%equil.pTe = betath^2*mc2*ones(size(equil.pTe));
%equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
waves{1} = make_idealLHwave_jd(equil,wavestruct);
%
% Dpsipsi scan (0 -> 100 m2/s)
%
dkeparam.coll_mode = 2;%Pb with option 1 (high velicity limit)
dkeparam.prec0_f = NaN;
dkedisplay.display_mode = 0;%If -1, only the radius at which the residu is the largest is displayed
%
dtn_list = [1,10,100,1000];
%
normf0_0 = NaN(2,3,length(rho_S)-1,dtn_list(end) + 100,length(dtn_list));
curr0_0 = NaN(2,3,length(rho_S)-1,dtn_list(end) + 100,length(dtn_list));
residu_0 = NaN(2,3,length(rho_S)-1,dtn_list(end) + 100,length(dtn_list));
normf0_10 = NaN(2,3,length(rho_S)-1,dtn_list(end) + 100,length(dtn_list));
curr0_10 = NaN(2,3,length(rho_S)-1,dtn_list(end) + 100,length(dtn_list));
residu_10 = NaN(2,3,length(rho_S)-1,dtn_list(end) + 100,length(dtn_list));
%
for coll_mode = [1,3],
	for optsplit = 1:2,
    	for jdtn = 1:length(dtn_list),
    		%
    		dkeparam.coll_mode = coll_mode-1;
        	dkeparam.opsplit = optsplit - 1;
        	dkeparam.nit_f= dtn_list(end)/dtn_list(jdtn) + 100;
        	dkeparam.dtn = dtn_list(jdtn);
        	%
        	transpfaste.Dr0 = [0];
        	[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        	%
        	normf0_0(optsplit,coll_mode,1:size(dke_out.normf0,1),1:size(dke_out.normf0,2),jdtn) = dke_out.normf0;
        	curr0_0(optsplit,coll_mode,1:size(dke_out.curr0,1),1:size(dke_out.curr0,2),jdtn) = dke_out.curr0;
        	residu_0(optsplit,coll_mode,1:size(dke_out.residu_f,1),1:size(dke_out.residu_f,2),jdtn) = dke_out.residu_f;
        	%
        	transpfaste.Dr0 = [10];
        	[Znorm,Zcurr,ZP0,dke_out,radialDKE,equilDKE,momentumDKE,gridDKE,Zmomcoef,Zbouncecoef,Zmripple,mksa] = main_dke_yp(id_simul,psin_S,rho_S,dkepath,equil,dkeparam,dkedisplay,ohm,waves,transpfaste,ripple,[],[]);
        	%
        	normf0_10(optsplit,coll_mode,1:size(dke_out.normf0,1),1:size(dke_out.normf0,2),jdtn) = dke_out.normf0;
        	curr0_10(optsplit,coll_mode,1:size(dke_out.curr0,1),1:size(dke_out.curr0,2),jdtn) = dke_out.curr0;
        	residu_10(optsplit,coll_mode,1:size(dke_out.residu_f,1),1:size(dke_out.residu_f,2),jdtn) = dke_out.residu_f;
      		%
        	disp(['- opsplit: ',int2str(dkeparam.opsplit),',dtn: ',int2str(dtn_list(jdtn)),' done.'])
    	end
	end
end
%
save test_operator_splitting.mat
%
%************************************************************************************************************************************
%
% coll_mode = 0
%
figure(1),semilogy([1:1100]*1,squeeze(normf0_0(1,1,10,1:1100,1)),'r'),hold on
figure(1),semilogy([1:200]*10,squeeze(normf0_0(1,1,10,1:200,2)),'r-.')
figure(1),semilogy([1:110]*100,squeeze(normf0_0(1,1,10,1:110,3)),'r:')
figure(1),semilogy([1:100]*1000,squeeze(normf0_0(1,1,10,1:100,4)),'r*')
%
figure(2),semilogy([1:1100]*1,squeeze(normf0_0(2,1,10,1:1100,1)),'r'),hold on
figure(2),semilogy([1:200]*10,squeeze(normf0_0(2,1,10,1:200,2)),'r-.')
figure(2),semilogy([1:110]*100,squeeze(normf0_0(2,1,10,1:110,3)),'r:')
figure(2),semilogy([1:100]*1000,squeeze(normf0_0(2,1,10,2:100,4)),'r*')
%
figure(3),semilogy([1:1100]*1,squeeze(curr0_0(1,1,10,1:1100,1)),'b'),hold on
figure(3),semilogy([1:200]*10,squeeze(curr0_0(1,1,10,1:200,2)),'b-.')
figure(3),semilogy([1:110]*100,squeeze(curr0_0(1,1,10,1:110,3)),'b:')
figure(3),semilogy([1:100]*1000,squeeze(curr0_0(1,1,10,2:100,4)),'b*')
%
figure(4),semilogy([1:1100]*1,squeeze(curr0_0(2,1,10,1:1100,1)),'b'),hold on
figure(4),semilogy([1:200]*10,squeeze(curr0_0(2,1,10,1:200,2)),'b-.')
figure(4),semilogy([1:110]*100,squeeze(curr0_0(2,1,10,1:110,3)),'b:')
figure(4),semilogy([1:100]*1000,squeeze(curr0_0(2,1,10,2:100,4)),'b*')
%
figure(5),semilogy([1:1100]*1,squeeze(normf0_10(1,1,10,1:1100,1)),'r'),hold on
figure(5),semilogy([1:200]*10,squeeze(normf0_10(1,1,10,1:200,2)),'r-.')
figure(5),semilogy([1:110]*100,squeeze(normf0_10(1,1,10,1:110,3)),'r:')
figure(5),semilogy([1:100]*1000,squeeze(normf0_10(1,1,10,2:100,4)),'r*')
%
figure(6),semilogy([1:1100]*1,squeeze(normf0_10(2,1,10,1:1100,1)),'r'),hold on
figure(6),semilogy([1:200]*10,squeeze(normf0_10(2,1,10,1:200,2)),'r-.')
figure(6),semilogy([1:110]*100,squeeze(normf0_10(2,1,10,1:110,3)),'r:')
figure(6),semilogy([1:100]*1000,squeeze(normf0_10(2,1,10,2:100,4)),'r*')
%
figure(7),semilogy([1:1100]*1,squeeze(curr0_10(1,1,10,1:1100,1)),'b'),hold on
figure(7),semilogy([1:200]*10,squeeze(curr0_10(1,1,10,1:200,2)),'b-.')
figure(7),semilogy([1:110]*100,squeeze(curr0_10(1,1,10,1:110,3)),'b:')
figure(7),semilogy([1:100]*1000,squeeze(curr0_10(1,1,10,2:100,4)),'b*')
%
figure(8),semilogy([1:1100]*1,squeeze(curr0_10(2,1,10,1:1100,1)),'b'),hold on
figure(8),semilogy([1:200]*10,squeeze(curr0_10(2,1,10,1:200,2)),'b-.')
figure(8),semilogy([1:110]*100,squeeze(curr0_10(2,1,10,1:110,3)),'b:')
figure(8),semilogy([1:100]*1000,squeeze(curr0_10(2,1,10,2:100,4)),'b*')
%
% coll_mode = 2
%
figure(9),semilogy([1:1100]*1,squeeze(normf0_0(1,3,10,1:1100,1)),'r'),hold on
figure(9),semilogy([1:200]*10,squeeze(normf0_0(1,3,10,1:200,2)),'r-.')
figure(9),semilogy([1:110]*100,squeeze(normf0_0(1,3,10,1:110,3)),'r:')
figure(9),semilogy([1:100]*1000,squeeze(normf0_0(1,3,10,1:100,4)),'r*')
%
figure(10),semilogy([1:1100]*1,squeeze(normf0_0(2,3,10,1:1100,1)),'r'),hold on
figure(10),semilogy([1:200]*10,squeeze(normf0_0(2,3,10,1:200,2)),'r-.')
figure(10),semilogy([1:110]*100,squeeze(normf0_0(2,3,10,1:110,3)),'r:')
figure(10),semilogy([1:100]*1000,squeeze(normf0_0(2,3,10,2:100,4)),'r*')
%
figure(11),semilogy([1:1100]*1,squeeze(curr0_0(1,3,10,1:1100,1)),'b'),hold on
figure(11),semilogy([1:200]*10,squeeze(curr0_0(1,3,10,1:200,2)),'b-.')
figure(11),semilogy([1:110]*100,squeeze(curr0_0(1,3,10,1:110,3)),'b:')
figure(11),semilogy([1:100]*1000,squeeze(curr0_0(1,3,10,2:100,4)),'b*')
%
figure(12),semilogy([1:1100]*1,squeeze(curr0_0(2,3,10,1:1100,1)),'b'),hold on
figure(12),semilogy([1:200]*10,squeeze(curr0_0(2,3,10,1:200,2)),'b-.')
figure(12),semilogy([1:110]*100,squeeze(curr0_0(2,3,10,1:110,3)),'b:')
figure(12),semilogy([1:100]*1000,squeeze(curr0_0(2,3,10,2:100,4)),'b*')
%
figure(13),semilogy([1:1100]*1,squeeze(normf0_10(1,3,10,1:1100,1)),'r'),hold on
figure(13),semilogy([1:200]*10,squeeze(normf0_10(1,3,10,1:200,2)),'r-.')
figure(13),semilogy([1:110]*100,squeeze(normf0_10(1,3,10,1:110,3)),'r:')
figure(13),semilogy([1:100]*1000,squeeze(normf0_10(1,3,10,2:100,4)),'r*')
%
figure(14),semilogy([1:1100]*1,squeeze(normf0_10(2,3,10,1:1100,1)),'r'),hold on
figure(14),semilogy([1:200]*10,squeeze(normf0_10(2,3,10,1:200,2)),'r-.')
figure(14),semilogy([1:110]*100,squeeze(normf0_10(2,3,10,1:110,3)),'r:')
figure(14),semilogy([1:100]*1000,squeeze(normf0_10(2,3,10,2:100,4)),'r*')
%
figure(15),semilogy([1:1100]*1,squeeze(curr0_10(1,3,10,1:1100,1)),'b'),hold on
figure(15),semilogy([1:200]*10,squeeze(curr0_10(1,3,10,1:200,2)),'b-.')
figure(15),semilogy([1:110]*100,squeeze(curr0_10(1,3,10,1:110,3)),'b:')
figure(15),semilogy([1:100]*1000,squeeze(curr0_10(1,3,10,2:100,4)),'b*')
%
figure(16),semilogy([1:1100]*1,squeeze(curr0_10(2,3,10,1:1100,1)),'b'),hold on
figure(16),semilogy([1:200]*10,squeeze(curr0_10(2,3,10,1:200,2)),'b-.')
figure(16),semilogy([1:110]*100,squeeze(curr0_10(2,3,10,1:110,3)),'b:')
figure(16),semilogy([1:100]*1000,squeeze(curr0_10(2,3,10,2:100,4)),'b*')
%











return

for iDr0 = 1:length(Dr0_mask),
    leg{iDr0} = ['D_{\psi\psi} = ',num2str(Dr0_list(Dr0_mask(iDr0))),' m^{2}/s'];
end
%
figure(1),clf
%
xlim = [0,1];
ylim = [0,0.004];
xlab = 'r/a_p';
ylab = 'j';
tit = '';
%
%for iDr0 = 1:length(Dr0_list) - 1, 
%    graph1D_jd(equilDKE.xrho,j(:,iDr0),i,0,0,'','','',NaN,xlim,ylim,'-','none',NaN,2,20,gca);
%end
graph1D_jd(equilDKE.xrho,j(:,Dr0_mask),0,0,xlab,ylab,tit,leg,xlim,ylim,'-','none',NaN,2,20,gca,0.9,0.7,0.7);
graph1D_jd(equilDKE.xrho,besselj(0,2.4*equilDKE.xrho)*j(1,Dr0_mask(end)),0,0,'','','',NaN,xlim,ylim,'--','none','k',2,20);
%
set(gca,'ytick',[0:0.25:1]*ylim(2))
set(gca,'xtick',[0:0.2:1]*xlim(2))

return

%
figure(2),clf
%
xlim = [0.01,100];
ylim = [0,200];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'CPU time (s)';
tit = '';
%
graph1D_jd(Dr0_list(2:end),tCPU(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(3),clf
%
xlim = [0.01,100];
ylim = [0,200];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'FPE calculation time (s)';
tit = '';
%
graph1D_jd(Dr0_list(2:end),tDKE(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(4),clf
%
xlim = [0.01,100];
ylim = NaN;%[0,200];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'LU matrix size (MBytes)';
tit = '';
%
graph1D_jd(Dr0_list(2:end),memory(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
%
%set(gca,'ytick',[0:0.2:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(5),clf
%
xlim = [0.01,100];
ylim = [0,0.06];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'I (MA)';
tit = '';
%
graph1D_jd(Dr0_list(2:end),-Itot(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.25:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(6),clf
%
xlim = [0.01,100];
ylim = [0,0.004];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'P/(2\piR_p) (MW/m)';
tit = '';
%
graph1D_jd(Dr0_list(2:end),Ptot_2piRp(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.25:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
figure(7),clf
%
xlim = [0.01,100];
ylim = [0,6];
xlab = 'D_{\psi\psi} (m^{2}/s)';
ylab = 'n_{19}IR_p/P';
tit = '';
%
graph1D_jd(Dr0_list(2:end),-Eta(2:end),1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
%
set(gca,'ytick',[0:0.25:1]*ylim(2))
set(gca,'xtick',[0.01,0.1,1,10,100])
set(gca,'XMinorGrid','off')
set(gca,'XMinorTick','on')
%
print_jd(2,'fig_transp_nobounce_j','.',1)
print_jd(2,'fig_transp_nobounce_cpu','.',2)
print_jd(2,'fig_transp_nobounce_fpe','.',3)
print_jd(2,'fig_transp_nobounce_memory','.',4)
print_jd(2,'fig_transp_nobounce_I','.',5)
print_jd(2,'fig_transp_nobounce_P','.',6)
print_jd(2,'fig_transp_nobounce_Eta','.',7)
%
if opt_proc > 0 & strcmp(computer,'GLNXA64'), 
    %
    figure(8),clf
    %
    xlim = [0:10];
    ylim = NaN;%[0,0.1];
    xlab = 'D_{\psi\psi} (m^{2}/s)';
    ylab = 'Number of processors';
    tit = '';
    %
    graph1D_jd(nproc_list,tCPU_nproc,1,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,20,gca,0.9,0.7,0.7);
    %
    set(gca,'ytick',[0:0.2:1]*ylim(2))
    set(gca,'xtick',[0:0.2:1]*xlim(2))
    %
    print_jd(2,'fig_transp_nobounce_cpu_proc','.',8)
    %
end
%
%************************************************************************************************************************************
eval(['save ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
info_dke_yp(2,['Data saved in ',path_simul,'DKE_RESULTS_',id_equil,'_',id_simul,'.mat']);
