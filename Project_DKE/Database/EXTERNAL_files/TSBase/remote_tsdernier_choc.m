function [shotnum]= remote_tsdernier_choc(remote_enforce)
%
%LUKE -  Function which gives the last shot number Tore Supra database. Includes WEST too. May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		remote_enforce (optional) : enforce remote calculation
%           (default = 0)
%
%   Output:
%
%		shotnum: last shot number 
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
shotnum = [];
%
if nargin < 1
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
    cprintf([1,0.5,0],['---> Direct access to tsdernier_choc is forbidden outside internal CEA network. Remote access is enforced']);disp(' ')
    remote_enforce = 1;
    %
end
%
if remote_enforce == 0 %try first direct access
    %
    if ~isempty(which('tsdernier_choc'))
        %
        shotnum = tsdernier_choc;
        %
        if isempty(shotnum)
            %
            cprintf([1,0.5,0],['---> Direct access to tsdernier_choc failed. Remote access to tsdernier_choc is performed.']);disp(' ')
            flag_remote = 1;
            %
        end
        %
    else
        %
        flag_remote = 1;
        cprintf([1,0.5,0],['---> The mex function of tsdernier_choc does not exist. Compile it first in ~/Project_DKE/Database/EXTERNAL_files/TSBase/TSBase/ folder. Remote access to tsdernier_choc is performed.']);disp(' ')
        %
    end
    %
else
    %
    flag_remote = 1;
    cprintf([1,0.5,0],['---> Remote access to tsdernier_choc is enforced.']);disp(' ')
    %
end
%
if flag_remote == 1
    %
    [remote,err] = remote_cea;
    %
    if err == 0 && isstruct(remote)
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');
        %
        remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
        remote.matver.matdef = remote.matver.mat802;%enforce Matlab R2013b for tsbase only
        %
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %
        [err,job,shotnum] = matremote_jd('tsdernier_choc',{''},remote,job);
        %
    else
        %
        cprintf('red*','---> ALTAIR, ANDROMEDE and SIRRAH are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    end 
    %
end
%