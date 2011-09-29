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
%by Y.PEYSSON CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
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

