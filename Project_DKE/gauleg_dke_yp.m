function [x,w] = gauleg_dke_yp(n,epsi,x1,x2)
%
%	Calculation of the weights for the Gauss-Legendre quadrature. Ribicki's algorithm 
%
%	Input:
%	
%		- n: number of weigth [1,1]
%		  (default = 50)
%		- epsi: precision [1,1]
%		  (default = 1e-14)
%		- x1: lower limit [1,1]
%		  (default = -1)
%		- x2: upper limit [1,1]
%		  (default = +1)
%
%	Output:
%
%		- x: Gauss-Legendre quadrature x-values [n,1]
%		- w: Gauss-Legendre quadrature weights at x-values [n,1]
%
%
%by Y.PEYSSON CEA-DRFC 16/05/1991 <yves.peysson@cea.fr>
%revised for MatLab 4.1 (30/08/1994) 
%
if nargin < 0,
	infoyp(2,'Wrong number of input arguments for gaulegyp');
	return;
end
if nargin == 0,
	n = 50;
	epsi = 1e-14;
	x1 = -1;
	x2 = 1;
elseif nargin == 1,
	epsi = 1e-14;
	x1 = -1;
	x2 = 1;
elseif nargin == 2,
	x1 = -1;
	x2 = 1;
elseif nargin == 3,
	x2 = 1;
end
%
m = (n+1)/2;
xm = 0.5*(x2+x1);xl = 0.5*(x2-x1);
for i=1:m,
 	z = cos(pi*(i-0.25)/(n+0.5));
 	p1 = 1.0;
 	p2 = 0.0;
 	for j=1:n,
  		p3 = p2;p2 = p1;p1 = ((2.0*j-1.0)*z*p2-(j-1.0)*p3)/j;
 	end
 	pp = n*(z*p1-p2)/(z*z-1.0);z1 = z;z = z1-p1/pp;
 	test = abs(z-z1)-epsi;
 	while test > 0,
  		p1 = 1.0;p2 = 0.0;
  		for j=1:n
   			p3 = p2;p2 = p1;p1 = ((2.0*j-1.0)*z*p2-(j-1.0)*p3)/j;
  		end
  		pp = n*(z*p1-p2)/(z*z-1.0);z1 = z;z = z1-p1/pp;
  		test = abs(z-z1)-epsi;
 	end
 	x(i) = xm-xl*z;x(n+1-i) = xm+xl*z;
 	w(i) = 2.0*xl/((1.0-z*z)*pp*pp);w(n+1-i) = w(i);
end
%
x = x(:);
w = w(:);
