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
function [nc] = nlogicalcores
%
% Calculate the number of logical cores
%
% INPUTS: none 
%
% OUTPUTS:
%
%   - nproc: number of logical cores [1,1]
%
% by Y. Peysson (CEA-IRFM) <yves.peysson@cea.fr>
%
if strcmp(computer,'MACI64')
    [e,nc] = unix('sysctl -n hw.ncpu');%mac OS
else
    [e,nc] = unix('grep -c ^processor /proc/cpuinfo');%linux OS
end
%
if e==0
    nc = str2num(nc);
else
    nc = [];
end