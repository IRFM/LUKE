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
function trimImage( filename, doCrop )
%trimImage  Trim white-space from around an image
%
%   gpubench.trimImage(filename, doCrop)

%   Copyright 2011 The MathWorks, Inc.

if nargin<2
    doCrop = true;
end

cdata = imread( filename );
isWhite = all( cdata==255, 3 );

% Try to work out where the canvas starts so that we can turn everything
% outside transparent. We assume any row or column which is >75% white is
% outside the axes.
whiteRowRatio = sum( isWhite, 2 ) / size( isWhite, 2 );
firstCanvasRow = find( whiteRowRatio < 0.75, 1, 'first' );
lastCanvasRow = find( whiteRowRatio < 0.75, 1, 'last' );
whiteColRatio = sum( isWhite, 1 ) / size( isWhite, 1 );
firstCanvasCol = find( whiteColRatio < 0.75, 1, 'first' );
lastCanvasCol = find( whiteColRatio < 0.75, 1, 'last' );
% Create the alpha channel
alpha = ~isWhite;
alpha(firstCanvasRow:lastCanvasRow, firstCanvasCol:lastCanvasCol) = 1;

% Crop any spare white-space
if doCrop
    whiteRows = all( isWhite, 2 );
    firstRow = find( ~whiteRows, 1, 'first' );
    cdata = cdata(firstRow:end, :, :);
    alpha = alpha(firstRow:end, :, :);
end

% Write the result back
imwrite( cdata, filename, 'Alpha', double(alpha) );