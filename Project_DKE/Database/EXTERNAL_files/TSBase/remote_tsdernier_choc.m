function [shotnum]= remote_tsdernier_choc
%
%LUKE -  Function which gives the last shot number Tore Supra database. Includes WEST too. May be used within CEA network or outside by SSH bridge
%
%   Input: None
%
%   Output:
%
%		shotnum: last shot number 
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
shotnum = [];
%
[remote,err] = remote_cea;
%
if err == 0 && isstruct(remote)
    %
    cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');
    %
    remote.matver.matdef = remote.matver.mat903;%enforce Matlab R2013b for tsbase only
    %
    job = matstandardjob_jd('runmat');
    job.funcopy = false;%since binary is machine specific only local version is used
    %
    [err,job,shotnum] = matremote_jd('tsdernier_choc',{''},remote,job);
    %
else
    %
    cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
    %
end 
%