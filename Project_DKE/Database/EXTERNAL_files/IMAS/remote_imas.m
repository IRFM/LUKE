function [imas_output]= remote_imas(imas_param,data_type,remote_enforce,cluster)
%
%LUKE -  Function which load signals from WEST/TORE SUPRA IMAS database. Can be used only within CEA network
%
%   Input:
%
%		imas_param: imas structure for parameters 
%		data_type : type of signal (ex: 'equilibrium' or 'core_profiles')
%		remote_enforce : enforce remote calculation
%           (default = 0)
%       cluster : CEA cluster (SIRRAH) or CEA cluster (ANDROMEDE)
%
%   Output:
%
%		imas_output: IMAS data structure for the corresponding data type
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2,
    error('Not enough input arguments in remote_imas.m');
end
if nargin < 3
    remote_enforce = 0;
    cluster = 'ANDROMEDE';
end
if nargin < 4
    cluster = 'ANDROMEDE';
end
%
remote_profile_ANDROMEDE = remote_CEA_ANDROMEDE;
remote_profile_SIRRAH = remote_CEA_SIRRAH;
%

[err_ANDROMEDE,txt_ANDROMEDE] = unix(['ssh -Y ',remote_profile_ANDROMEDE.remoteuser,'@',remote_profile_ANDROMEDE.host,' "whoami"']);%Zone partenaire
[err_SIRRAH,txt_SIRRAH] = unix(['ssh -Y ',remote_profile_SIRRAH.remoteuser,'@',remote_profile_SIRRAH.host,' "whoami"']);%Zone intra
err = err_ANDROMEDE + err_SIRRAH;
if err == 0, 
    txt = txt_SIRRAH;%the client is connected to CEA intranet
else
    if err_ANDROMEDE == 0,
        txt = txt_ANDROMEDE;%the client computer can connected directly to CEA extranet.
    else
        txt = '';%the client computer cannot connected directly to CEA extranet. May be by a SSH bridge.
    end
end
%
if err==0,
    %
    if ~isempty(txt) && remote_enforce == 0,%when connected directly from the CEA network
            [imas_output] = imas(imas_param,data_type);%
    else
        dkepath = load_structures_yp('dkepath','','');
        %
        for iprof = 1: length(dkepath.profilestr)
            if strcmp(cluster,'ANDROMEDE'),
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
        remote.link_mode = '';
        remote.matver.matdef = imas_param.matlabpath;
        job = matstandardjob_jd('runmat');
        if nargin > 1,
            [err,job,imas_output] = matremote_jd('imas',{imas_param,data_type},remote,job);%
        end
        %
    end    
end
