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
remote_profile_SIRRAH = '';
remote_profile_TALITHA = '';
%
for ii = 1:length(dkepath.remote)
    %
    if strfind(dkepath.remote(ii).hostname,'altair') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_ALTAIR = dkepath.remote(ii);
        %
    elseif strfind(dkepath.remote(ii).hostname,'sirrah') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_SIRRAH = dkepath.remote(ii);
        %
    elseif strfind(dkepath.remote(ii).hostname,'talitha') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_TALITHA = dkepath.remote(ii);
        %
    end
    %
end
%
if isempty(remote_profile_ALTAIR) && isempty(remote_profile_ANDROMEDE) && isempty(remote_profile_CEPHEE) && isempty(remote_profile_PERSEE) && isempty(remote_profile_RANA) && isempty(remote_profile_SIRRAH) && isempty(remote_profile_TALITHA)
    %
    cprintf('red*','---> No remote profile is available for remote access to TSBase');disp(' ')
    %
end
%
if ~isempty(remote_profile_ALTAIR)
    %    
    remote = remote_profile_ALTAIR;
    %
    [txt,err] = matremotessh(remote,'hostname');
    %
    if err > 0
        %
        [err,txt] = matremotecmd(remote,'','hostname');
        %
        if err == 0
            %
            remote.bridge = [];
            %
        else
            %
            remote = [];
            %
        end
    end
    %
end
%


%
if ~isempty(remote_profile_SIRRAH) && err > 0
    %
    [txt,err] = matremotessh(remote_profile_SIRRAH,'hostname');
    %
    if err == 0
        %
        remote = remote_profile_SIRRAH;
        %
    else
        %
        remote = [];
        %
    end
    %
end
%
if ~isempty(remote_profile_TALITHA) && err > 0
    %
    [txt,err] = matremotessh(remote_profile_TALITHA,'hostname');
    %
    if err == 0
        %
        remote = remote_profile_TALITHA;
        %
    else
        %
        remote = [];
        %
    end
    %
end
%