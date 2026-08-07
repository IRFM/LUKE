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
close all
clear all
clc
%
shotnumbers = [27503,27549,32299]; 
%
tsclean(shotnumbers);
%
[youts] = remote_mtsexist(shotnumbers,'GPROFTEFIT');
%
if ~isempty(youts)
    for ii = 1:length(shotnumbers)
        if youts{ii}.cr == 0 && all(youts{ii}.certif > 0)
            disp(['TPROF data available for discharge #',int2str(shotnumbers(ii))])
        else
            disp(['TPROF data unavailable or partially available for discharge #',int2str(shotnumbers(ii))])
        end
    end
else
    disp('Error : no output data from remote_mtsexist')
end