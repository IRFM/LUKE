function [z] = g_dke_yp(x,y)
%
%    Chang and Cooper function for Fokker-Planck calculations
%    see ref. C.F.F.Karney in Computer Physics Reports 4 (1986) 183-244
%
%    Input:
%         
%         - x: initial vector (uniform grid term) [n,m]
%         - y: initial vector (non-uniform grid term) [n,m]
%				(default y = 0, uniform grid)
%
%    Output: 
%
%         - z: Chang and Cooper function [n,m]
%
%Last Update: 02/12/2002
%
%by Y.PEYSSON CEA-DRFC 11/05/1993 <yves.peysson@cea.fr>
%revised for MatLab 4.1 (07/09/1994) 
%revised for MatLab 5.2 (04/07/2002) 
%
if nargin < 1,
     error('Wrong number of input arguments for g_dke_yp');
elseif nargin == 1,
	  y = zeros(size(x));%Uniform grid
end
%
z = zeros(size(x));
mask = abs(x)>1e-6;
z(mask) = 1.0./x(mask) - 1.0./(exp(x(mask) + y(mask)) - 1);
%
if sum(sum(y)) == 0,
	z(~mask) = 0.5 - x(~mask)/12 + (x(~mask)).^3/720;
end
%
