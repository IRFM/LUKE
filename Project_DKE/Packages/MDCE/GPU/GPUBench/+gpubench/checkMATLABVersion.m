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
function checkMATLABVersion()
%checkMATLABVersion  error if the MATLAB version is not suitable

%   Copyright 2011 The MathWorks, Inc.

v = ver('MATLAB');
v = regexp( v.Version, '(?<major>\d+)\.(?<minor>\d+)', 'names' );
v.major = str2double( v.major );
v.minor = str2double( v.minor );
if (v.major < 7) || ((v.major==7) && (v.minor<13))
    error( 'GPUBench:MATLABVersion', 'GPUBench requires MATLAB version 7.13 (R2011b) or higher' );
end
