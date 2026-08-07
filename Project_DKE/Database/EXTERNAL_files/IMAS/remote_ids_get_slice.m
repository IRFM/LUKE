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
function [imas_output] = remote_ids_get_slice(shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user,imas_machine,imas_backend,imas_interp)
%
%LUKE -  Function which load signals at a given time (asolute or relative to t_ignitron) from WEST/TORE SUPRA IMAS database. May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		- shotnumber : shot number 
%       - ids_name : ids name. To see all ids_name, get data dictionary, type in Linux Terminal: dd_doc
%       - time_requested : time requested -> real : relative time (s), imag : absolute time(s). To get absolute time, get time_ignitron usingvtsbase, tignitron = tsbase(shotnumber, 'rignitron');
%       - imas_run : see IMAS doc
%       - imas_occurrence : see IMAS doc
%       - imas_user : see IMAS doc
%       - imas_machine : see IMAS doc
%       - imas_backend : see IMAS doc
%       - imas_interp : see IMAS doc
%
% NOTE : Default options: imas_run=0, imas_occurrence=0,imas_user='imas_public', imas_machine='west'
%        Details on the website : https://westusers.partenaires.cea.fr
%
%   Output:
%
%		- imas_output: IMAS data structure for the corresponding data type
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
imas_output = [];
%
if nargin < 3
     error('Not enough input argument in remote_imas_get_slice.m');
end
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
        if nargin == 3
            %
            imas_output = imas_get_slice(shotnumber,ids_name,time_requested);
            %
        elseif nargin == 4
            %
            imas_output = imas_get_slice(shotnumber,ids_name,time_requested,imas_run);
            %
        elseif nargin == 5
            %
            imas_output = imas_get_slice(shotnumber,ids_name,time_requested,imas_run,imas_occurrence);
            %
        elseif nargin == 6
            %
            imas_output = imas_get_slice(shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user);
            %
        elseif nargin == 7
            %
            imas_output = imas_get_slice(shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user,imas_machine);
            %
        elseif nargin == 8
            %
            imas_output = imas_get_slice(shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user,imas_machine,imas_backend);
            %
        elseif nargin == 9
            %
            imas_output = imas_get_slice(shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user,imas_machine,imas_backend,imas_interp);
            %
        end
        %
    else
        %
        cprintf([1,0.5,0],'---> WARNING: data load may be long if ethernet connection is poor');disp(' ');
        %
        remote.matver.matdef = remote.matver.mat907;%enforce Matlab version for IMAS access
        %
        job = matstandardjob_jd('runmat');
        job.funcopy = false;%since binary is machine specific only local version is used
        %job.debugmode = 1;%
        %
        if nargin == 3
            %
            [err,job,imas_output] = matremote_jd('imas_get_slice',{shotnumber,ids_name,time_requested},remote,job);
            %
        elseif nargin == 4
            %
            [err,job,imas_output] = matremote_jd('imas_get_slice',{shotnumber,ids_name,time_requested,imas_run},remote,job);
            %
        elseif nargin == 5
            %
            [err,job,imas_output] = matremote_jd('imas_get_slice',{shotnumber,ids_name,time_requested,imas_run,imas_occurrence},remote,job);
            %
        elseif nargin == 6
            %
            [err,job,imas_output] = matremote_jd('imas_get_slice',{shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user},remote,job);
            %
        elseif nargin == 7
            %
            [err,job,imas_output] = matremote_jd('imas_get_slice',{shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user,imas_machine},remote,job);
            %
        elseif nargin == 8
            %
            [err,job,imas_output] = matremote_jd('imas_get_slice',{shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user,imas_machine,imas_backend},remote,job);
            %
        elseif nargin == 9
            %
            [err,job,imas_output] = matremote_jd('imas_get_slice',{shotnumber,ids_name,time_requested,imas_run,imas_occurrence,imas_user,imas_machine,imas_backend,imas_interp},remote,job);
            %
        end
        %
        if ~isempty(err)
            %
            imas_output.err = err;
            %
        end
        %
    end
    %
else
    %
    cprintf('red*','---> CEA computers are unreachable for access to TS/WEST database with IMAS. Check the connection parameters (ssh).');disp(' ')
    %
end 