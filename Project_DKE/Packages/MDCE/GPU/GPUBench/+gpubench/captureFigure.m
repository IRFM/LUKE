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
function captureFigure( figh, filename, trim )
%captureFigure: use print to capture a figure with over-sampling
%
%   gpubench.captureFigure(figh,filename,trim)

%   Copyright 2011 The MathWorks, Inc.

if nargin<3
    trim = true;
end

% Have to hard-code the DPI since Windows doesn't report it correctly
% dpi = get(0,'ScreenPixelsPerInch');
%dpi = 192;
dpi = 160;

% Copy the position to the paper position to get the size right
pos = get( figh, 'Position' );
set( figh, 'PaperUnits', 'Points', 'PaperPosition', pos );

% Print the image to file at screen resolution
print( figh, '-zbuffer', sprintf('-r%d',round(0.5*dpi)), '-dpng', filename );

% Load and trim the top whitespace
gpubench.trimImage( filename, trim );
