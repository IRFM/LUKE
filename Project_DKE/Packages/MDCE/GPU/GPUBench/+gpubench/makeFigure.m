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
function fig = makeFigure( name )
%makeFigure  create a figure suitable for printing in a GPUBench report
%
%   fig = gpubench.makeFigure(name)

%   Copyright 2011 The MathWorks, Inc.

fig = figure( 'Name', name, ...
    'NumberTitle', 'off', ...
    'Color', 'w', ...
    'InvertHardCopy', 'off', ...
    'Renderer', 'ZBuffer', ...
    'Visible', 'off' );
set( fig, 'DefaultAxesColor', 0.95*[1 1 1] );
