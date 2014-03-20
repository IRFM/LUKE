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
remtimout = 0;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
rempause = 1/60;%pause between job checks (in minutes) (only for remtimout > 0)
remstart = 0;% (1) start new simulation; (0) check older simulation (only for remtimout = 0)
remnum = 1;% remote profile number. Use 0 for local sequential calculations
remdebugmode = 1;%1;% debug mode (0) off (1) on
remclean = 2;%0;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
%
opt.save = 0;% save individual results in LUKE_RESULTS files (WARNING : Use absolute simul.path to save locally with local cluster)
%
%
mdce_opt = 0;% option for testing distributed computing inside remote calculation
%
luke_memory = 2000;% job memory in mb
luke_walltime = 1;% job walltime in hours
%
p_opt = -1;
% 
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_Zi';%Simulation ID
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
%************************************************************************************************************************************
%************************************************************************************************************************************
%************************************************************************************************************************************
%
[dkepath,equil,dkeparam,dkedisplay] = load_structures_yp('dkepath',id_path,path_path,'equil',id_equil,path_equil,'dkeparam',id_dkeparam,path_dkeparam,'dkedisplay',id_display,path_display);
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
dkeparam.tn = [50000,100000];% 2 time steps to tn=100000 best for asymptotic solution
dkeparam.rt_mode = 1;% necessary to use run_lukert
%
dkeparam.np_S = 201;
dkeparam.nmhu_S = 201;
%
dkeparam.rho_S = rho_S;% radial flux grid points enforced
dkeparam.psin_S = psin_S;% radial flux grid points enforced
%
dkeparam.clustermode.coll_dke_jd.scheduler.mode = mdce_opt;
dkeparam.clustermode.eecoll_dke_yp.scheduler.mode = mdce_opt;
%
dkeparam.luke_memory = luke_memory;% job memory in mb
dkeparam.luke_walltime = luke_walltime;% job walltime in hours
%
betath = 0.001;
%
[qe,me,mp,mn,e0,mu0,re,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
opt.fields = {'Zcurr','ZP0'};% select fields to be returned from lukestructs. Use NaN to return all fields.
%
Zi_list = [1:20*0+4];
coll_mode_list = [0:2];
%
nZi = length(Zi_list);
ncoll = length(coll_mode_list);
%
% simulation filename
%
filename = [path_simul,'LUKE_RESULTS_',id_equil,'_',id_simul,'.mat'];
%
% check if current jobs exists to load possible existing jobs
%
if remtimout == 0 && remstart == 0 && exist(filename,'file'),% load existing simulation
    %
    load(filename,'lukestructs');
    %
else% new simulation
    %
    lukestructs = cell(ncoll,nZi);
    %
    for iZi = 1:nZi,
        for icoll = 1:ncoll,
            %
            Zi = Zi_list(iZi);
            equil.zZi = [1,1,1,Zi];
            equil.pzni = [0;0;0;1/Zi]*equil.pne;
            %
            waves{1} = make_idealLHwave_jd(equil,wavestruct);
            %
            dkeparam.coll_mode = coll_mode_list(icoll);% Relativistic Maxwellian background
            %
            % generate initial luke_inputs structure
            %
            lukestructs{icoll,iZi}.simul.path = path_simul;
            lukestructs{icoll,iZi}.simul.locid = [id_simul,'_coll_',num2str(coll_mode_list(icoll)),'_Zi_',num2str(Zi)];
            lukestructs{icoll,iZi}.equil = equil;
            lukestructs{icoll,iZi}.dkeparam = dkeparam;
            lukestructs{icoll,iZi}.dkedisplay = dkedisplay;
            lukestructs{icoll,iZi}.waves = waves;
            lukestructs{icoll,iZi}.opt = opt;
            %
        end
    end
end
%
dkepath.remtimout = remtimout;% timeout in minutes
dkepath.rempause = rempause;% pause between job checks (in minutes) (only for remtimout > 0)
dkepath.remenforce = 0;% exit if remote calculation failed 
dkepath.remnum = remnum;% remote profile number
dkepath.debugmode = remdebugmode;% debug mode 
dkepath.clean = remclean;% clean mode 
%
lukestructs = run_lukert(lukestructs,dkepath);
%
j = NaN(ncoll,nZi);
P = NaN(ncoll,nZi);
%
plotresults = 0;
%
for iZi = 1:nZi,
    for icoll = 1:ncoll,
        if isfield(lukestructs{icoll,iZi},'output'),
            %
            plotresults = 1;
            %
            j(icoll,iZi) = lukestructs{icoll,iZi}.output.Zcurr.x_0;
            P(icoll,iZi) = lukestructs{icoll,iZi}.output.ZP0.x_rf_fsav;
        end
    end
end
%
eta = j./P;
%
j_0_nr_Karney_1 = 0.05759;
P_0_nr_Karney_1 = 0.004012;
eta_0_nr_Karney_1 = 14.35;
%
j_2_nr_Karney_1 = 0.07092;
P_2_nr_Karney_1 = 0.004294;
eta_2_nr_Karney_1 = 16.52;
%
%eta_0_nr_Karney = eta_0_nr_Karney_1*6./(5 + Zi_list);
eta_2_nr_Karney = eta_2_nr_Karney_1*6./(5 + Zi_list);
%
%************************************************************************************************************************************
%
if plotresults,
    %
    figure(1),clf
    %
    %leg = {'Linearized','High v limit','Maxwellian NR','Maxwellian'};
    leg = {'Linearized','High v limit','Maxwellian'};
    xlim = [0,max(Zi_list)];
    ylim = [0,0.1];
    xlab = 'Z_i';
    ylab = 'j';
    tit = '';
    siz = 20+14i;
    %
    graph1D_jd(Zi_list,j(3,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
    graph1D_jd(Zi_list,j(2,:),0,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
    graph1D_jd(Zi_list,j(1,:),0,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
    %graph1D_jd(xlim,[j_2_nr_Karney_1,j_2_nr_Karney_1],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
    %graph1D_jd(xlim,[j_0_nr_Karney_1,j_0_nr_Karney_1],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
    %
    set(gca,'ytick',[0:0.2:1]*ylim(2))
    set(gca,'xtick',[0:0.2:1]*xlim(2))
    %
    figure(2),clf
    %
    ylim = [0,0.02];
    ylab = 'P';
    %
    graph1D_jd(Zi_list,P(3,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
    graph1D_jd(Zi_list,P(2,:),0,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
    graph1D_jd(Zi_list,P(1,:),0,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
    %graph1D_jd(xlim,[P_2_nr_Karney_1,P_2_nr_Karney_1],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
    %graph1D_jd(xlim,[P_0_nr_Karney_1,P_0_nr_Karney_1],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
    %
    set(gca,'ytick',[0:0.2:1]*ylim(2))
    set(gca,'xtick',[0:0.2:1]*xlim(2))
    %
    figure(3),clf
    %
    ylim = [0,20];
    ylab = 'j/P';
    %
    graph1D_jd(Zi_list,eta(3,:),0,0,xlab,ylab,tit,NaN,xlim,ylim,'-','none','r',2,siz,gca,0.9,0.7,0.7);
    graph1D_jd(Zi_list,eta(2,:),0,0,'','','',NaN,xlim,ylim,'-','none','b',2,siz,gca);
    graph1D_jd(Zi_list,eta(1,:),0,0,'','','',leg,xlim,ylim,'-','none','g',2,siz,gca);
    graph1D_jd(Zi_list,eta_2_nr_Karney,0,0,'','','',NaN,xlim,ylim,'--','none','k',0.5,siz,gca);
    %graph1D_jd(Zi_list,eta_0_nr_Karney,0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
    %
    set(gca,'ytick',[0:0.2:1]*ylim(2))
    set(gca,'xtick',[0:0.2:1]*xlim(2))
    %
    print_jd(p_opt,'fig_j_Zi','./figures',1)
    print_jd(p_opt,'fig_P_Zi','./figures',2)
    print_jd(p_opt,'fig_eta_Zi','./figures',3)
    %
end
%
%************************************************************************************************************************************
%
save(filename,'-v7.3');
info_dke_yp(2,['Data saved in ',filename]);

