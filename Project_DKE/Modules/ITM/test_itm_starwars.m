%LUKE - Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%
%Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%Part of this script may be used readily in the KEPLER actor
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
clear all
close all
clc
%
% Computing parameters
%
remdebugmode = 0;% debug mode (0) off (1) on
remclean = 2;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
%luke_memory = 2000;% job memory in mb
%luke_walltime = 1;%job walltime in hours
enforce = 0;% exit if remote calculation failed 
%
opt_struct = 0;%(0) light version, compatible with fluctuations, proc_luke and runhxr, (1) : heavy version, all fields are kept except XYD_rf and gridindex_rf (rarely used, except for looking for bug), (2) : full version,all fields are kept.
%
opt.save = 1;% (1): save LUKE_RESULTS or return error in localdatadir (0): return results or error
opt.localdatadir = 'results';% local directory where LUKE_RESULTS is saved
opt.fields = {'Zcurr','ZP0','dke_out'};% select fields to be returned from lukestructs. Use NaN to return all fields.
opt.proc = struct;%postprocessing done remotely
opt.backup = 0;% (1) save fluctuation time steps (0) do not save
opt.waves = 0;%(-1) waves are not saved in "wave_results/" and not stored in dke_out. In this case, C3PO must be rerun to see the rays (0) waves are stored in dke_out and saved in LUKE_RESULTS, (1) waves are saved in "wave_results/" but not stored in dke_out
opt.saveinputs = 0;% (1) save input structures in .mat files before starting (0) do not save
%
svnremoteupdate = 0;%(1) svn remote update on the ITM gateway (0) : no svn remote update on the ITM gateway
%
rho_S = 31;%101;
%
euitm.loadlocalfile = 1;%(1): load euitm data in local file if it exists (otherwise read data in MDS+ database), (0) do not load locally (in MDS+ database only)
euitm.savelocalfile = 1;%(2): save euitm data in local file and in MDS+ database (1): save euitm data in local file but not in MDS+ database, (0) do not save locally (in MDS+ database only)
%
% remote profile for load data from EUITM MDS+ database only
%
remoteprofile = 'EFDA_ITM';
scheduler = 'direct';
profilename = 'yvesp';
duplicate = 'true';%if true, don't use the remote LUKE_ITM toolbox
%
% Simulation parameters (EC17 paper parameters)
%
%   t(s)	P_EL25(W)	P_EL40(W)	P_UL(W)
%---------------------------------------------
%   0       1e6         0           0
%   1       0           1e6         0
%   2       0           0           1e6
%   3       1           0           0
%   4       0           1           0
%   5       0           0           1
%   6       1e6         1e6         0
%
% The first three slices and the last one match the original data used for the benchmark 
% (still saved as shot 2, run 551). The three additional slices are a copy of the first three, 
% with 1W instead of 1MW at the antenna.
%
mds_ver = '4.10a';%'4.09a';%File format version in EUITM MDS+ database
%
machine = 'test';
shot = 2;
run= 601;
run_out= 602;
timeslice = NaN;%[0,1,2,3,4,5,6];%time slice does not work
iter = 1;
occurrence_out = 0;
%
time_interp = 1;
%
CPOs = {'equilibrium','coreprof','antennas'};
%
occurrence_eq = 0;%equilibrium CPO occurence
occurrence_cp = 0;%coreprof CPO occurence
occurrence_an = 0;%antenna CPO occurence
%
%----------------------------------------------------------------------------------------------
%
CPO_occurrences = [occurrence_eq,occurrence_cp,occurrence_an];
%
dataname = dataname_ITM(machine,shot,run,timeslice,time_interp);
filename = [pwd,'/LUKE_RESULTS_',dataname,'.mat'];
%
if exist(filename,'file'),
	cleansim = input_dke_yp(['Do you to clean the existing simulation: ',dataname,' (y/n)'],'n',{'y','n'});
	disp(' ')
    if cleansim == 'y',% clean simulation
        delete(filename)
    end
