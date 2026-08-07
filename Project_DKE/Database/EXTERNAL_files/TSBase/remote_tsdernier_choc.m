% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
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
remote = remote_cea;
%
if isstruct(remote)
    %
    [err,txt] = unix('hostname');
    txt = deblank(txt);
    %
    if ~isempty(strfind(txt,'partenaires')) || ~isempty(strfind(txt,'intra'))
        %
        [shotnum] = tsdernier_choc('');
        %
    else
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');
        %
        remote.matver.matdef = remote.matver.mat913;%enforce Matlab R2013b for tsbase only
        %
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %
        [err,job,shotnum] = matremote_jd('tsdernier_choc',{''},remote,job);
        %
    end
    %
else
    %
     if isempty(remote)
        %
        cprintf('red*','---> CEA computers are unreachable for access to TSBase. Check the connection parameters (ssh).');disp(' ')
        %
    else
        %
        [shotnum] = tsdernier_choc('');
        %
    end
    %
end 
%
