function youts = mtsmat(shotnumber,signals)
%
%LUKE : multple load of signals from Tore Supra database
%
%   Input:
%
%       shotnumber: shot number (ex: 0)
%       signals : structure of signal types (ex: {'EXP=T=S;TORE_SUPRA;LISTDIAG','EXP=T=S;General;Itor',...})
%
%   Output:
%
%	youts: signal structure
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2
    error('');
end
%
for ii = 1:length(signals) % load all signals
    %
    yout = [];
    %
    [yout] = tsmat(shotnumber,signals{ii});%
    %
    youts(ii) = yout;
    %
end