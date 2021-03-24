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
    ydates{ii} = tsdate(shotnumber(ii);%
    %
end