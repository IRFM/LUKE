function rundke_Zi_remote(remtimout,link_mode,opt_save,display_mode,plot_results)
%
% This function is used to test the use of the MDCE toolbox within run_lukert
% A loop is created over various collision operators and ion charges
%
%   - If it is called with remtimout > 0, the function waits for each calculation to be completed 
%   - If it is called with remtimout = 0, the function saves the job in a LUKE_RESULTS file
%   - If it is called without arguments, it loads the previously saved LUKE_RESULTS file if it exists, and check the results.
%
% INPUTS :
%       - remtimout : timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
%       - link_mode : connection mode prescription
%           o -2  : disable remote profiles
%           o -1  : local profiles only
%           o NaN : (default) use value from remote.link_mode
%           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%           o 0   : ssh key pair enforced
%           o 1   : ssh bridge enforced
%           o 2   : url/ftp bridge enforced
%       - opt_save
%           o 0   : no not save LUKE_RESULTS files (default)
%           o 1   : save LUKE_RESULTS files in folder LUKE_RESULTS_files/
%       - display_mode
%           o 0   : no display
%           o 1   : display general info and time evoution (default)
%           o 2   : display all MDCE steps
%       - plot_results : flag to plot results (default : false)
%
if nargin < 5,
    plot_results = false;% flag to plot results
end
%
if nargin < 4,
    display_mode = 1;
end
%
if nargin < 3,
    opt_save = 0;
end
%
if nargin < 2 || (~isempty(link_mode) && (~isnumeric(link_mode) || ~isscalar(link_mode) || ~any(link_mode == [-1:2]))),
    link_mode = NaN;% bridge mode : (NaN) follow remote, ([]) priority to ssh, (0) ssh only, (1) bridge only
end
%
if nargin < 1,
    remtimout = 0;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
end
%
rempause = 1/60;%pause between job checks (in minutes) (only for remtimout > 0)
%
debugmode = 0;%1;% debug mode (0) off (1) on
cleanmode = 2;%0;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
luke_memory = 2000;% job memory in mb
luke_walltime = 1;% job walltime in hours
enforce = 0;% (0) : exit if remote calculation failed, (1): if remote calculation failed, it is done locally
%
opt.save = opt_save;% save individual results in LUKE_RESULTS files (WARNING : Use absolute simul.path to save locally with local cluster)
%
mdce_opt = 0;% option for testing distributed computing inside remote calculation
%
p_opt = -1;
%
localdatadir = 'LUKE_RESULTS_files_Zi_remote/';
%
% ***********************This part must be specified by the user, run make files if necessary) *****************************
%
id_simul = 'LH_karney_Zi_remote';%Simulation ID
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
betath = 0.001;
%
[~,~,~,~,~,~,~,mc2] = pc_dke_yp;%Universal physics constants
%
equil.pTe = betath^2*mc2*ones(size(equil.pTe));
equil.pzTi = betath^2*mc2*ones(size(equil.pzTi));
%equil.pzTi = 1e-10*ones(size(equil.pzTi));
%
opt.fields = {'Zcurr','ZP0'};% select fields to be returned from lukestructs. Use NaN to return all fields.
%
Zi_list = [1,100];%Z = 74 is tungsten fully stripped ion
coll_mode_list = 0:2;
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
if nargin == 0 && exist(filename,'file'),% load existing simulation
    %
    load(filename,'lukestructs','remtimout','link_mode','plot_results','remnum','dist_mode','mdce_mode');
    %
else% new simulation
    %
    % determite remote and distributed profiles
    %
   % if ~exist('dkepath','var'),
   %     dkepath = setpath_luke_jd('',link_mode,0);
   % else
   %     dkepath = setpath_luke_jd(dkepath,link_mode,0);
   % end
    %
    if ~isempty(dkepath.remote),
        remopt = input_dke_yp(['Do you want to transfer the distributed calculation to a remote host (y/n)'],'n',{'y','n'});
        disp(' ')
    else
        remopt = 'n';
    end
    %
    if remopt == 'y',% use of mdce_remote
        remnum = iselect_jd(dkepath.profilestr,'Please select the host for the distributed calculation ?',0,struct,1);
        disp(' ')
        dist_mode = NaN;
        mdce_mode = input_dke_yp(['Please select a mode for the distribution on host ',dkepath.profilestr{remnum},':\n(0) sequential \n(1) jobcomputing \n(2) parcomputing \n(3) remcomputing \n'],0,0:3);
    else% direct distribution from localhost
        remnum = 0;
        dist_mode = iselect_jd(dkepath.distprofiles,'Please select a mode for the distribution from the local host ?',0,struct,1);
        if dist_mode > 3,
            mdce_mode = 3 - dist_mode;
        else
            mdce_mode = dist_mode - 1;
        end
    end
    %
    dkepath.clustermode.run_lukert.scheduler.remnum = remnum;
    dkepath.clustermode.run_lukert.scheduler.mode = mdce_mode;
    dkepath.clustermode.run_lukert.scheduler.remtimout = remtimout;
    dkepath.clustermode.run_lukert.scheduler.rempause = rempause;
    dkepath.clustermode.run_lukert.scheduler.memory = luke_memory;
    dkepath.clustermode.run_lukert.scheduler.walltime = luke_walltime;
    dkepath.clustermode.run_lukert.scheduler.debugmode = debugmode;
    dkepath.clustermode.run_lukert.scheduler.display = display_mode;
    dkepath.clustermode.run_lukert.scheduler.cleanmode = cleanmode;
    dkepath.clustermode.run_lukert.scheduler.enforce = enforce;% exit if remote calculation failed 
    if opt.save,
        dkepath.clustermode.run_lukert.scheduler.localdatadir = localdatadir;
        if exist(localdatadir,'dir') && length(dir(localdatadir)) > 2,
            delete([localdatadir,'*']);
        end
    end
    %
    % generate luke_inputs structure
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
lukestructs = run_lukert(lukestructs,dkepath);
%
j = NaN(ncoll,nZi);
P = NaN(ncoll,nZi);
%
flag_running = true(ncoll,nZi);
flag_error = true(ncoll,nZi);;
luke_warning = cell(ncoll,nZi);
%
for iZi = 1:nZi,
    for icoll = 1:ncoll,
        if isfield(lukestructs{icoll,iZi},'output'),
            %
            j(icoll,iZi) = lukestructs{icoll,iZi}.output.Zcurr.x_0;
            P(icoll,iZi) = lukestructs{icoll,iZi}.output.ZP0.x_rf_fsav;
            %
            flag_running(icoll,iZi) = false;
            flag_error(icoll,iZi) = false;
            %
            if isfield(lukestructs{icoll,iZi},'warning')
                luke_warning{icoll,iZi} = [' **** WARNING : ',lukestructs{icoll,iZi}.warning];
            end
        elseif isfield(lukestructs{icoll,iZi},'err'),
            flag_running(icoll,iZi) = false;
            flag_error(icoll,iZi) = true;
        end
    end
