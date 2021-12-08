function [ydates]= remote_mtsdate(shotnumbers,remote_enforce,cluster)
%
%LUKE -  Function which load multipes shot dates from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumbers: list shot number (ex: [32299,45525])
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
%       cluster (optional)  : CEA cluster (SIRRAH), CEA cluster (ANDROMEDE), CEA cluster (ALTAIR)
%           (default = 'ALTAIR')
%
%   Output:
%
%		ydates: structures of shot dates
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 1,
     error('Not enough input argument in remote_tsdate.m');
end
if nargin < 2
    remote_enforce = 1;
    cluster = 'ALTAIR';
end
if nargin < 3
    cluster = 'ALTAIR';
end
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
    error('No remote profile for remote_tsbase.m')
    %
end
%
if remote_enforce == 0,
    if ~isempty(remote_profile_ALTAIR)
        [err_ALTAIR,txt_ALTAIR] = unix(['ssh -Y ',remote_profile_ALTAIR.remoteuser,'@',remote_profile_ALTAIR.hostname,' "hostname"']);%Zone partenaire
    end
    %
    if ~isempty(remote_profile_ANDROMEDE)
        [err_ANDROMEDE,txt_ANDROMEDE] = unix(['ssh -Y ',remote_profile_ANDROMEDE.remoteuser,'@',remote_profile_ANDROMEDE.hostname,' "hostname"']);%Zone partenaire
    end
    %
    if ~isempty(remote_profile_SIRRAH)
        [err_SIRRAH,txt_SIRRAH] = unix(['ssh -Y ',remote_profile_SIRRAH.remoteuser,'@',remote_profile_SIRRAH.hostname,' "hostname"']);%Zone intra
    end
    %
    err = err_ALTAIR + err_SIRRAH + err_ANDROMEDE;
    %
    if err == 0, 
        txt = txt_SIRRAH;%the client is connected to CEA intranet
    else
        if err_ALTAIR == 0,
            txt = txt_ALTAIR;%the client computer can connected directly to CEA extranet.
        elseif err_ANDROMEDE == 0,
            txt = txt_ANDROMEDE;%the client computer can connected directly to CEA extranet.          
        else
            txt = '';%the client computer cannot connected directly to CEA extranet. May be by a SSH bridge.
            err = 0;
        end
    end
else
    err = 0;
    err_ALTAIR = '';
    err_ANDROMEDE = '';
    err_SIRRAH = '';
    txt = '';
end
%
[err_local,txt_local] = unix('hostname');%local client machine
%
if strcmp(txt_local,txt),%client on the server machine. Direct connection possible
    remote_enforce = 0;
end
%
if err==0,
    %
    if ~isempty(txt) && remote_enforce == 0,%when connected directly from the CEA network
            [ydates] = mtsdate(shotnumbers);%
            err = '';
            job = '';
    else
        %
        disp('WARNING: remote access -> data load may be long if ethernet connection is poor');
        %
        dkepath = load_structures_yp('dkepath','','');
        %
        for iprof = 1: length(dkepath.profilestr)
            if strcmp(cluster,'ALTAIR'),
                if strfind(dkepath.profilestr{iprof},'CEA_ALTAIR : direct'),%connect to ALTAIR
                    break
                end
            elseif strcmp(cluster,'ANDROMEDE'),
                if strfind(dkepath.profilestr{iprof},'CEA_ANDROMEDE : direct'),%connect to ANDROMEDE
                    break
                end
            elseif strcmp(cluster,'SIRRAH'),
                if strfind(dkepath.profilestr{iprof},'CEA_SIRRAH : direct'),%connect to SIRRAH
                    break
                end
            end
        end
        %
        scheduler.remnum = iprof;
        %
        remote = dkepath.remote(scheduler.remnum);
        %
        remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
        remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
        %
        if remote_enforce == 0
            remote.link_mode='';
        else
            remote.link_mode=1;
        end
        %
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %
        [err,job,ydates] = matremote_jd('mtsdate',{shotnumbers},remote,job);
        %
    end    
end
