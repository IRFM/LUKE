function [yout1,yout2,yout3,yout4,yout5]= remote_tsmat(shotnumber,signal,remote_enforce)
%
%LUKE -  Function which load signals from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%		signal : type of signal (ex: 'gphyb')
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
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
     error('Not enough input argument in remote_tsmat.m');
end
if nargin < 3
    remote_enforce = 0;
end
%
flag_remote = 0;
%
[err_local,txt_local] = unix('hostname');%local client machine
%
txt_local = deblank(txt_local);
%
if remote_enforce == 0 && isempty(strfind(txt_local,'altair')) && isempty(strfind(txt_local,'andromede')) && isempty(strfind(txt_local,'sirrah'))
    %
    cprintf([1,0.5,0],['---> Direct access to tsmat is forbidden outside internal CEA network. Remote access is enforced']);disp(' ')
    remote_enforce = 1;
    %
end
%
if remote_enforce == 0 %try first direct access
    %
    if ~isempty(which('tsmat'))
        %
        [yout1,yout2,yout3,yout4,yout5] = tsmat(shotnumber,signal);%
        %
        if isempty(yout1) && isempty(yout2) && isempty(yout3) && isempty(yout4) && ~isempty(yout5)
            %
            cprintf([1,0.5,0],['---> Direct access to tsmat failed. Remote access to tsmat is performed.']);disp(' ')
            flag_remote = 1;
            %
        end
        %
    else
        %
        flag_remote = 1;
        cprintf([1,0.5,0],['---> The mex function of tsmat does not exist. Compile it first in ~/Project_DKE/Database/EXTERNAL_files/TSBase/TSBase/ folder. Remote access to tsmat is performed.']);disp(' ')
        %
    end
    %
else
    %
    flag_remote = 1;
    cprintf([1,0.5,0],['---> Remote access to tsmat is enforced.']);disp(' ')
    %
end
%
if flag_remote == 1
    %
    [remote,err] = remote_cea;
    %
    if err == 0 && isstruct(remote)
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
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
        [err,job,yout1,yout2,yout3,yout4,yout5] = matremote_jd('tsmat',{shotnumber,signal},remote,job);
        %
    else
        %
        cprintf('red*','---> ALTAIR, ANDROMEDE and SIRRAH are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    end 
    %
end
