function [varargout] = calcval_yp(equil_fit,theta,a0,an,bn,da0drho,dandrho,dbndrho)
%
% Calculate the local interpolated value of the magnetic equilbrium at any
% poloidal angle position
%
% INPUT
%    - equil_fit: interpolated magnetic equilibrium structure
%    - poloidal angle value (rad) [1,1]
%    - a0,an,bn: Fourier expansion coefficients
%    - da0drho,dandrho,dbndrho: Radial derivatives of the Fourier expansion coefficients
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
if nargin ~= 8 & nargin ~= 5,error('Wrong number of input arguments in calcval_yp.m');end
%
if size(an,2) ~= size(equil_fit.x_fit.n,1), an = an.';end
if size(bn,2) ~= size(equil_fit.x_fit.n,1), bn = bn.';end 
%
if nargin == 8,
    if size(dandrho,2) ~= size(equil_fit.x_fit.n,1), dandrho = dandrho.';end
    if size(dbndrho,2) ~= size(equil_fit.x_fit.n,1), dbndrho = dbndrho.';end 
end
%
X = a0 + an*cos(equil_fit.x_fit.n*theta) + bn*sin(equil_fit.x_fit.n*theta);
dXdtheta = -an*(equil_fit.x_fit.n.*sin(equil_fit.x_fit.n*theta)) + bn*(equil_fit.x_fit.n.*cos(equil_fit.x_fit.n*theta));
d2Xdtheta2 = -an*(equil_fit.x_fit.n.^2.*cos(equil_fit.x_fit.n*theta)) - bn*(equil_fit.x_fit.n.^2.*sin(equil_fit.x_fit.n*theta));
%
if nargin == 8,
    if ~isempty(da0drho) & ~isempty(dandrho) & ~isempty(dbndrho),
        dXdrho = da0drho + dandrho*cos(equil_fit.x_fit.n*theta) + dbndrho*sin(equil_fit.x_fit.n*theta);
        d2Xdthetadrho = -dandrho*(equil_fit.x_fit.n.*sin(equil_fit.x_fit.n*theta)) + dbndrho*(equil_fit.x_fit.n.*cos(equil_fit.x_fit.n*theta));
    else
        dXdrho = [];
        d2Xdthetadrho = [];
    end
end
%
if nargout >= 1 & nargin >=5, varargout{1} = X;end
if nargout >= 2 & nargin >=5, varargout{2} = dXdtheta;end
if nargout >= 3 & nargin >=5, varargout{3} = d2Xdtheta2;end
if nargout >= 4 & nargin == 8, varargout{4} = dXdrho;end
if nargout >= 5 & nargin == 8, varargout{5} = d2Xdthetadrho;end
%

