function imas_outputs = imas_west_mget(shotnumber,signals)
%
%LUKE : multple load of signals from TS/WEST database with IMAS
%
%   Input:
%
%       shotnumber: shot number 
%       signals : structure of signals for IMAS (ex: signals{1} = {ids_name,imas_run,imas_occurrence,imas_user,imas_machine}, signals{2} = {ids_name,imas_run,imas_occurrence], ...)
%
%   Output:
%
%	youts: signals structure
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2
    %
    error('Not enough input argument in imas_west_mget.m');
    %
end
%
for ii = 1:length(signals) % load all signals
    %
    imas_output = [];
    %
    if length(signals{ii}) == 1
        %
        imas_output = imas_west_get(shotnumber,signals{ii}{1});
        %
    elseif length(signals{ii}) == 2
        %
        imas_output = imas_west_get(shotnumber,signals{ii}{1},signals{ii}{2});
        %
    elseif length(signals{ii}) == 3
        %
        imas_output = imas_west_get(shotnumber,signals{ii}{1},signals{ii}{2},signals{ii}{3});
        %
    elseif length(signals{ii}) == 4
        %
        imas_output = imas_west_get(shotnumber,signals{ii}{1},signals{ii}{2},signals{ii}{3},signals{ii}{4});
        %
    elseif length(signals{ii}) == 5
        %
        imas_output = imas_west_get(shotnumber,signals{ii}{1},signals{ii}{2},signals{ii}{3},signals{ii}{4},signals{ii}{5});
        %
    end
    %
    imas_outputs(ii).imas_output = imas_output;
    %
end
