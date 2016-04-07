function lukegitupdate(dkepath,debugmode,link_mode)
%
% This function updates LUKE and associated toolboxes remotely for the profiles stored
% in dkepath. LUKE and related toolboxes must be under Git file system
% control.
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat
%       - debugmode
%       - link_mode : connection mode prescription
%           o -2  : disable remote profiles
%           o -1  : local profiles only
%           o NaN : (default) use value from remote.link_mode
%           o []  : give priority to (0) ssh key pair, (1) ssh bridge, (2) url/ftp bridge
%           o 0   : ssh key pair enforced
%           o 1   : ssh bridge enforced
%           o 2   : url/ftp bridge enforced
%
if nargin < 3,
    link_mode = NaN;
end
if nargin < 2,
    debugmode = 0;  
end
if nargin < 1,
    dkepath = '';
end
%
[dkepath] = load_structures_yp('dkepath','','');
%
if ~exist('dkepath','var'),
    dkepath = setpath_luke_jd('',link_mode,0,0);
else
    dkepath = setpath_luke_jd(dkepath,link_mode,0,0);
end
%
nrem = length(dkepath.remote);
%
disp (' ')
info_dke_yp(2,'List of remote profiles tagged for git update :')
disp(' ')
%
flag_gitupdate = false(1,nrem);
%
for irem = 1:nrem,
    if isfield(dkepath.remote(irem),'gitupdate') && ~isempty(dkepath.remote(irem).gitupdate) && dkepath.remote(irem).gitupdate,
        flag_gitupdate(irem) = true;
    end
end
remote_index = find(flag_gitupdate);
nrem = length(remote_index);
%
for irem = 1:nrem,
    info_dke_yp(4,['#',num2str(irem),' : ',dkepath.profilestr{remote_index(irem)},' for LUKE root : ',dkepath.remote(remote_index(irem)).env.luke_root]);
end
disp(' ')
%  
remlist = input_dke_yp('Please identify profiles to be updated',1:nrem,[1;nrem]);
disp(' ')
%
remote = dkepath.remote(remote_index(remlist));
nrem = length(remote);
%
for irem = 1:nrem,
    remote(irem).debugmode = debugmode;
end
%
% ----------------------------
%
remotefunctions = {'select_LUKE.m','load_remoteprofiles_jd.m','make_help.m','luke_root'};% update MatTools, MatRemote, MatHelp and LUKE
%
display_mode = 3;% show detailed results
%
exclude = {'.git','.mat','~','.mexa64','.mexglx','.mexmaci64','.o','.DS_Store'};
%
flag = remotegitupdate(remote,remotefunctions,display_mode,exclude);
%
disp('--------------------------------------')
disp('           GLOBAL RESULTS             ')
disp('--------------------------------------')
disp(' ')
disp('  -2 : the remote process failed')
disp('  -1 : the git update process failed')
disp('   0 : the git update succeeded')
disp(' ')
disp(' Results for : MatTools / MatRemote / MatHelp / LUKE ')
disp(' ')
disp('--------------------------------------')
disp(' ')
disp(' ')
disp(' ')
%
flag1 = num2str(flag(:,1));
flag2 = num2str(flag(:,2));
flag3 = num2str(flag(:,3));
flag4 = num2str(flag(:,4));
%
for irem = 1:nrem,
    disp([flag1(irem,:),' / ',flag2(irem,:),' / ',flag3(irem,:),' / ',flag4(irem,:),' : ',dkepath.profilestr{remote_index(remlist(irem))}])
end
%