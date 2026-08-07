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
