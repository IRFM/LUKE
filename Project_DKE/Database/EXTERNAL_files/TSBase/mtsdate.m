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
function ydates = mtsdate(shotnumbers)
%
%LUKE : multiple load of shot dates from Tore Supra database 
%
%   Input:
%
%       shotnumbers: list of shot numbers (ex: [32299,45525])
%
%   Output:
%
%       ydates: dates structure
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2
    error('');
end
%
for ii = 1:length(shotnumbers) % load all signals
    %
    ydates{ii} = tsdate(shotnumbers(ii));
    %
end