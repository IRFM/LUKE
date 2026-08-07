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
function plotFLOPS( data, color, linewidth )
%plotFLOPS  plot some gpuBench data as floating-point operations per second
%
%   gpubench.plotFLOPS(data,color,linewidth)

%   Copyright 2011 The MathWorks, Inc.

semilogx( data.Sizes, 1e-9 * data.NumOps ./ data.Times, ...
    'Color', color, ...
    'Marker', '.', ...
    'MarkerSize', 10+6*linewidth, ...
    'linewidth', linewidth )
xlabel( 'Number of elements' )
ylabel( sprintf('GFLOPS\n(higher is better)') )
grid( 'on' )
hold( 'on' )
