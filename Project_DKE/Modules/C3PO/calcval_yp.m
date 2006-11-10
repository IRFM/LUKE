function [X,dXdtheta,d2Xdtheta2,dXdrho,d2Xdthetadrho] = calcval_yp(equil_fit,a0,an,bn,da0drho,dandrho,dbndrho,theta)
%


% INPUT
%    - equil_fit: interpolated magnetic equilibrium structure
%    - a0,an,bn: Fourier expansion coefficients
%    - da0drho,dandrho,dbndrho: Radial derivatives of the Fourier expansion coefficients
%    - poloidal angle value (rad) [1,1]
%
% OUTPUT: 
%    - X: value at position (rho,theta) [1,1]
%    - dXdtheta: value of the first order poloidal derivatives at position (rho,theta) [1,1]
%    - d2Xdtheta2: value of the second order poloidal derivatives at position (rho,theta) [1,1]
%    - dXdrho: value of the first order radial derivatives at position (rho,theta) [1,1]
%    - d2Xdthetadrho: value of the second order poloidal and radial cross-derivatives at position (rho,theta) [1,1]
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin ~= 8,error('Wrong number of input arguments in calcval_yp.m');end
%
if size(an,2) ~= size(equil_fit.x_fit.n,1), an = an.';end
if size(bn,2) ~= size(equil_fit.x_fit.n,1), bn = bn.';end 
if size(dandrho,2) ~= size(equil_fit.x_fit.n,1), dandrho = dandrho.';end
if size(dbndrho,2) ~= size(equil_fit.x_fit.n,1), dbndrho = dbndrho.';end 
%
X = a0 + an*cos(equil_fit.x_fit.n*theta) + bn*sin(equil_fit.x_fit.n*theta);
dXdtheta = -an*(equil_fit.x_fit.n.*sin(equil_fit.x_fit.n*theta)) + bn*(equil_fit.x_fit.n.*cos(equil_fit.x_fit.n*theta));
d2Xdtheta2 = -an*(equil_fit.x_fit.n.^2.*cos(equil_fit.x_fit.n*theta)) - bn*(equil_fit.x_fit.n.^2.*sin(equil_fit.x_fit.n*theta));
if ~isempty(da0drho) & ~isempty(dandrho) & ~isempty(dbndrho),
   dXdrho = da0drho + dandrho*cos(equil_fit.x_fit.n*theta) + dbndrho*sin(equil_fit.x_fit.n*theta);
   d2Xdthetadrho = -dandrho*(equil_fit.x_fit.n.*sin(equil_fit.x_fit.n*theta)) + dbndrho*(equil_fit.x_fit.n.*cos(equil_fit.x_fit.n*theta));
else
   dXdrho = [];
   d2Xdthetadrho = [];
end
  
  
