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
function [sf] = trapzyp(f)
%
%	Numerical integration by the trapeze's method of a function y = f(x).
%	Steps may be irregular. 
%
%	Input:
%
%		- f: [x,f1,f2,...,fn], x is the abciss vector, fi are n functions [m,n+1]
%
%	Output:
%
%		- sf: [sf1,sf2,...,sfn], sum of fi's [m,n] 
%
if nargin < 1,
	infoyp(2,'Wrong number of input arguments for trapz_dke_yp');
	return;
end
%
[m,n] = size(f);
%
if m > 2,
	delta = f(2:1:m,1)-f(1:1:m-1,1);
	ff = (f(2:1:m,2:1:n) + f(1:1:m-1,2:1:n))/2;
	sf = sum((delta*ones(1,n-1)).*ff);
elseif m == 2,
	sf = (f(1,2:1:n) + f(2,2:1:n))/2;
elseif m == 1,
	sf = f(1,2:1:n);
elseif m == 0,
	error('Empty matrix in trapz_dke_yp');
end

