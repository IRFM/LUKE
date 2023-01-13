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
%
remote_profile_SIRRAH = '';
%
for ii = 1:length(dkepath.remote)
    %
    if strfind(dkepath.remote(ii).hostname,'altair') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_ALTAIR = dkepath.remote(ii);
        %
    elseif strfind(dkepath.remote(ii).hostname,'sirrah') & strcmp(dkepath.remote(ii).scheduler,'pbs')
        %
        remote_profile_SIRRAH = dkepath.remote(ii);
    end
    %
end
%
if isempty(remote_profile_ALTAIR) && isempty(remote_profile_SIRRAH)
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
    if err > 0 && ~isempty(txt)
        %
        [err,txt] = matremotecmd(remote,'','hostname');
        %
        if err == 0 || isempty(txt)
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
    return
end
%
if ~isempty(remote_profile_SIRRAH)
    %
    [err,txt] = unix('hostname');
    %
    if err == 0 && contains(txt,'intra.cea.fr')
        %
        remote = 1;
        %
    else
        %
        remote = [];
        %
    end
    %
end
