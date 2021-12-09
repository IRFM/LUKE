function [remote,err] = remote_cea
%
%LUKE : Automatic remote structure generation for access to TSBase
%
%   Input: None
%
%   Output:
%
%	remote : remote structure (using LUKE path and MatRemote profiles
%   err : error status for ssh connection
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
err = 0;
remote = [];
%
dkepath = load_structures_yp('dkepath','','');
%
remote_profile_ALTAIR = '';
remote_profile_ANDROMEDE = '';
remote_profile_SIRRAH = '';
%
for ii = 1:length(dkepath.remote)
    %1
    if strfind(dkepath.remote(ii).hostname,'altair') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_ALTAIR = dkepath.remote(ii);
        %
    elseif strfind(dkepath.remote(ii).hostname,'andromede') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_ANDROMEDE = dkepath.remote(ii);
        %
    elseif strfind(dkepath.remote(ii).hostname,'sirrah') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_SIRRAH = dkepath.remote(ii);
        %
    end
    %
end
%
if isempty(remote_profile_ALTAIR) && isempty(remote_profile_ANDROMEDE) && isempty(remote_profile_SIRRAH)
    %
    cprintf('red*','---> No remote profile is available for remote access to TSBase');disp(' ')
    %
end
%
if ~isempty(remote_profile_ALTAIR)
    %
    [txt,err] = matremotessh(remote_profile_ALTAIR,'hostname');
    %
    remote = remote_profile_ALTAIR;
    %
end
%
if ~isempty(remote_profile_ANDROMEDE) && err > 0
    %
    [txt,err] = matremotessh(remote_profile_ANDROMEDE,'hostname');
    %
    remote = remote_profile_ANDROMEDE;
    %
end
%
if ~isempty(remote_profile_SIRRAH) && err > 0
    %
    [txt,err] = matremotessh(remote_profile_SIRRAH,'hostname');
    %
    remote = remote_profile_SIRRAH;
    %
end
%
