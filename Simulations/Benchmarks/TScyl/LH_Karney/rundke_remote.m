function rundke_remote(remlist,link_mode,remtimout)
%
% This function runs the LH Karney benchmark remotely on a selection of hosts. 
%   - If it is called with remtimout > 0, the function waits for each calculation to be completed 
%   - If it is called with remtimout = 0, the function saves the jobs in a LUKE_RESULTS file
%   - If it is called without arguments, it loads the previously saved LUKE_RESULTS file if it exists, and check the results.
%
% INPUTS :
%       - remlist : remote profile selection
%           o NaN : (default) test all profiles
%           o []  : prompt for profile selection
%           o ex : [1:3,6,8] : profile selection
%       - link_mode : connection mode prescription
%           o -1  : local profiles only
%           o NaN : (default) use value from remote.link_mode
%           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%           o 0   : ssh key pair enforced
%           o 1   : ssh bridge enforced
%           o 2   : url/ftp bridge enforced
%       - remtimout : timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
%
if nargin < 3,
    remtimout = 10;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
end
%    
if nargin < 2 || (~isempty(link_mode) && (~isnumeric(link_mode) || ~isscalar(link_mode) || ~any(link_mode == [0:2]))),
    link_mode = NaN;% bridge mode : (NaN) follow remote, ([]) priority to ssh, (0) ssh only, (1) bridge only
end
%
if nargin < 1 || (~isempty(remlist) && ~isnumeric(remlist)),
    remlist = [];% Interactive mode
