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
shot_list = [9816,28353,32299,45525,54555];  
%
tsclean(shot_list);
%
[date_list] = remote_mtsdate(shot_list);
%
for ii = 1:length(shot_list)
    %
    disp(['Date of discharge #',int2str(shot_list(ii)),' : ',date_list{ii}])
    % 
end
