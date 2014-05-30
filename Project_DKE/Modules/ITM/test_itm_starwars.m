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
opts.remnum = 10;% remote profile number. Use 0 for local sequential calculations (for LUKE only from ITM gateway)
opts.remtimout = 0;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
opts.rempause = 5;% pause between job checks (in minutes) (only for remtimout > 0)
opts.remstart = 0;% (1) start new simulation; (0) check older simulation (only for remtimout = 0)
opts.debugmode = 0;% debug mode (0) off (1) on
opts.clean = 2;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
opts.save = 0;% (1): save LUKE_RESULTS or return error (0): return results or error
opts.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
opts.backup = 0;% (1) save fluctuation time steps (0) do not save
opts.waves = 0;% (1) save waves at each time step (0) do not save
opts.opt_struct = 0;%(0) light version, compatible with fluctuations, proc_luke and runhxr, (1) : heavy version, all fields are kept except XYD_rf and gridindex_rf (rarely used, except for looking for bug), (2) : full version,all fields are kept.
opts.svnremoteupdate = 0;%(1) svn remote update on the ITM gateway (0) : no svn remote update on the ITM gateway_rf and gridindex_rf (rarely used, except for looking for bug), (2) : full version,all fields are kept.
%
%dkeparam.opt_struct
%opt.waves = 0 : waves retourn�s dans dke_out (et sauv�es dans LUKE_RESULTS)
%opt.waves = 1 : waves sauvegard�s dans "wave_results/" et non retourn�s dans dke_out
%opt.waves = -1: waves non sauvegard�s et non retourn�s dans dke_out. Dans ce cas, il faut faire retourner C3PO si on veux voir les rayons.
%
opts.euitm.loadlocalfile = 1;%(1): load euitm data in local file if it exists (otherwise read data in MDS+ database), (0) do not load locally (in MDS+ database only)
opts.euitm.savelocalfile = 1;%(2): save euitm data in local file and in MDS+ database (1): save euitm data in local file but not in MDS+ database, (0) do not save locally (in MDS+ database only)
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
[dkepath] = load_structures_yp('dkepath','','');
%
disp('---------------------------------------------')
disp(['Computer used for calculations --> ',dkepath.profilestr{opts.remnum}]);
disp('---------------------------------------------')
%
cd([dkepath.luke_root,'Project_DKE/Modules/ITM'])
dataname = dataname_ITM(machine,shot,run,timeslice,time_interp);
filename = [pwd,'/LUKE_RESULTS_',dataname,'.mat'];
%
addpath(fullfile(dkepath.local_root,'LUKE_ITM','trunk'));% LUKE <-> ITM toolbox
%
[s_host,w_host] = unix('hostname -f');%identify the machine
%
% check if current jobs exists to load possible existing jobs
%
remoteprofile = 'EFDA_ITM';
scheduler = 'direct';
profilename = 'yvesp';
duplicate = 'true';%if true, don't use the remote LUKE_ITM toolbox
%
if ~length(strfind(w_host,'itm')),%remote calculations
    [remote,profilestr] = load_remoteprofiles_jd(remoteprofile,false,false,scheduler,profilename,duplicate);
    job = matstandardjob_jd('runmat');
    if exist('opts') && isfield(opts,'debugmode') && opts.debugmode,
        remote.debugmode = 1;
    end 
else
    remote = [];
    job = [];
end
%
if ~exist(filename,'file'),% load existing simulation        
    %
    if exist('opts') && isfield(opts,'svnremoteupdate') && opts.svnremoteupdate,
        %
        [err_svn,c_svn,s_svn,w_svn] = matremote_jd('itmsvnupdate',{},remote,job);%svn remote or local update
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
        [err_mds,machine_mds,username_mds,ver_mds] = matremote_jd('which_MDSdatabase',{},remote,job);%remote or local test of the MDS database
        %
        if isempty(machine_mds) || isempty(username_mds) || isempty(ver_mds) || ~isempty(err_mds),
            error(['ERROR: ITM database not recognized -> machine: ',machine_mds,', user: ',username_mds,', datastructure version: ',ver_mds]);
        else
            disp(['ITM database well recognized -> machine: ',machine_mds,', user: ',username_mds,', datastructure version: ',ver_mds]);
        end
        %
        if ~strcmp(machine,machine_mds),disp('WARNING: inconsistent machine name between script and MDS+ database.');end
        %
        [err_database,flag_database] = matremote_jd('database_recreate_ITM',{'shot','run_out'},remote,job);%remote or local database creation output (for the test only)
        %
        if ~isempty(err_database),
            disp('WARNING: output MDS database creation failed.') 
            opts.euitm.savelocalfile = 1;%LUKE results not saved in the MDS database
        else
            disp('Output MDS database creation successfuly created.') 
        end
    end
end
%
[err_waves,waves] = itm_starwars(machine,shot,run,timeslice,time_interp,CPOs,CPO_occurrences,run_out,iter,occurrence_out,opts);
%
if isstruct(waves),    
    %
    if ~exist('opts') || ~isfield(opts,'euitm') || ~isfield(opts.euitm,'savelocalfile') || opts.euitm.savelocalfile ~= 1,%LUKE results are saved in MDS+ database
        [err_waves,waves_mds] = matremote_jd('check_write_waves_ITM',{length(remote),shot,run_out},remote,job);%write LUKE ouput in ITM database
    else
        waves_mds = '';
    end
    %
    for it = 1:length(waves),
        figure;
        plot(waves(it).coherentwave(1).grid_1d.psi,waves(it).coherentwave(1).profiles_1d.powd_tot,'b+'),hold on
        %
        if isstruct(waves_mds), 
            plot(waves_mds(it).coherentwave(1).grid_1d.psi,waves_mds(it).coherentwave(1).profiles_1d.powd_tot,'rx'),hold on
        end
        %
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