end
%
eta = j./P;
%
j_nr_k = NaN(ncoll,nZi);
P_nr_k = NaN(ncoll,nZi);
eta_nr_k = NaN(ncoll,nZi);
%
j_nr_k(1,1) = 0.05759;
P_nr_k(1,1) = 0.004012;
eta_nr_k(1,1) = 14.35;
%
j_nr_k(3,1) = 0.07092;
P_nr_k(3,1) = 0.004294;
eta_nr_k(3,1) = 16.52;
%
eta_0_nr_Karney = eta_nr_k(1,1)*6./(5 + Zi_list);
eta_2_nr_Karney = eta_nr_k(3,1)*6./(5 + Zi_list);
%
%************************************************************************************************************************************
%
if ~any(flag_running(:)) && plot_results,
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
    %graph1D_jd(xlim,[j_nr_k(3,:),j_nr_k(3,:)],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
    %graph1D_jd(xlim,[j_nr_k(1,1),j_nr_k(1,1)],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
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
    %graph1D_jd(xlim,[P_nr_k(3,1),P_nr_k(3,1)],0,0,'','','',NaN,xlim,ylim,'--','none','r',2,siz,gca);
    %graph1D_jd(xlim,[P_nr_k(1,1),P_nr_k(1,1)],0,0,'','','',NaN,xlim,ylim,'--','none','m',2,siz,gca);
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
    graph1D_jd(Zi_list,eta_2_nr_Karney,0,0,'','','',NaN,xlim,ylim,'--','none','b',0.5,siz,gca);
    graph1D_jd(Zi_list,eta_0_nr_Karney,0,0,'','','',NaN,xlim,ylim,'--','none','r',0.5,siz,gca);
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
format
%
if ~isempty(link_mode) && ~isnan(link_mode) && link_mode >= 0,
    link_modestr = ['_link_mode_',num2str(link_mode)];
elseif ~isempty(link_mode) && link_mode == -1,
    link_modestr = '_noremote';
else
    link_modestr = '';
end
%
diaryname = ['res_karney_Zi_remote_',datestr(now,29),'_remnum_',num2str(remnum),'_mdce_',num2str(mdce_mode),link_modestr,'.log'];
%
if input_dke_yp(['Do you want to save the results in the log file ',diaryname,' ? (y/n)'],'y',{'y','n'}) == 'y',
    %
    if exist(diaryname,'file'),
        delete(diaryname);
    end
    %
    diary(diaryname);
    %
else
    diaryname = '';
end
%
disp(' ')
if remnum == 0,
    disp(['Calculation distributed locally with the MDCE profile : ',dkepath.distprofiles{dist_mode}]);
else
    disp(['Calculation distributed on remote host : ',dkepath.profilestr{remnum},' with MDCE mode ',num2str(mdce_mode)]);
end
disp(' ')
%

disp('----------------------')
disp(['Comparison LUKE/Karney - Non relativistic case (3,5,1) - with tn = ',int2str(dkeparam.tn),', dtn = ',int2str(dkeparam.dtn),' and nit_f = ',int2str(dkeparam.nit_f)])
disp('----------------------')
%
for iZi = [1,nZi],
    for icoll = 1:ncoll,
        casestr = ['Zi = ',num2str(Zi_list(iZi)),' ; coll mode = ',num2str(coll_mode_list(icoll))];
        if flag_running(icoll,iZi),
            disp([casestr,' : running'])
        elseif ~isnan(j(icoll,iZi)),
            disp([casestr,' : j = ',num2str(j(icoll,iZi)),'/',num2str(j_nr_k(icoll,iZi)),' ; P = ',num2str(P(icoll,iZi)),'/',num2str(P_nr_k(icoll,iZi)),' ; j/P = ',num2str(eta(icoll,iZi)),'/',num2str(eta_nr_k(icoll,iZi)),luke_warning{icoll,iZi}]) 
        else      
            disp([casestr,' : failed'])
        end
    end
end
%
if ~isempty(diaryname),
    diary off
end
%
%************************************************************************************************************************************
%
if remtimout == 0,
    if ~any(flag_running(:)) && ~any(flag_error(:)),
        if exist(filename)
            delete(filename);% jobs completed, file deleted
        end
    else
        if any(flag_error(:)),
            save(filename);% file saved for future check
            info_dke_yp(2,['Data saved in ',filename]);
        end
    end
end
