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



