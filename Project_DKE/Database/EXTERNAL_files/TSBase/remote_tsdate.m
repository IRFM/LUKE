function [ydate]= remote_tsdate(shotnumber,remote_enforce)
%
%LUKE -  Function which load shot date from Tore Supra database (work for WEST shot date only). May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
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
if nargin < 2
    remote_enforce = 0;
end
%
flag_remote = 0;
%
%
[err_local,txt_local] = unix('hostname');%local client machine
%
txt_local = deblank(txt_local);
%
if remote_enforce == 0 && isempty(strfind(txt_local,'altair')) && isempty(strfind(txt_local,'andromede')) && isempty(strfind(txt_local,'sirrah'))
    %
    cprintf([1,0.5,0],['---> Direct access to tsdate is forbidden outside internal CEA network. Remote access is enforced']);disp(' ')
    remote_enforce = 1;
    %
end
%
if remote_enforce == 0 %try first direct access
    %
    if ~isempty(which('tsdate'))
        %
        [ydate] = tsdate(shotnumber);
        %
        if isempty(ydate)
            %
            cprintf([1,0.5,0],['---> Direct access to tsdate failed. Remote access to tsdate is performed.']);disp(' ')
            flag_remote = 1;
            %
        end
        %
    else
        %
        flag_remote = 1;
        cprintf([1,0.5,0],['---> The mex function of tsdate does not exist. Compile it first in ~/Project_DKE/Database/EXTERNAL_files/TSBase/TSBase/ folder. Remote access to tsdate is performed.']);disp(' ')
        %
    end
    %
else
    %
    flag_remote = 1;
    cprintf([1,0.5,0],['---> Remote access to tsdate is enforced.']);disp(' ')
    %
end
%
if flag_remote == 1
    %
    [remote,err] = remote_cea;
    %
    if err == 0 && isstruct(remote)
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ')
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
        [err,job,ydate] = matremote_jd('tsdate',{shotnumber},remote,job);
        %
    else
        %
        cprintf('red*','---> ALTAIR, ANDROMEDE and SIRRAH are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    end 
    %
end

