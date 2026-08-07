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
function [f,df,d2f] = halftanh(x)
%
%	Half tanh for x < 0
%
%	Input:
%	
%		- x: input value [n,m]
%
%	Output:
%
%		- f: function [n,m]
%		- df: first derivative [n,m]
%		- d2f: second derivative [n,m]
%
f = x;
f(x<0) = tanh(x(x<0));
f(x<-400) = -1;
%
df = ones(size(x));
df(x<0) = 1.0./cosh(x(x<0))./cosh(x(x<0));
df(x<-400) = 0;
%
d2f = zeros(size(x));
d2f(x<0) = -2.0*sinh(x(x<0))./cosh(x(x<0)).^3;
d2f(x<-400) = 0;
%

