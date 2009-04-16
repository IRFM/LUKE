function [threadnumber] = multithreading_luke(dkepath)
%LUKE - Set multithreading for LUKE automatically is possible (intrinsic multiprocessing)
%
%Set multithreading for LUKE automatically is possible (intrinsic multiprocessing)
%
%INPUT:
%
%   - dkepath: hardware and sofware configuration + paths (structure)
%
%OUTPUT:
%
%   - threadnumber: number of threads activated.
%
% by Yves Peysson (CEA/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/IRFM, joan.decker@cea.fr)
%
if ~isfield(dkepath,'maxcompthreads'),
    mode = 'automatic';
else
	mode = dkepath.maxcompthreads;
end
%
if ischar(mode),
    if ~strcmp(mode,'automatic'),
    	mode = str2num(mode);
    end
end
%
maxNumCompThreads(mode);
threadnumber = maxNumCompThreads(mode);



