function [x0,y0] = stairs_dke_yp(x,y,xlabelmode,ylabelmode,titlemode,xlimmode,ylimmode,colormode,linemode,widthmode,mode)
%
%	Customized stairs-step plot with various linetype and color display options.
% 	(see function stairs.m)
%
%	Input: 
%
%		- x: vector [1,m]
%		- y: vector (optional) [1,m]
%		- tt: string for color display and linetype (optional) [1,p]
%		- mode: 1 -> centering the step around x, 0 -> the step starts at x[1,1]
%		  (default = 1)
% 
%	Output: 
%	
%		- x0: vector [1,m]
%		- y0: vector [1,m]
% 
%
%by Y.PEYSSON CEA-DRFC <yves.peysson@cea.fr>
%
n = length(x);
delta = (max(x) - min(x)) / (n-1);
nn = 2*n;
yy = zeros(nn+2,1);
xx = yy;
t = x(:)' - mode*0.5*delta;
xx(1:2:nn) = t;
xx(2:2:nn) = t;
xx(nn+1:nn+2) = t(n) + [delta;delta];
yy(2:2:nn) = y;
yy(3:2:nn+1) = y;
if nargout == 0
   [ax] = graph1D_jd(xx,yy,0,1,xlabelmode,ylabelmode,titlemode,NaN,xlimmode,ylimmode,linemode,'none',colormode,widthmode);
else
	xo = xx;
	yo = yy;
end
