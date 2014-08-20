function [R_sep0,Z_sep0] = sep4helmex_yp(xpoint,ntheta)
%
%   Create the separatrix for the toroidal MHD equilibrium solver HELENA (helmex)
%
%   INPUTS
%
%       - xpoint : parameters of the shape of the separatrix
%       - ap : minor radius of the plasma at Zp = 0 (m) [1,1] 
%       - Rp : major radius of the plasma (m) [1,1] 
%       - Zp : vertical shift of the plasma (m) [1,1] 
%       - ntheta: number of poloidal points for the separatrix [1,1]
%           (default = 65)
%
%   OUTPUTS
%
%       - R_sep0 :  seperatrix major radius [1,ntheta]
%       - Z_sep0 :  seperatrix vertical position [1,ntheta]
%
%
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (EPFL/CRPP,joan.decker@epfl.ch)
%
if nargin < 5,
    ntheta = 65;
end
%
if nargin < 1,
    error('No enough input arguments in sep4helmex_yp.m');
end
%
ap = xpoint(9);
Rp = xpoint(10);
Zp = xpoint(11);
%
lim_top = atan(0.5*xpoint(1)/(1-xpoint(2)))*180/pi;%In order to avoid convergence problem in separatrix MEX file
if xpoint(4) > lim_top,xpoint(4) = lim_top - 0.1;end
lim_bottom = atan(0.5*xpoint(5)/(1-xpoint(6)))*180/pi;%In order to avoid convergence problem in separatrix MEX file
if xpoint(8) > lim_bottom,xpoint(8) = lim_bottom - 0.1;end
%
[x1,y1] = separatrice(xpoint,1);%The LCS is approximated by four ellipses (mode = 1)
%
rr = x1*ap;
zz = y1*ap;
%
alpha  = unwrap(angle(rr+ i .* zz));%poloidal angle
if alpha(end) < -5
    alpha = alpha - alpha(end);
end
%
theta_sep  = linspace(0,2*pi,ntheta);% poloidal points
%
ind = find(diff(alpha) == 0);
alpha(ind) = [];
%
rr(ind) = [];
zz(ind) = [];
%    
R_sep0 = spline(alpha',rr',theta_sep) + Rp;%resampling 
Z_sep0 = spline(alpha',zz',theta_sep) + Zp;%resampling 

