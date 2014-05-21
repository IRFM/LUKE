%LUKE - Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%
%Test program for the itm_starwars MatLab function used in KEPLER actor (C3PO/LUKE for ITM simulator)
%Part of this script may be used readily in the KEPLER actor
% 
% by Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr)
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
CPO_occurrences = [occurrence_eq,occurrence_cp,occurrence_an];
%
[dkepath] = load_structures_yp('dkepath','','');
addpath(fullfile(dkepath.local_root,'LUKE_ITM','trunk'));% LUKE <-> ITM toolbox
%
[s_host,w_host] = unix('hostname -f');%identify the machine
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
    if debugmode,remote.debugmode = 1;end 
else
    remote = [];
    job = [];
end
%
[err,c_svn,s_svn,w_svn] = matremote_jd('itmsvnupdate',{},remote,job);%svn remote or local update
%
[err,machine,username,ver] = matremote_jd('which_MDSdatabase',{},remote,job);%remote or local test of the MDS database
%
if isempty(machine) || isempty(username) || isempty(ver)
	error(['ITM database not recognized -> machine: ',machine,', user: ',user,', datastructure version: ',ver]);
end
%
[err,flag] = matremote_jd('database_recreate_ITM',{'shot','run_out'},remote,job);%remote or local database creation output (for the test only)
%
waves = itm_starwars(shot,run,timeslice,time_interp,CPOs,CPO_occurrences,run_out,iter,occurrence_out);
%
output = 'ok';
outputdata = waves.coherentwave(1).profiles_1d.powd_tot;
