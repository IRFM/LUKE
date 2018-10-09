function [ydate,yout1,yout2,yout3,yout4,yout5]= remote_tsbase(shotnumber,signal,remote_enforce,cluster)
%
%LUKE -  Function which load signals from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%		signal : type of signal (ex: 'gphyb')
%		remote_enforce : enforce remote calculation
%           (default = 0)
%       cluster : CEA cluster (SIRRAH) or CEA cluster (ANDROMEDE)
%
%   Output:
%
%		ydate: shot date (if only shot number is given, it answers the shot date)
%       yout1: signal vector 1 
%       yout2: signal vector 2 (may be time vector)
%       yout3: signal vector 3 (may be time vector or empty)
%       yout4: signal vector 4 (may be time vector or empty)
%       yout5: signal vector 5 (may be time vector or empty)
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2,
     error('Not enough input argument in remote_tsbase.m');
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
ydate = [];
yout1 = [];
yout2 = [];
yout3 = [];
yout4 = [];
yout5 = [];
%
if err==0,
    %
    if ~isempty(txt) && remote_enforce == 0,%when connected directly from the CEA network
            [yout1,yout2,yout3,yout4,yout5] = tsbase(shotnumber,signal);%
            [ydate] = tsdate(shotnumber);%
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
        remote.link_mode='';
        job = matstandardjob_jd('runmat');
        if nargin > 1,
            [err,job,yout1,yout2,yout3,yout4,yout5] = matremote_jd('tsbase',{shotnumber,signal},remote,job);
        else
            [err,job,ydate] = matremote_jd('tsdate',{shotnumber},remote,job);
        end
        %
    end    
end
