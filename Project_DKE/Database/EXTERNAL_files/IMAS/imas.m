function [imas_output] = imas(imas_param,data_type)
%
%LUKE -  Function which load signals from WEST/TORE SUPRA IMAS database. May be used within CEA network or outside by SSH bridge
%
%   Input:
%
%		imas_param: imas structure for parameters 
%		data_type : type of signal (ex: 'equilibrium' or 'core_profiles')
%
%   Output:
%
%		imas_output: IMAS data structure for the corresponding data type
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2,
    error('Not enough input arguments in imas.m');
end
%
idx = imas_open_env('ids', imas_param.shot, imas_param.run, imas_param.user, imas_param.machine, imas_param.version);
%
if strcmp(imas_param.command,'ids_get_slice'),
    imas_output  = ids_get_slice(idx, data_type, imas_param.time_requested, 1);
else
    error('Unrecognized IMAS command in imas.m');
end
%

