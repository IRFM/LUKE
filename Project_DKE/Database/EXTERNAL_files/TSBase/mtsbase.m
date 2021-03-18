function youts = mtsbase(shotnumber,signals)
%
%LUKE : multple load of signals from Tore Supra database
%
%   Input:
%
%		shotnumber: shot number (ex: 45525)
%		signals : structure of signal types (ex: {'gphyb','gphase',...})
%
%   Output:
%
%       youts: signals structure
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2
    error('');
end
%
for ii = 1:length(signals) % load all signals
    %
    [youts(ii).yout1,youts(ii).yout2,youts(ii).yout3,youts(ii).yout4,youts(ii).yout5] = tsbase(shotnumber,signals{ii});%
    %
end