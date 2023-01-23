function [imas_output] = imas_get_slice(shot,ids_name,time_requested,run,occ,user,machine,backend,interp)
%
%LUKE -  Function which load signals at a given time (asolute or relative to t_ignitron) from WEST/TORE SUPRA IMAS database. May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		- shot: shot number 
%       - ids_name: ids name. To see all ids_name, get data dictionary, type in Linux Terminal: dd_doc
%       - time_requested: time requested -> real : relative time (s), imag : absolute time(s). To get absolute time, get time_ignitron usingvtsbase, tignitron = tsbase(shotnumber, 'rignitron');
%       - run: see IMAS doc
%       - occ: see IMAS doc
%       - user: see IMAS doc
%       - machine: see IMAS doc
%       - backend : see IMAS doc, support -> 12 : MDS+, 13 : HDF5
%       - interp : see IMAS doc (interpolation method)
%
% NOTE : Default options: imas_run=0, imas_occurrence=0,imas_user='imas_public', imas_machine='west'
%        Details on the website : https://westusers.partenaires.cea.fr
%
%   Output:
%
%		- imas_output: IMAS data structure for the corresponding data type at the given time
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
imas_output = [];
%
if nargin < 3
     error('Not enough input argument in imas_get_slice.m');
end
%
if isreal(time_requested)
    %
    tignitron = tsbase(shot,'rignitron');
    time_ref = tignitron + time_requested;
    %
else
    %
    time_ref = time_requested;
    %
end
%
idx = imas_open_env_backend(shot, run, user, machine, '3', backend);
%
imas_output = ids_get_slice(idx, ids_name, time_requested, occ, interp);
%
imas_close(idx);
%