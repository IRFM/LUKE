function lukecvsupdate(dkepath,debugmode,link_mode)
%
% This function updates LUKE and associated toolboxes remotely for the profiles stored
% in dkepath
%
%	Input:
%
%       - dkepath: path structure with remote profiles
%           (default: if no input structure or empty, dkepath is automatically loaded from LUKE_PATH.mat
%       - debugmode
%       - link_mode : connection mode prescription
%           o -1  : disable remote profiles
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
if isempty(dkepath)
    dkepath = setpath_luke_jd(dkepath,link_mode);
end
%
nrem = length(dkepath.remote);
%
disp (' ')
info_dke_yp(2,'List of remote profiles available :')
disp(' ')
%
flag_remote = true(1,nrem);
hosts = cell(1,nrem);
%
for irem = 1:nrem,
    ihost = find(flag_remote & strcmp(dkepath.remote(irem).host,hosts));
    if ~isempty(ihost) && strcmp(dkepath.remote(irem).scheduler,'direct'),% give priority to direct mode
        flag_remote(ihost) = false;
    elseif ~isempty(ihost)% discard profile
        flag_remote(irem) = false;
    end
    hosts{irem} = dkepath.remote(irem).host;
end
remote_index = find(flag_remote);
nrem = length(remote_index);

for irem = 1:nrem,
    info_dke_yp(4,['#',num2str(irem),' : ',dkepath.profilestr{remote_index(irem)}]);
end
disp(' ')
%  
remlist = input_dke_yp('Please identify profiles to be updated',1:nrem,[1;nrem]);
disp(' ')
%
remote = dkepath.remote(remote_index(remlist));
%
for irem = 1:length(remote)
    remote(irem).debugmode = debugmode;
end
%
% ----------------------------
%
remotefunctions = {'select_LUKE_jd.m','load_remoteprofiles_jd.m','luke_root'};% update MatTools, MatRemote, and LUKE
%
display_mode = 3;% show detailed results
%
exclude = {'.mat','~','.mexa64','.mexglx','.mexmaci64','.o','.DS_Store'};
%
remotecvsupdate(remote,remotefunctions,display_mode,exclude)
%