function youts = mtsbase(shotnumber,signals)
%
%LUKE : multple load of signals from Tore Supra database
%
%   Input:
%
%       shotnumber: shot number (ex: 45525)
%       signals : structure of signal types (ex: {'gphyb','gphase',...})
%
%   Output:
%
%	youts: signals structure
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin < 2
    error('');
end
%
youts = [];
%
for ii = 1:length(signals) % load all signals
    %
    yout1 = [];
    yout2 = [];
    yout3 = [];
    yout4 = [];
    yout5 = [];
    %
    [yout1,yout2,yout3,yout4,yout5] = tsbase(shotnumber,signals{ii});%
    %
    youts(ii).yout1	= yout1;
    youts(ii).yout2	= yout2;
    youts(ii).yout3	= yout3;
    youts(ii).yout4	= yout4;
    youts(ii).yout5 = yout5;
    %
end