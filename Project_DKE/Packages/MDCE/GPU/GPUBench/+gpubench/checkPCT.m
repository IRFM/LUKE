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
function checkPCT()
%checkPCT  check that Parallel Computing Toolbox is installed and licensed

%   Copyright 2011 The MathWorks, Inc.


pctInstalled = exist( 'gpuArray', 'file' ) == 2;
if ~pctInstalled
    error( 'GPUBench:PCTNotInstalled', 'GPUBench requires Parallel Computing Toolbox which does not appear to be installed.' );
end

pctLicensed = license( 'test', 'distrib_computing_toolbox' );
if ~pctLicensed
    error( 'GPUBench:NoPCTLicense', 'No Parallel Computing Toolbox license was available.' );
end
