function [ydate]= remote_tsdate(shotnumber)
%
%LUKE -  Function which load shot date from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%
%   Output:
%
%		ydate: shot date (if only shot number is given, it answers the shot date)
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if ~ismember('mute_remote_tsdate', who('global'))
    mute_remote_tsdate = 0;
else
    global mute_remote_tsdate
end
%
ydate = [];
%
if nargin < 1,
     error('Not enough input argument in remote_tsdate.m');
end
%
remote = remote_cea;
%
if isstruct(remote)
    %
    cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ')
    %
    remote.matver.matdef = remote.matver.mat903;%enforce Matlab R2013b for tsbase only
    %
    job = matstandardjob_jd('runmat');
    job.funcopy = false;%since binary is machine specific only local version is used
    %
    [err,job,ydate] = matremote_jd('tsdate',{shotnumber},remote,job);
    %
else
if isempty(remote)
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    else
        %
        [ydate] = tsdate(shotnumber,signal);
        %
    end
    %
end 
%
if length(ydate) > 10
    ydate = ydate(1:10);%remove possible spurious ending char
end
