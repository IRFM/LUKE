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
function sz = sizeof( type )
%SIZEOF Get the size in bytes for an element of the specified type
%
%   bytes = gpubench.sizeof(typename) returns the number of bytes required
%   for a single real value of the specified type.
%
%   Examples:
%   >> gpubench.sizeof('double')
%   ans = 8
%   >> gpubench.sizeof('single')
%   ans = 4
%
%   See also: gpuBench

%   Copyright 2011 The MathWorks, Inc.

switch upper(type)
    case {'INT8','UINT8','LOGICAL'}
        sz = 1;
    case {'INT16','UINT16'}
        sz = 2;
    case {'INT32','UINT32'}
        sz = 4;
    case {'INT64','UINT64'}
        sz = 8;
    case 'SINGLE'
        sz = 4;
    case 'DOUBLE'
        sz = 8;
    otherwise
        error( 'SizeOf:BadType', 'Unknown type ''%s''.', type );
end