end
%
if ~exist(filename,'file'),% load existing simulation    
    %
    dkepath = setpath_luke_jd('');
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
        disp(' ')
        %
        remtimout = input_dke_yp(['Timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again'],0,0:1000);
        disp(' ')
        %
        if remtimout > 0,
            rempause = input_dke_yp(['Pause between job checks (in minutes)'],5,0:30);
        else
            rempause = 5;
        end
        %
    else% direct distribution from localhost
        remnum = 0;
        remtimout = input_dke_yp(['Timeout for remote calculations, in minutes.'],100,1:1000);
        disp(' ')
        %
        rempause = input_dke_yp(['Pause between job checks (in minutes)'],5,0:30);
        disp(' ')
        %
        dist_mode = iselect_jd(dkepath.distprofiles,'Please select a mode for the distribution from the local host ?',0,struct,1);
        disp(' ')
        if dist_mode > 3,
            mdce_mode = 3 - dist_mode;
        else
            mdce_mode = dist_mode - 1;
        end
    end 
    %
    remstart = 0;% (1) start new simulation; (0) check older simulation (only for remtimout = 0)
    %
    opts.remnum = remnum;%3;% remote profile number. Use 0 for local sequential calculations (for LUKE only from ITM gateway). (> 0 transfer before distribution, <0 distribution before transfer)
    opts.remmdce = mdce_mode;%distribution mode of LUKE on the remote machine (0) sequential, (1) jobcomputing, (2) parcomputing, (3) remcomputing 
    opts.remtimout = remtimout;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
    opts.rempause = rempause;% pause between job checks (in minutes) (only for remtimout > 0)
    opts.remstart = remstart;% (1) start new simulation; (0) check older simulation (only for remtimout = 0)
    opts.remdebugmode = remdebugmode;% debug mode (0) off (1) on
    opts.remclean = remclean;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
    %opts.luke_memory = luke_memory;% job memory in mb
    %opts.luke_walltime = luke_walltime;%job walltime in hours
    opts.enforce = enforce;% exit if remote calculation failed 
    %
    opts.opt_struct = opt_struct;%(0) light version, compatible with fluctuations, proc_luke and runhxr, (1) : heavy version, all fields are kept except XYD_rf and gridindex_rf (rarely used, except for looking for bug), (2) : full version,all fields are kept.
    %
    opts.opt.save = opt.save;% (1): save LUKE_RESULTS or return error in localdatadir (0): return results or error
    opts.opt.localdatadir = opt.localdatadir;% local directory where LUKE_RESULTS is saved
    opts.opt.fields = opt.fields;% select fields to be returned from lukestructs. Use NaN to return all fields.
    opts.opt.proc = opt.proc;%postprocessing done remotely
    opts.opt.backup = opt.backup;% (1) save fluctuation time steps (0) do not save
    opts.opt.waves = opt.waves;%(-1) waves are not saved in "wave_results/" and not stored in dke_out. In this case, C3PO must be rerun to see the rays (0) waves are stored in dke_out and saved in LUKE_RESULTS, (1) waves are saved in "wave_results/" but not stored in dke_out
    opts.opt.saveinputs = opt.saveinputs;% (1) save input structures in .mat files before starting (0) do not save
    %
    opts.svnremoteupdate = svnremoteupdate;%(1) svn remote update on the ITM gateway (0) : no svn remote update on the ITM gateway
    %
    opts.rho_S = rho_S;
    %
    opts.euitm.loadlocalfile = euitm.loadlocalfile;%(1): load euitm data in local file if it exists (otherwise read data in MDS+ database), (0) do not load locally (in MDS+ database only)
    opts.euitm.savelocalfile = euitm.savelocalfile;%(2): save euitm data in local file and in MDS+ database (1): save euitm data in local file but not in MDS+ database, (0) do not save locally (in MDS+ database only)
    %
    if exist('opts') && isfield(opts,'svnremoteupdate') && opts.svnremoteupdate,
        %
        [err_svn,~,c_svn,s_svn,w_svn] = matremote_jd('itmsvnupdate',{},remote,job);%svn remote or local update
        %
        if ~isempty(err_svn),
            disp('WARNING: SVN update of the ITM tools for LUKE calculations failed') 
        else
            disp(['Successful SVN update of the ITM tools for LUKE calculations: ',w_svn{1},w_svn{2}]),
        end
    end
    %
    if ~exist('opts') || ~isfield(opts,'euitm') || ~isfield(opts.euitm,'savelocalfile') || opts.euitm.savelocalfile ~= 1,%LUKE results are saved in MDS+ database
        %
        [err_mds,~,machine_mds,username_mds,ver_mds] = matremote_jd('which_MDSdatabase',{},remote,job);%remote or local test of the MDS database
        %
        if isempty(machine_mds) || isempty(username_mds) || isempty(ver_mds) || ~isempty(err_mds),
            error(['ERROR: ITM database not recognized -> machine: ',machine_mds,', user: ',username_mds,', datastructure version: ',ver_mds]);
        else
            disp(['ITM database well recognized -> machine: ',machine_mds,', user: ',username_mds,', datastructure version: ',ver_mds]);
        end
        %
        if ~strcmp(machine,machine_mds),disp('WARNING: inconsistent machine name between script and MDS+ database.');end
        %
        [err_database,~,flag_database] = matremote_jd('database_recreate_ITM',{'shot','run_out'},remote,job);%remote or local database creation output (for the test only)
        %
        if ~isempty(err_database),
            disp('WARNING: output MDS database creation failed.') 
            opts.euitm.savelocalfile = 1;%LUKE results not saved in the MDS database
        else
            disp('Output MDS database creation successfuly created.') 
        end
    end
