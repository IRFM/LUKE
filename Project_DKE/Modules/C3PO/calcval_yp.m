function [varargout] = calcval_yp(fit,theta,a0,an,bn,da0drho,dandrho,dbndrho,d2a0drho2,d2andrho2,d2bndrho2)
%
% Calculate the local interpolated value at any poloidal angle position
%
% INPUT
%    - fit: interpolated structure
%    - poloidal angle value (rad) [1,1]
%    - a0,an,bn: Fourier expansion coefficients
%    - da0drho,dandrho,dbndrho: 1st order radial derivatives of the Fourier expansion coefficients
%    - d2a0drho2,d2andrho2,d2bndrho2: 2nd order radial derivatives of the Fourier expansion coefficients
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
if isfield(fit,'x_fit'), fit = fit.x_fit;end%backward compatibility with equilfit_yp
%
if nargin ~= 11 & nargin ~= 8 & nargin ~= 5,error('Wrong number of input arguments in calcval_yp.m');end
%
if size(an,2) ~= size(fit.n,1), an = an.';end
if size(bn,2) ~= size(fit.n,1), bn = bn.';end 
%
if nargin >= 8,
    if size(dandrho,2) ~= size(fit.n,1), dandrho = dandrho.';end
    if size(dbndrho,2) ~= size(fit.n,1), dbndrho = dbndrho.';end 
end
%
if nargin == 11,
    if size(d2andrho2,2) ~= size(fit.n,1), d2andrho2 = d2andrho2.';end
    if size(d2bndrho2,2) ~= size(fit.n,1), d2bndrho2 = d2bndrho2.';end 
end
%
n = fit.n;
%
X = a0 + an*cos(n*theta) + bn*sin(n*theta);
dXdtheta = -an*(n.*sin(n*theta)) + bn*(n.*cos(n*theta));
d2Xdtheta2 = -an*(n.^2.*cos(n*theta)) - bn*(n.^2.*sin(n*theta));
%
if nargin >= 8,
    if ~isempty(da0drho) & ~isempty(dandrho) & ~isempty(dbndrho),
        dXdrho = da0drho + dandrho*cos(n*theta) + dbndrho*sin(n*theta);
        d2Xdthetadrho = -dandrho*(n.*sin(n*theta)) + dbndrho*(n.*cos(n*theta));
    else
        dXdrho = [];
        d2Xdthetadrho = [];
    end
end
%
if nargin == 11,
    if ~isempty(d2a0drho2) & ~isempty(d2andrho2) & ~isempty(d2bndrho2),
        d2Xdrho2 = d2a0drho2 + d2andrho2*cos(n*theta) + d2bndrho2*sin(n*theta);
    else
        d2Xdrho2 = [];
    end
end
%
if nargout >= 1 & nargin >=5, varargout{1} = X;end
if nargout >= 2 & nargin >=5, varargout{2} = dXdtheta;end
if nargout >= 3 & nargin >=5, varargout{3} = d2Xdtheta2;end
if nargout >= 4 & nargin >= 8, varargout{4} = dXdrho;end
if nargout >= 5 & nargin >= 8, varargout{5} = d2Xdthetadrho;end
if nargout >= 6 & nargin == 11, varargout{6} = d2Xdrho2;end
%

