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
function [Pn,cL] = leg_dke_yp(x,m)
%
%	Fast calculation of the Legendre polynomial Pn(x) of degree m
%
%	Input:
%	
%		- x: x-vector between [-1,1] [1,n]
%		- m: degree of the Legendre polynomial [1,1]
%		  (default = 0)
%
%	Output:
%
%		- Pn: Legendre polynomials up to degree m [m+1,n]
%       - cL: Legendre coefficient up to degree m [m+1] 
%
%	Warning: Pn(k+1,:) is corresponding to the Legendre polynomial of	degree k.
%
if nargin < 1,
	infoyp(2,'Wrong number of input arguments for leg_dke_yp');
	return;
end
if nargin == 1,
	m = 0;
end
%
sx = size(x);
Pn = ones(m+1,sx(2));
Pn(2,:) = x;
%
for i=2:m,
 	Pn(i+1,:) = ((2*i-1)*x.*Pn(i,:)-(i-1)*Pn(i-1,:))/i;
end
%
cL=([1:m+1]'-1/2);
