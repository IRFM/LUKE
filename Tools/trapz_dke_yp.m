function [sf] = trapzyp(f)
%
%	Numerical integration by the trapeze's method of a function y = f(x).
%	Steps may be irregular. 
%
%	Input:
%
%		- f: [x,f1,f2,...,fm], x is the abciss vector, fi are m functions [n,m+1]
%
%	Output:
%
%		- sf: [sf1,sf2,...,sfm], sum of fi's [n,m] 
%
%
%by Y.PEYSSON CEA-DRFC 11/10/1991 <peysson@drfc.cad.cea.fr>
%revised for MatLab 4.1 (31/08/1994) 
%revised for MatLab 5.2 (31/08/2000) 
%
if nargin < 1,
	infoyp(2,'Wrong number of input arguments for trapezeyp');
	return;
end
%
[n,m] = size(f);
%
%sf=(f(2,1)-f(1,1))*sum(f(:,2:m));
%
if n > 2,
	delta = f(2:1:n,1)-f(1:1:n-1,1);
	ff = (f(2:1:n,2:1:m) + f(1:1:n-1,2:1:m))/2;
	sf = sum((delta*ones(1,m-1)).*ff);
elseif n == 2,
	sf = (f(1,2:1:m) + f(2,2:1:m))/2;
elseif n == 1,
	sf = f(1,2:1:m);
elseif n == 0,
	error('Empty matrix in trapzyp');
end

