%LUKE - Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%
%Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%Part of this script may be used readily in the KEPLER actor
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
%
clear all
close all
%
opts.remnum = 1;% remote profile number. Use 0 for local sequential calculations (for LUKE only from ITM gateway)
opts.remtimout = 0;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
opts.rempause = 5;% pause between job checks (in minutes) (only for remtimout > 0)
opts.remstart = 0;% (1) start new simulation; (0) check older simulation (only for remtimout = 0)
opts.debugmode = 1;% debug mode (0) off (1) on
opts.clean = 2;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
opts.save = 0;% (1): save LUKE_RESULTS or return error (0): return results or error
opts.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
opts.backup = 0;% (1) save fluctuation time steps (0) do not save
opts.waves = 0;% (1) save waves at each time step (0) do not save
opts.opt_struct = 0;%(0) light version, compatible with fluctuations, proc_luke and runhxr, (1) : heavy version, all fields are kept except XYD_rf and gridindex_rf (rarely used, except for looking for bug), (2) : full version,all fields are kept.
%dkeparam.opt_struct
%opt.waves = 0 : waves retournés dans dke_out (et sauvées dans LUKE_RESULTS)
%opt.waves = 1 : waves sauvegardés dans "wave_results/" et non retournés dans dke_out
%opt.waves = -1: waves non sauvegardés et non retournés dans dke_out. Dans ce cas, il faut faire retourner C3PO si on veux voir les rayons.
%
opts.euitm.loadfile = 0;%(1): load euitm data in file if exists, (0) do not load
opts.euitm.savefile = 1;%(1): save euitm data in file if exists, (0) do not save
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
shot = 2;
run= 601;
run_out= 602;
timeslice = [0,1,2,3,4,5,6];
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
path_simul = [pwd,'/'];
dataname = dataname_ITM(shot,run,timeslice,time_interp,run_out,occurrence_out);
filename = [path_simul,'LUKE_RESULTS_',dataname,'.mat'];
%
CPO_occurrences = [occurrence_eq,occurrence_cp,occurrence_an];
%
[dkepath] = load_structures_yp('dkepath','','');
addpath(fullfile(dkepath.local_root,'LUKE_ITM','trunk'));% LUKE <-> ITM toolbox
%
[s_host,w_host] = unix('hostname -f');%identify the machine
%
% check if current jobs exists to load possible existing jobs
%
if ~exist(filename,'file'),% load existing simulation        
    %
    if ~exist('opts') || ~isfield(opts,'euitm') || ~isfield(opts.euitm,'loadfile') || ~opts.euitm.loadfile,
        %
        remoteprofile = 'EFDA_ITM';
        debugmode = 0;
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
        [err_svn,c_svn,s_svn,w_svn] = matremote_jd('itmsvnupdate',{},remote,job);%svn remote or local update
        %
        if ~isempty(err_svn),
            disp('WARNING: SVN update of the ITM tools for LUKE calculations failed') 
        else
            disp(['Successful SVN update of the ITM tools for LUKE calculations: ',w_svn{1},w_svn{2}]),
        end
        %
        [err_mds,machine,username,ver] = matremote_jd('which_MDSdatabase',{},remote,job);%remote or local test of the MDS database
        %
        if isempty(machine) || isempty(username) || isempty(ver) || ~isempty(err_mds),
            error(['ERROR: ITM database not recognized -> machine: ',machine,', user: ',user,', datastructure version: ',ver]);
        else
            disp(['ITM database well recognized -> machine: ',machine,', user: ',username,', datastructure version: ',ver]);
        end
        %
        [err_database,flag_database] = matremote_jd('database_recreate_ITM',{'shot','run_out'},remote,job);%remote or local database creation output (for the test only)
        %
        if ~isempty(err_database),
            disp('WARNING: output MDS database creation failed.') 
            shot = shot + 1i;%LUKE results not saved in the MDS database
        else
            disp('Output MDS database creation successfuly created.') 
        end
    else
        shot = shot + 1i;%LUKE results not saved in the MDS database
    end
else
    shot = shot + 1i;%LUKE results not saved in the MDS database
end
%
waves = itm_starwars(shot,run,timeslice,time_interp,CPOs,CPO_occurrences,run_out,iter,occurrence_out,opts);
%
if isstruct(waves),
    output = 'ok';
    keyboard
    %TODO : outputdata = waves.coherentwave(1).profiles_1d.powd_tot;
    %outputdata = waves.coherentwave(1).profiles_1d.powd_tot;
else
    disp(waves);%in case of error
end
