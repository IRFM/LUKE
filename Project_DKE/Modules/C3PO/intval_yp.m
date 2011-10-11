function [varargout] = intval_yp(fit,theta0,theta,a0,an,bn,da0drho,dandrho,dbndrho)
%
% Calculate the local interpolated value at any poloidal angle position and
% radial position of the integral of X and dXdrho (for the phase of the
% plasma fluctations)
%
% INPUT
%    - fit: interpolated structure
%    - theta0: initial poloidal angle value (rad) [1,1]
%    - theta: poloidal angle value (rad) [1,1]
%    - a0,an,bn: Fourier expansion coefficients
%    - da0drho,dandrho,dbndrho: 1st order radial derivatives of the Fourier expansion coefficients
%
% OUTPUT: 
%    - int02theta_X: value of the integral of X from 0 to theta at position (rho,theta) [1,1]
%    - int02theta_dXdrho:: value of the integral dXdrho from 0 to theta at position (rho,theta) [1,1]
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if isfield(fit,'x_fit'), fit = fit.x_fit;end%backward compatibility with equilfit_yp
%
if nargin ~= 9 & nargin ~= 6,error('Wrong number of input arguments in intval_yp.m');end
%
if size(an,2) ~= size(fit.n,1), an = an.';end
if size(bn,2) ~= size(fit.n,1), bn = bn.';end 
%
if nargin == 9,
    if size(dandrho,2) ~= size(fit.n,1), dandrho = dandrho.';end
    if size(dbndrho,2) ~= size(fit.n,1), dbndrho = dbndrho.';end 
end
%
n = fit.n;
%
int02theta_X = a0*(theta - theta0) + (an./n')*(sin(n*theta) - sin(n*theta0)) + (bn./n')*(cos(n*theta0) - cos(n*theta));
%
if nargin == 9,
    if ~isempty(da0drho) & ~isempty(dandrho) & ~isempty(dbndrho),
        int02theta_dXdrho = da0drho*(theta - theta0) + (dandrho./n')*(sin(n*theta) - sin(n*theta0)) + (dbndrho./n')*(cos(n*theta0) - cos(n*theta));
    else
        int02theta_dXdrho = [];
    end
end
%
if nargout >= 1, varargout{1} = int02theta_X;end
if nargout >= 2, varargout{2} = int02theta_dXdrho;end

