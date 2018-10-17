function [imas_output]= remote_imas(imas_param)
%
%LUKE -  Function which load signals from WEST/TORE SUPRA IMAS database. Can be used only within CEA network
%
%   Input:
%
%		imas_param: imas structure for parameters 
%
%   Output:
%
%		imas_output: IMAS data structure for the corresponding data type
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 1,
    error('Not enough input arguments in remote_imas.m');
end
%
if ~isfield(imas_param,'remote_profile'),
   imas_param.remote_profile = 'CEA_SIRRAH';%'CEA_ANDROMEDE';%Remote profile for reading data (SIRRAH or ANDROMEDE for WEST/TORE SUPRA)
   disp(['WARNING: remote profile is not setup in imas structure. Default remote profile ',imas_param.remote_profile,' is chosen']);
end
%
if ~isfield(imas_param,'remote_enforce'),
   imas_param.remote_enforce = 1;%Remote profile for reading data 
   disp(['WARNING: remote_enforce field is not setup in imas structure. Default remote connection is enforced.']);
end
%
remote_profile_ANDROMEDE = remote_CEA_ANDROMEDE;
remote_profile_SIRRAH = remote_CEA_SIRRAH;
%
if imas_param.remote_enforce == 0,
    [err_ANDROMEDE,txt_ANDROMEDE] = unix(['ssh -Y ',remote_profile_ANDROMEDE.remoteuser,'@',remote_profile_ANDROMEDE.host,' "hostname"']);%Zone partenaire
    [err_SIRRAH,txt_SIRRAH] = unix(['ssh -Y ',remote_profile_SIRRAH.remoteuser,'@',remote_profile_SIRRAH.host,' "hostname"']);%Zone intra
    err = err_ANDROMEDE + err_SIRRAH;
    %
    if err == 0, 
        txt = txt_SIRRAH;%the client is connected to CEA intranet
    else
        if err_ANDROMEDE == 0,
            txt = txt_ANDROMEDE;%the client computer can connected directly to CEA extranet.
        else
            txt = '';%the client computer cannot connected directly to CEA extranet. May be by a SSH bridge.
        end
    end
else
    err = 0;
    err_ANDROMEDE = '';
    err_SIRRAH = '';
    txt = '';
end
%

remote_profile = eval(['remote_',imas_param.remote_profile]);
%
[err_remote,txt_remote] = unix(['ssh -Y ',remote_profile.remoteuser,'@',remote_profile.host,' "hostname"']);
if err_remote ~= 0, 
    txt_remote = '';%the client computer cannot connected directly to CEA extranet. May be by a SSH bridge. Remote connection necessary
end
%
[err_local,txt_local] = unix('hostname');%local client machine
%
if strcmp(txt_local,txt_remote),%client on the server machine. Direct connection possible
    imas_param.remote_enforce = 0;
    imas_param.local_access = 1;
else
    imas_param.local_access = 0;
end
%















if err_remote==0,
    %
    if imas_param.local_access && imas_param.remote_enforce == 0,%when connected directly from the CEA network
            [imas_output] = imas(imas_param);%
    else
        dkepath = load_structures_yp('dkepath','','');
        %
        for iprof = 1: length(dkepath.profilestr)
            if strfind(dkepath.profilestr{iprof},[imas_param.remote_profile,' : direct']),%connect to the selected remote profile
                break
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
            [err,job,imas_output] = matremote_jd('imas',{imas_param},remote,job);%
        end
        %
    end    
end
