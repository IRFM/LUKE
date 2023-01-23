function [imas_output]= remote_imas_west_get(shotnumber,ids_name,imas_run,imas_occurrence,imas_user,imas_machine)
%
%LUKE -  Function which load signals from WEST/TORE SUPRA IMAS database. May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber: shot number 
%       ids_name: ids name. To see all ids_name, get data dictionary, type in Linux Terminal: dd_doc
%       imas_run: see IMAS doc
%       imas_occurrence: see IMAS doc
%       imas_user: see IMAS doc
%       imas_machine: see IMAS doc
%
% NOTE : Default options: imas_run=0, imas_occurrence=0,imas_user='imas_public', imas_machine='west'
%        Details on the website : https://westusers.partenaires.cea.fr
%
%   Output:
%
%		imas_output: IMAS data structure for the corresponding data type
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
imas_output = [];
%
if nargin < 2,
     error('Not enough input argument in remote_imas_west_get.m');
end
%
remote = remote_cea;
%
if isstruct(remote)
    %
    cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
    %
    remote.matver.matdef = remote.matver.mat907;%enforce Matlab version for IMAS access
    %
    job = matstandardjob_jd('runmat');
    job.funcopy = false;%since binary is machine specific only local version is used
    %job.debugmode = 1;%
    %
    if nargin == 2
        %
        [err,job,imas_output] = matremote_jd('imas_west_get',{shotnumber,ids_name},remote,job);
        %
    elseif nargin == 3
        %
        [err,job,imas_output] = matremote_jd('imas_west_get',{shotnumber,ids_name,imas_run},remote,job);
        %
    elseif nargin == 4
        %
        [err,job,imas_output] = matremote_jd('imas_west_get',{shotnumber,ids_name,imas_run,imas_occurrence},remote,job);
        %
    elseif nargin == 5
        %
        [err,job,imas_output] = matremote_jd('imas_west_get',{shotnumber,ids_name,imas_run,imas_occurrence,imas_user},remote,job);
        %
    elseif nargin == 6
        %
        [err,job,imas_output] = matremote_jd('imas_west_get',{shotnumber,ids_name,imas_run,imas_occurrence,imas_user,imas_machine},remote,job);
        %
    end
    %
    if ~isempty(err)
        %
        imas_output.err = err;
        %
    end
    %
else
    %
    cprintf('red*','---> CEA computers are unreachable for access to TS/WEST database with IMAS. Check the connection parameters (ssh).');disp(' ')
    %
end 