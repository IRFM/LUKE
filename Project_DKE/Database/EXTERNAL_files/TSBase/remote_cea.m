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
remote_profile_PERSEE = '';
remote_profile_CEPHEE = '';
remote_profile_RANA = '';
remote_profile_SIRRAH = '';
remote_profile_TALITHA = '';
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
    elseif strfind(dkepath.remote(ii).hostname,'persee') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_PERSEE = dkepath.remote(ii);
        %
    elseif strfind(dkepath.remote(ii).hostname,'cephee') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_CEPHEE = dkepath.remote(ii);
        %
    elseif strfind(dkepath.remote(ii).hostname,'rana') & strcmp(dkepath.remote(ii).scheduler,'direct')
        %
        remote_profile_RANA = dkepath.remote(ii);
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
if ~isempty(remote_profile_ANDROMEDE) && err > 0
    %
    remote = remote_profile_ANDROMEDE;
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
        %
    end
    %
end
%
if ~isempty(remote_profile_PERSEE) && err > 0
    %
    remote = remote_profile_PERSEE;
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
        %
    end
    %
end
%
if ~isempty(remote_profile_CEPHEE) && err > 0
    %
    remote = remote_profile_CEPHEE;
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
        %
    end
    %
end
%
if ~isempty(remote_profile_RANA) && err > 0
    %
    remote = remote_profile_RANA;
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
        %
    end
    %
end

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