function remote_profile = remote_CEA_ANDROMEDE(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the ANDROMEDE cluster
%
default_cluster = 'pbs';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% JOAN DECKER
%
% andromede (pbs pro)
%
remote.pbs.joan = default_remote_profile;
remote.pbs.joan.host = 'andromede1.intra.cea.fr';% empty for local host
remote.pbs.joan.nproc = 12;
remote.pbs.joan.cmd = 'qsub';
remote.pbs.joan.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.joan.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.joan.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.joan.matver.mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
remote.pbs.joan.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.joan.matver.mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
remote.pbs.joan.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.pbs.joan.matver.mat800.prefdir = '/home/sccp/gsem/decker/.matlab/R2012b';
remote.pbs.joan.matver.matdef = remote.pbs.joan.matver.mat800;%default matlab on remote machine
remote.pbs.joan.luke_root = '/home/sccp/gsem/decker/LUKE_1_10/';
remote.pbs.joan.users.remoteuser = 'JD211098';
%
% YVES PEYSSON
%
remote.pbs.yves = default_remote_profile;
remote.pbs.yves.host = 'andromede1.intra.cea.fr';
remote.pbs.yves.nproc = 12;
remote.pbs.yves.cmd = 'qsub';
remote.pbs.yves.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.yves.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yves.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yves.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.pbs.yves.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.yves.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.pbs.yves.matver.matdef = remote.pbs.yves.matver.mat710;%default matlab on remote machine
remote.pbs.yves.luke_root = '/home/sccp/gsem/peysson/LUKE/';
remote.pbs.yves.users.remoteuser = 'YP105119';
%
% YVES BURAVAND
%
remote.pbs.yvesb = default_remote_profile;
remote.pbs.yvesb.host = 'andromede1.intra.cea.fr';
remote.pbs.yvesb.nproc = 12;
remote.pbs.yvesb.cmd = 'qsub';
remote.pbs.yvesb.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.yvesb.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.yvesb.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.yvesb.matver.mat710.prefdir = '/home/sccp/gsem/peysson/.matlab/R2010a';
remote.pbs.yvesb.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.yvesb.matver.mat712.prefdir = '/home/sccp/gsem/peysson/.matlab/R2011a';
remote.pbs.yvesb.matver.matdef = remote.pbs.yvesb.matver.mat710;%default matlab on remote machine
remote.pbs.yvesb.luke_root = '/home/sccp/gsem/peysson/LUKE/';
remote.pbs.yvesb.users.remoteuser = 'YB109156';
%
% EMELIE NILSSON
%
% andromede (pbs pro)
%
remote.pbs.emelie = default_remote_profile;
remote.pbs.emelie.host = 'andromede1.intra.cea.fr';% empty for local host
remote.pbs.emelie.nproc = 12;
remote.pbs.emelie.cmd = 'qsub';
remote.pbs.emelie.get_jobid = {'','.andromede1'};%str_before,str_after
remote.pbs.emelie.set_jobid = {'qstat ','.andromede1','Unknown Job Id'};%str_before,str_after,str_check
remote.pbs.emelie.matver.mat710.root = '/Applications/Matlab_2010A/bin/';
remote.pbs.emelie.matver.mat710.prefdir = '/home/sccp/gsem/decker/.matlab/R2010a';
remote.pbs.emelie.matver.mat712.root = '/Applications/Matlab_2011A/bin/';
remote.pbs.emelie.matver.mat712.prefdir = '/home/sccp/gsem/decker/.matlab/R2011a';
remote.pbs.emelie.matver.mat800.root = '/Applications/Matlab_2012B/bin/';
remote.pbs.emelie.matver.mat800.prefdir = '/home/sccp/gsem/decker/.matlab/R2012b';
remote.pbs.emelie.matver.matdef = remote.pbs.emelie.matver.mat800;%default matlab on remote machine
remote.pbs.emelie.luke_root = '/home/sccp/gchf/EN290612/LUKE/';
remote.pbs.emelie.users.remoteuser = 'EN290612';
%
% -------------------------------------------------
% this part should be common to all remote profiles
% -------------------------------------------------
%
if nargin < 1 || ~isfield(remote,clustername),
    clustername = default_cluster;
end
%
if nargin < 2 || ~isfield(remote.(clustername),profilename),
    profilename = default_profile;
end
%
remote_profile = remote.(clustername).(profilename);
%
if nargin >= 3,
    remote_profile.users.(localuser) = remote_profile.users.remoteuser;
end
%
