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