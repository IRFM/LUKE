function [threadnumber] = multithreading_luke(mode)
%LUKE - Set multithreading for LUKE automatically is possible (intrinsic multiprocessing)
%
%Set multithreading for LUKE automatically is possible (intrinsic multiprocessing)
%
%INPUT:
%
%   - mode: 'automatic' or 0,1,2,3. 0 is equivalent to automatic. 
%
%OUTPUT:
%
%   - threadnumber: number of threads activated.
%
% by Yves Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/IRFM, joan.decker@cea.fr)
%
if nargin < 1,
    mode = 'automatic';
end
%
if ischar(mode),
    if ~strcmp(mode,'automatic'),mode = 'automatic';end
else
    mode = abs(floor(mode));
    if ~mode, mode = 'automatic';end
end
%
ver = version;
if str2num(ver(1:3)) > 7.4,
    maxNumCompThreads(mode);
    threadnumber = maxNumCompThreads(mode);
end


