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
youts = [];
%
for ii = 1:length(signals) % load all signals
    %
    youts{ii} = tsmat(shotnumber,signals{ii});%
    %
end