function [remote,err] = remote_cea
%
    dkepath = load_structures_yp('dkepath','','');
    %
    remote_profile_ALTAIR = '';
    remote_profile_ANDROMEDE = '';
    remote_profile_SIRRAH = '';
    %
    for ii = 1:length(dkepath.remote)
        %
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
        cprintf('red*','---> No remote profile is available for remote_tsdate.m');disp(' ')
        %
    end
    %
    if ~isempty(remote_profile_ALTAIR)
        %
        if isempty(strfind(remote_profile_ALTAIR.hostname,'partenaires.cea.fr'))
            %
            hostname = [remote_profile_ALTAIR.hostname,'.partenaires.cea.fr'];
            %
        else
            %
            hostname = remote_profile_ALTAIR.hostname;
            %
        end
        %
        [err,txt] = unix(['ssh -Y ',remote_profile_ALTAIR.remoteuser,'@',hostname,' "hostname"']);%Zone partenaire
        %
        remote = remote_profile_ALTAIR;
        %
    end
    %
    if ~isempty(remote_profile_ANDROMEDE) && err > 0
        %
        if isempty(strfind(remote_profile_ANDROMEDE.hostname,'partenaires.cea.fr'))
            %
            hostname = [remote_profile_ANDROMEDE.hostname,'.partenaires.cea.fr'];
            %
        else
            %
            hostname = remote_profile_ANDROMEDE.hostname;
            %
        end
        %
        [err,txt] = unix(['ssh -Y ',remote_profile_ANDROMEDE.remoteuser,'@',hostname,' "hostname"']);%Zone partenaire
        %
        remote = remote_profile_ANDROMEDE;
        %
    end
    %
    if ~isempty(remote_profile_SIRRAH) && err > 0
        %
        if isempty(strfind(remote_profile_SIRRAH.hostname,'intra.cea.fr'))
            %
            hostname = [remote_profile_SIRRAH.hostname,'.intra.cea.fr'];
            %
        else
            %
            hostname = remote_profile_SIRRAH.hostname;
            %
        end
        %
        [err,txt] = unix(['ssh -Y ',remote_profile_SIRRAH.remoteuser,'@',hostname,' "hostname"']);%Zone intra
        %
        remote = remote_profile_SIRRAH;
        %
    end
    %