else
    temp_luke_results = load(['LUKE_RESULTS_',dataname,'.mat']);
    %
    opts = temp_luke_results.opts;
    dkepath = temp_luke_results.dkepath;
    %
    if isfield(temp_luke_results,'data_proc')
        disp(['WARNING: the file LUKE_RESULTS_',dataname,'.mat must be deleted or renamed first to start a new simulation.']);
        clear('temp_luke_results');
    end
    %
end
%
disp('---------------------------------------------')
disp(['Computer used for calculations --> ',dkepath.profilestr{opts.remnum}]);
disp(['Distributed computing mode     --> ',int2str(opts.remmdce)]);
disp('---------------------------------------------')
%
%
cd([dkepath.luke_root,'Project_DKE/Modules/ITM'])
%
[s_host,w_host] = unix('hostname -f');%identify the local machine
%
% check if current jobs exists to load possible existing jobs
%
if ~length(strfind(w_host,'itm')),%remote calculations
    [remote,profilestr] = load_remoteprofiles_jd(remoteprofile,false,false,scheduler,profilename,duplicate);
    job = matstandardjob_jd('runmat');
    if exist('opts') && isfield(opts,'remdebugmode') && opts.remdebugmode,
        remote.debugmode = 1;
    end 
else
    remote = [];
    job = [];
end
%
[err_waves,waves] = itm_starwars(mds_ver,machine,shot,run,timeslice,time_interp,CPOs,CPO_occurrences,run_out,iter,occurrence_out,opts);
%
if isstruct(waves),    
    %
    if ~exist('opts') || ~isfield(opts,'euitm') || ~isfield(opts.euitm,'savelocalfile') || opts.euitm.savelocalfile ~= 1,%LUKE results are saved in MDS+ database
        [err_waves,~,waves_mds] = matremote_jd('check_write_waves_ITM',{length(remote),shot,run_out},remote,job);%write LUKE ouput in ITM database
    else
        waves_mds = '';
    end
    %
    load(['LUKE_RESULTS_',dataname,'.mat'],'data_proc');
    %
    for it = 1:length(waves),
        figure
        graph1D_jd(waves(it).coherentwave(1).grid_1d.psi,waves(it).coherentwave(1).profiles_1d.powd_tot,0,0,'','','',NaN,NaN,NaN,'-','none','r',2);hold on
        %
        if isstruct(waves_mds), 
            graph1D_jd(waves_mds(it).coherentwave(1).grid_1d.psi,waves_mds(it).coherentwave(1).profiles_1d.powd_tot,0,0,'','','',NaN,NaN,NaN,'-','none','b',2);hold on
        end
        %
        disp(['Absorbed RF power (it = ',int2str(it),') -> ',num2str(data_proc{it}.scalar.p0_rf_2piRp*2*pi*data_proc{1}.scalar.Rp),' (MW)']);
        %TODO display global proc results
    end
    %
    if ~exist('opts') || ~isfield(opts,'euitm') || ~isfield(opts.euitm,'savelocalfile') || opts.euitm.savelocalfile == 0,%LUKE results are saved in MDS+ database
        if exist(['MDSDATA_euitm_',dataname,'.mat'],'file'),
            delete(['MDSDATA_euitm_',dataname,'.mat'],'file'),
        end
    end
    %
else
    disp(err_waves);%in case of error
end
