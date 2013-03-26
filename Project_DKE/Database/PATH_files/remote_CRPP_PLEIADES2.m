function remote_profile = remote_CRPP_PLEIADES2(clustername,profilename,localuser)
%
% This function regroups the remote profiles run on the EPFL PLEIADES2 cluster
%
default_cluster = 'torque';% default cluster profile if 'clustername' is not an existing cluster profile
default_profile = 'joan';% default user profile if 'remoteuser' is not an existing user profile
%
% --------------------------------------------------
%
% pleiades2 (torque)
%
%
% JOAN DECKER
%
remote.torque.joan = default_remote_profile;
remote.torque.joan.host = 'pleiades2.epfl.ch';% empty for local host
remote.torque.joan.nproc = 48;% limited to two jobs per PBS node to avoid cluster saturation
%remote.torque.joan.nodes = 1;% default number of nodes for job on cephee
remote.torque.joan.ppn = 1;% default number of cores for job on cephee
remote.torque.joan.wait = 0;% forbidden option
remote.torque.joan.cmd = 'qsub';
remote.torque.joan.get_jobid = {'','.pleiades2.epfl.ch'};%str_before,str_after
remote.torque.joan.set_jobid = {'qstat ','','Unknown Job Id'};%str_before,str_after,str_check
remote.torque.joan.matver.mat711.root = '/usr/local/matlab-7.11.0/bin/';
remote.torque.joan.matver.mat711.prefdir = '/home/jdecker/.matlab/R2010b';
remote.torque.joan.matver.matdef = remote.torque.joan.matver.mat711;%default matlab on remote machine
remote.torque.joan.luke_root = '/home/jdecker/LUKE/';
remote.torque.joan.users.remoteuser = 'jdecker';
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
