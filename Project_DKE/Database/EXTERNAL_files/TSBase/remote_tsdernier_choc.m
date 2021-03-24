function [shotnum]= remote_tsdernier_choc(remote_enforce,cluster)
%
%LUKE -  Function which gives the last shot number Tore Supra database. Includes WEST too. May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
%       cluster (optional)  : CEA cluster (SIRRAH), CEA cluster (ANDROMEDE), CEA cluster (ALTAIR)
%           (default = 'ALTAIR')
%
%   Output:
%
%		shotnum: last shot number 
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 1,
     error('Not enough input argument in remote_tsdernier_choc.m');
end
if nargin < 1
    remote_enforce = 1;
    cluster = 'ALTAIR';
end
if nargin < 2
    cluster = 'ALTAIR';
end
%
remote_profile_ALTAIR = remote_CEA_ALTAIR;
remote_profile_ANDROMEDE = remote_CEA_ANDROMEDE;
remote_profile_SIRRAH = remote_CEA_SIRRAH;
%
if remote_enforce == 0,
    [err_ALTAIR,txt_ALTAIR] = unix(['ssh -Y ',remote_profile_ALTAIR.remoteuser,'@',remote_profile_ALTAIR.host,' "hostname"']);%Zone partenaire
    [err_ANDROMEDE,txt_ANDROMEDE] = unix(['ssh -Y ',remote_profile_ANDROMEDE.remoteuser,'@',remote_profile_ANDROMEDE.host,' "hostname"']);%Zone partenaire
    [err_SIRRAH,txt_SIRRAH] = unix(['ssh -Y ',remote_profile_SIRRAH.remoteuser,'@',remote_profile_SIRRAH.host,' "hostname"']);%Zone intra
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
shotnum = [];
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
            [shotnum] = tsdernier_choc;%
            err = '';
            job = '';
    else
        %
        disp('WARNING: data load may be long if ethernet connection is poor');
        %
        dkepath = load_structures_yp('dkepath','','');
        %
        for iprof = 1: length(dkepath.profilestr)
            if strcmp(cluster,'ALTAIR'),
                if strfind(dkepath.profilestr{iprof},'CEA_ALTAIR : direct'),%connect to ALTAIR
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
        remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsdernier_choc only
        remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsdernier_choc only
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
        [err,job,shotnum] = matremote_jd('tsdernier_choc',{''},remote,job);
        %
    end    
end