end
%
rempause = 1/60;%pause between job checks (in minutes) (only for remtimout > 0)
%
debugmode = 0;% debug mode (0) off (1) on
cleanmode = 2;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
luke_memory = 2000;% job memory in mb
luke_walltime = '01:00';% job walltime in hours (number or full description '00:00' for hours and minutes
enforce = 1;% (0) : exit if remote calculation failed, (1): if remote calculation failed, it is done locally
%
opt.save = 1;% save individual results in LUKE_RESULTS files (WARNING : Use absolute simul.path to save locally with local cluster)
%
mdce_opt = 0;% option for testing distributed computing inside remote calculation
%
localdatadir = 'LUKE_RESULTS_files_remote/';
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
dkeparam.rho_S = rho_S;% radial flux grid points enforced
dkeparam.psin_S = psin_S;% radial flux grid points enforced
%
dkeparam.clustermode.coll_dke_jd.scheduler.mode = mdce_opt;
dkeparam.clustermode.eecoll_dke_yp.scheduler.mode = mdce_opt;
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
opt.fields = {'Znorm','Zcurr','ZP0'};% select fields to be returned from lukestructs. Use NaN to return all fields.
%
% generate luke_inputs structure
%
lukestruct.equil = equil;
lukestruct.dkeparam = dkeparam;
lukestruct.dkedisplay = dkedisplay;
lukestruct.waves = waves;
lukestruct.opt = opt;
%
% local calculation
%
disp('--> Local calculation')
%
lukestruct_0 = run_lukert(lukestruct,dkepath);
%
Znorm_0 = lukestruct_0.output.Znorm;
Zcurr_0 = lukestruct_0.output.Zcurr;
ZP0_0 = lukestruct_0.output.ZP0;
%
% simulation filename
%
filename = [path_simul,'LUKE_RESULTS_',id_equil,'_',id_simul,'.mat'];
%
% check if current jobs exists to load possible existing jobs
%
if nargin == 0 && exist(filename,'file'),% load existing simulation
    %
    load(filename,'lukestructs','remlist','link_mode','remtimout');
    %
    dkepath = setpath_luke_jd('',link_mode);
    %
    nrem = length(lukestructs);%remlist
    %
else% new simulation
    %
    % profiles in dkepath.remote tested
    %
    if ~exist('dkepath','var'),
        dkepath = setpath_luke_jd('',link_mode,0);
    else
        dkepath = setpath_luke_jd(dkepath,link_mode,0);
    end
    %
    if isfield(dkepath,'remote'),
        nrem = length(dkepath.remote);
        if isempty(remlist),
            remlist = input_dke_yp('Please identify profiles to be tested.',1:nrem,[1;nrem]);
        elseif isnan(remlist),
            remlist = 1:nrem;
        else
            remlist(remlist > nrem) = [];
        end
    else
        remlist = [];
    end
    %
    nrem = length(remlist);
    %
    dkepath.clustermode.run_lukert.scheduler.mode = 0;%no distribution of LUKE on the remote machine
    dkepath.clustermode.run_lukert.scheduler.remtimout = remtimout;
    dkepath.clustermode.run_lukert.scheduler.rempause = rempause;
    dkepath.clustermode.run_lukert.scheduler.memory = luke_memory;
    dkepath.clustermode.run_lukert.scheduler.walltime = luke_walltime;
    dkepath.clustermode.run_lukert.scheduler.debugmode = debugmode;
    dkepath.clustermode.run_lukert.scheduler.cleanmode = cleanmode;
    dkepath.clustermode.run_lukert.scheduler.enforce = enforce;% exit if remote calculation failed 
    if opt.save,
        dkepath.clustermode.run_lukert.scheduler.localdatadir = localdatadir;
        if exist(localdatadir,'dir') && length(dir(localdatadir)) > 2,
            delete([localdatadir,'*']);
        end
    end
    %
    lukestructs = repmat({lukestruct},[1,nrem]);
end
%
for remnum = 1:nrem,
    %
    if ~isnan(remlist), % new calculation
        %
        dkepath.clustermode.run_lukert.scheduler.remnum = remlist(remnum);
        %
        lukestructs{remnum}.simul.locid = [id_simul,'_',num2str(remlist(remnum))];
        %
        disp(['--> Calculation with remote number ',num2str(remlist(remnum)),', host: ',dkepath.remote(remlist(remnum)).host])
    end
    %
    lukestructs{remnum} = run_lukert(lukestructs{remnum},dkepath);
    %
end
%
Znorm = cell(1,nrem);
Zcurr = cell(1,nrem);
ZP0 = cell(1,nrem);
%
flag_running = false(1,nrem);
luke_warning = cell(1,nrem);
%
for remnum = 1:nrem,
    if isfield(lukestructs{remnum},'output'),
        if isfield(lukestructs{remnum},'warning')
            luke_warning{remnum} = [' **** WARNING : ',lukestructs{remnum}.warning];
        end
        Znorm{remnum} = lukestructs{remnum}.output.Znorm;
        Zcurr{remnum} = lukestructs{remnum}.output.Zcurr;
        ZP0{remnum} = lukestructs{remnum}.output.ZP0;
    elseif isfield(lukestructs{remnum},'job'),
        flag_running(remnum) = true;
    end
end
%
j_r_k = '0.003732';
p_r_k = '0.0001256';
eta_r_k = '29.72';
%
%************************************************************************************************************************************
%
format
%
if ~isempty(link_mode) && ~isnan(link_mode),
    link_modestr = ['_link_mode_',num2str(link_mode)];
else
    link_modestr = '';
end
%
diaryname = ['res_karney_remote_',datestr(now,29),link_modestr,'.log'];
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
disp(' Remote profiles tested : ')
disp(' ')
%
for remnum = 1:nrem,
    info_dke_yp(4,['#',num2str(remnum),' : ',dkepath.profilestr{remlist(remnum)}]);
end
disp(' ')

disp(['----------------------'])
disp(['Comparison LUKE/Karney - Relativistic case (4,7,1) - with tn = ',int2str(dkeparam.tn),', dtn = ',int2str(dkeparam.dtn),' and nit_f = ',int2str(dkeparam.nit_f)])
disp(['----------------------'])
%
disp(['Local calculation : j = ',num2str(Zcurr_0.x_0),'/',j_r_k,' ; P = ',num2str(ZP0_0.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(Zcurr_0.x_0./ZP0_0.x_rf_fsav),'/',eta_r_k]) 
%
for remnum = 1:nrem,
    if ~isempty(Zcurr{remnum}),
        disp(['Remote calc. # ',num2str(remnum),' : j = ',num2str(Zcurr{remnum}.x_0),'/',j_r_k,' ; P = ',num2str(ZP0{remnum}.x_rf_fsav),'/',p_r_k,' ; j/P = ',num2str(Zcurr{remnum}.x_0./ZP0{remnum}.x_rf_fsav),'/',eta_r_k,luke_warning{remnum}]) 
    elseif flag_running(remnum),
        disp(['Remote calc. # ',num2str(remnum),' : running'])
    else
        disp(['Remote calc. # ',num2str(remnum),' : failed'])
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
    if ~any(flag_running),
        delete(filename);% jobs completed, file deleted
    else
        save(filename);% file saved for future check
        info_dke_yp(2,['Data saved in ',filename]);
    end
end
%
