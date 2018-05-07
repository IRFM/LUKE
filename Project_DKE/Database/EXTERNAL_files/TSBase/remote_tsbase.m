function [ydate,yout1,yout2,yout3,yout4,yout5]= remote_tsbase(shotnumber,signal)
%
%LUKE -  Function which load signals from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%		signal : type of signal (ex: 'gphyb')
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
[err,txt] = unix('hostname');%machine identification
%
ydate = [];
yout1 = [];
yout2 = [];
yout3 = [];
yout4 = [];
yout5 = [];
%
if nargin == 0,
     error('Not enough input argument in remote_tsbase.m');
end
%
if err==0,
    %
    if strfind(txt,'cea'),%when connected in CEA network
            [yout1,yout2,yout3,yout4,yout5] = tsbase(shotnumber,signal);%
            [ydate] = tsdate(shotnumber);%
    else
        dkepath = load_structures_yp('dkepath','','');
        %
        for iprof = 1: length(dkepath.profilestr)
            if strfind(dkepath.profilestr{iprof},'CEA_ANDROMEDE : direct'),%bridge by andromede
                break
            end
        end
        %
        scheduler.remnum = iprof;
        %
        remote = dkepath.remote(scheduler.remnum);
        remote.link_mode=1;%ssh bridge 
        job = matstandardjob_jd('runmat');
        if nargin > 1,
            [err,job,yout1,yout2,yout3,yout4,yout5] = matremote_jd('tsbase',{shotnumber,signal},remote,job);%find remotely the optimum density in front of the grill consistent with RC measurements
        else
            [err,job,ydate] = matremote_jd('tsdate',{shotnumber},remote,job);%find remotely the optimum density in front of the grill consistent with RC measurements
        end
        %
    end    
end
