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
opts.remnum = 0;% remote profile number. Use 0 for local sequential calculations (for LUKE only from ITM gateway)
opts.remtimout = 60;% timeout for remote calculations, in minutes. Use (0) to return later and check results by running this script again
opts.rempause = 5;% pause between job checks (in minutes) (only for remtimout > 0)
opts.debugmode = 1;% debug mode (0) off (1) on
opts.clean = 2;% clean job files/folders : both on remote and local (2), only on remote (1) or not at all (0)
opts.save = 0;% (1): save LUKE_RESULTS or return error (0): return results or error
opts.fields = NaN;% selected fields in returned lukestructs. Use NaN for all fields
opts.backup = 0;% (1) save fluctuation time steps (0) do not save
opts.waves = 0;% (1) save waves at each time step (0) do not save
%
opts.euitm.loadfile = 1;%(1): load euitm data in file if exists, (0) do not load
opts.euitm.savefile = 1;%(1): save euitm data in file if exists, (0) do not save
%
% Simulation parameters
%
shot = 2;
run= 501;
run_out= 502;
timeslice = 0;
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
addpath(fullfile(dkepath.local_root,'LUKE_ITM','trunk'));% LUKE <-> ITM toolbox
%
[s_host,w_host] = unix('hostname -f');%identify the machine
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
        disp(['ITM database well recognized -> machine: ',machine,', user: ',user,', datastructure version: ',ver]);
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
