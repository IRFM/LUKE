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
function [SX] = integral_dke_jd(dx,X,d)
%
%	Numerical integration on the dimension d of the matrix X, with steps dx
%
%	Input:
%
%		- dx: steps [1,nx]
%       - X: matrix [nd dimensions, dim d of size nx]
%       - d: dimension for integration
%
%	Output:
%
%		- sf: integrated matrix, of dimension nd-1 
%
if nargin < 3,
	error('Wrong number of input arguments for integral_dke_jd');
end
%
nd = ndims(X);
ndx = length(dx);
%   
if size(X,d) ~= ndx
	error('Dimension mismatch');
end 
%
if ndx == 0
    SX = [];
    return
end
if ndx == 1
    %SX = squeeze(X);
    SX = squeeze(X*dx);
    if size(SX,1) == 1
        SX = SX.';
    end
    return;
end
Xs = shiftdim(X,d-1);
clear X
dx = dx(:);
%
sizeXs = size(Xs);
Xdxs = zeros(sizeXs);
nds = ndims(Xs);
if nds > 1
    Xdxs = repmat(dx,[1,sizeXs(2:nds)]);
else
    Xdxs = dx;
end
%
SXs = sum(Xdxs.*Xs);
clear Xdxs Xs
%
if nd > 2
%    SXs = squeeze(SXs);
%   SX = shiftdim(SXs,nd-d);
    SX = shiftdim(shiftdim(SXs,1),nd-d);
else
    SX = SXs.';
end

