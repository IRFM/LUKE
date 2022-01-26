function [yout1,yout2,yout3,yout4,yout5]= remote_tsbase(shotnumber,signal)
%
%LUKE -  Function which load signals from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%		signal : type of signal (ex: 'gphyb')
%
%   Output:
%
%       yout1: signal vector 1 
%       yout2: signal vector 2 (may be time vector)
%       yout3: signal vector 3 (may be time vector or empty)
%       yout4: signal vector 4 (may be time vector or empty)
%       yout5: signal vector 5 (may be time vector or empty)
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
yout1 = [];
yout2 = [];
yout3 = [];
yout4 = [];
yout5 = [];
%
if nargin < 2,
     error('Not enough input argument in remote_tsbase.m');
end
%
[remote,err] = remote_cea;
%
if err == 0 && isstruct(remote)
    %
    cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
    %
    remote.matver.matdef = remote.matver.mat903;%enforce Matlab R2013b for tsbase only
    %
    job = matstandardjob_jd('runmat');
    job.funcopy = false;%since binary is machine specific only local version is used
    %
    [err,job,yout1,yout2,yout3,yout4,yout5] = matremote_jd('tsbase',{shotnumber,signal},remote,job);
    %
else
    %
    cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
    %
end 
