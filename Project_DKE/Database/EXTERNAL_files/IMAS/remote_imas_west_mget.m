function [imas_outputs]= remote_imas_west_mget(shotnumber,signals)
%
%LUKE -  Function which load signals from WEST/TORE SUPRA database using IMAS. May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		shotnumber : shot number 
%       ids_name: ids name. To see all ids_name, get data dictionary, type in Linux Terminal: dd_doc
%       imas_run: see IMAS doc
%       imas_occurrence: see IMAS doc
%       imas_user: see IMAS doc
%       imas_machine: see IMAS doc
%
% NOTE : Default option signals: imas_run=0, imas_occurrence=0,imas_user='imas_public', imas_machine='west'
%        Details on the website : https://westusers.partenaires.cea.fr
%
%   Output:
%
%		imas_outputs: IMAS data structures for the corresponding data types
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
imas_outputs = [];
%
if nargin < 2
     error('Not enough input argument in remote_imas_west_mget.m');
end
%
remote = remote_cea;
%
if isstruct(remote)
    %
    if ~isempty(strfind(remote.host,'partenaires'))
        %
        outputs = imas_west_mget(shotnumber,signals);
        %
        for ii = 1:length(signals)
            %
            imas_outputs.(signals{ii}{1}) = outputs(ii).imas_output;
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
        %job.debugmode = 1;
        %
        [err,job,outputs] = matremote_jd('imas_west_mget',{shotnumber,signals},remote,job);
        %
        if isempty(err)
            %
            for ii = 1:length(signals)
                %
                imas_outputs.(signals{ii}{1}) = outputs(ii).imas_output;
                %
            end
            %
        else
            %
            imas_outputs.err = err;
            %
        end
        %
    end
    %
else
    %
    cprintf('red*','---> CEA computers are unreachable for access to TS/WEST database. Check the connection parameters (ssh).');disp(' ')
    %
end 
%