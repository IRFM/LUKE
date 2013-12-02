function [varargout] = calcval_yp(fit,theta,a0,an,bn,da0drho,dandrho,dbndrho,d2a0drho2,d2andrho2,d2bndrho2)
%
% Calculate the local interpolated value at any poloidal angle position,
% modified 29/11/2013 by E. Nilsson to take vectorial form of
% theta* as input
%
% INPUT
%    - fit: interpolated structure
%    - poloidal angle value (rad) [1,1], can be up to 3D
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
Xa0 = repmat(a0(:),[1,size(theta,1),size(theta,2)]);
%
Zan = repmat(an,[1,1,size(theta,1),size(theta,2)]);
Zbn = repmat(bn,[1,1,size(theta,1),size(theta,2)]);
%
Zn = permute(repmat(n(:),[1,size(a0(:),1),size(theta,1),size(theta,2)]),[2,1,3,4]);
%
Ztheta = permute(repmat(theta,[1,1,size(a0(:),1),size(n(:),1)]),[3,4,1,2]);
%
X = squeeze(Xa0) + squeeze(sum(Zan.*cos(Zn.*Ztheta) + Zbn.*sin(Zn.*Ztheta),2));
dXdtheta = squeeze(sum(-Zan.*(Zn.*sin(Zn.*Ztheta)) + Zbn.*(Zn.*cos(Zn.*Ztheta)),2));
d2Xdtheta2 = squeeze(sum(-Zan.*(Zn.^2.*cos(Zn.*Ztheta)) - Zbn.*(Zn.^2.*sin(Zn.*Ztheta)),2));
%
if nargin >= 8,
    if ~isempty(da0drho) & ~isempty(dandrho) & ~isempty(dbndrho),
        %
        Xda0drho = repmat(da0drho(:),[1,size(theta,1),size(theta,2)]);
        Zdandrho = repmat(dandrho,[1,1,size(theta,1),size(theta,2)]);
        Zdbndrho = repmat(dbndrho,[1,1,size(theta,1),size(theta,2)]);
        %
        dXdrho = squeeze(Xda0drho) + squeeze(sum(Zdandrho.*cos(Zn.*Ztheta) + Zdbndrho.*sin(Zn.*Ztheta),2));
        d2Xdthetadrho = squeeze(sum(-Zdandrho.*(Zn.*sin(Zn.*Ztheta)) + Zdbndrho.*(Zn.*cos(Zn.*Ztheta)),2));
    else
        dXdrho = [];
        d2Xdthetadrho = [];
    end
end
%
if nargin == 11,
    if ~isempty(d2a0drho2) & ~isempty(d2andrho2) & ~isempty(d2bndrho2),
        %
        Zd2andrho2 = repmat(d2andrho2,[1,1,size(theta,1),size(theta,2)]);
        Zd2bndrho2 = repmat(d2bndrho2,[1,1,size(theta,1),size(theta,2)]);
        %
        d2Xdrho2 = squeeze(Xd2a0drho2) + squeeze(sum(Zd2andrho2.*cos(Zn.*Ztheta) + Zd2bndrho2.*sin(Zn.*Ztheta),2));
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

