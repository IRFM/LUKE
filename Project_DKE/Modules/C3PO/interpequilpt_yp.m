function [Zpp_f] = interpequilpt_yp(method,f,rho,theta,nharm)
%
% Build interpolated toroidal MHD magnetic equilibrium from its numerical counterpart
% Piecewise polynomials (1D, radial) or piecewise polynomials + Fourier series (2D, radial + poloidal)
%
% 1-D: use interp1 MatLab built-in function (Hermite polynomial (pchip) spline, bi-cubic, linear, nearest,...)
% 2-D: use Fourier series expansion for the poloidal dependence and the interp1 for the Fourier series coefficients (spline, bi-cubic, linear, nearest,...)
%
% INPUT
%    - method: interpolation method -> Hermite polynomial(pchip), spline, nearest, linear, bicubic, ...) [nchar,1]
%    - f: 1-D (rho) or 2-D (rho,theta) function to interpolate [nrho,1] or [nrho,mtheta]
%    - rho: normalized minor radius [nrho,1]
%    - theta: poloidal flux grid coordinate [1,ntheta]
%    - nharm: number of harmonics for the Fourier series expansion (<ntheta-1) [1,1]
%
% OUTPUT
%
%    - Zpp_f: structure of piecewise polynomials (1-D) and Fourier series coefficients (2-D)
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin == 3,
    %
    if isvector(f),f = f(:)';end
    Zpp_f.pp_f = ppinterp_yp(rho(:),f',size(f'),method);%Create piecewise polynomials
    %
    if ~isfield(Zpp_f.pp_f,'orient'),
        Zpp_f.pp_f.orient = 'first';
    end
    %
    Zpp_f.pp_dfdrho = Zpp_f.pp_f;%1st order derivative along rho
    Zpp_f.pp_d2fdrho2 = Zpp_f.pp_f;%2nd order derivative along rho
    %
    if Zpp_f.pp_f.order == 2,%Linear
        Zpp_f.pp_dfdrho.coefs = [Zpp_f.pp_f.coefs(:,1)];%1st order partial derivative along rho
        Zpp_f.pp_d2fdrho2.coefs = zeros(size([Zpp_f.pp_f.coefs(:,1)]));%2nd order partial derivative along rho
    elseif Zpp_f.pp_f.order == 3,%Quadratic
        Zpp_f.pp_dfdrho.coefs = [2*Zpp_f.pp_f.coefs(:,1),Zpp_f.pp_f.coefs(:,2)];%1st order partial derivative along rho
        Zpp_f.pp_d2fdrho2.coefs = [2*Zpp_f.pp_f.coefs(:,1)];%2nd order partial derivative along rho
    elseif Zpp_f.pp_f.order == 4,%cubic spline or Hermite polynomial (pchip option)
        Zpp_f.pp_dfdrho.coefs = [3*Zpp_f.pp_f.coefs(:,1),2*Zpp_f.pp_f.coefs(:,2),Zpp_f.pp_f.coefs(:,3)];%1st order partial derivative along rho
        Zpp_f.pp_d2fdrho2.coefs = [6*Zpp_f.pp_f.coefs(:,1),2*Zpp_f.pp_f.coefs(:,2)];%2nd order partial derivative along rho
    end 
    %
    Zpp_f.pp_dfdrho.order = Zpp_f.pp_f.order - 1;%1st order derivative along rho
    Zpp_f.pp_d2fdrho2.order = Zpp_f.pp_f.order - 2;%2nd order derivative along rho
    %
elseif nargin >= 4,
    if min(size(f)) == 1, error('Matrix dimensions do not agree !');end
    rho = rho(:);
    theta = theta(:);
    %
    if nargin == 4,nharm = length(theta)-1;end
    %
    if nargin == 5 & nharm > length(theta)-1,
        %nharm = length(theta)-1;
        %info_dke_yp(2,['WARNING: the number of harmonics may not exceed : ',int2str(length(theta)-1)]);
    end
    %
    if nargin == 5 & isempty(nharm),
        nharm = length(theta)-1;
    end
    %       
    FScoef = zeros(size(f,1),2*nharm + 1);
    for ii = 1:size(f,1),
        FSfun = fscreate(theta,f(ii,:),nharm,'foh');%Fourier series coefficients calculations
        FScoef(ii,:) = FSfun('coef');   
    end
    %
    Zpp_f.n = [1:nharm]';%Number of harmonics
    %
    a0 = FScoef(:,nharm+1);%f(rho,theta) = a0(rho) + sum_n(an(rho)*cos(n*theta) + bn(rho)*sin(n*theta);
    an = 2*real(FScoef(:,[nharm+2:end]));
    bn = -2*imag(FScoef(:,[nharm+2:end]));
    %
    Zpp_f.pp_a0 = ppinterp_yp(rho,a0,size(a0),method);%Interpolation of Fourier series coefficients on a fine rho grid
    Zpp_f.pp_an = ppinterp_yp(rho,an,size(an),method);%Interpolation of Fourier series coefficients on a fine rho grid
    Zpp_f.pp_bn = ppinterp_yp(rho,bn,size(bn),method);%Interpolation of Fourier series coefficients on a fine rho grid
    %   
    if ~isfield(Zpp_f.pp_a0,'orient'),
        Zpp_f.pp_a0.orient = 'first';
        Zpp_f.pp_an.orient = 'first';
        Zpp_f.pp_bn.orient = 'first';
    end
    %
    Zpp_f.pp_da0drho = Zpp_f.pp_a0;
    Zpp_f.pp_dandrho = Zpp_f.pp_an;
    Zpp_f.pp_dbndrho = Zpp_f.pp_bn;
    Zpp_f.pp_d2a0drho2 = Zpp_f.pp_a0;
    Zpp_f.pp_d2andrho2 = Zpp_f.pp_an;
    Zpp_f.pp_d2bndrho2 = Zpp_f.pp_bn;
    %
    if Zpp_f.pp_a0.order == 2,%Linear
        Zpp_f.pp_da0drho.coefs = [Zpp_f.pp_a0.coefs(:,1)];%1st order partial derivative along rho
        Zpp_f.pp_dandrho.coefs = [Zpp_f.pp_an.coefs(:,1)];%1st order partial derivative along rho
        Zpp_f.pp_dbndrho.coefs = [Zpp_f.pp_bn.coefs(:,1)];%1st order partial derivative along rho
        Zpp_f.pp_d2a0drho2.coefs = zeros(size([Zpp_f.pp_a0.coefs(:,1)]));%2nd order partial derivative along rho
        Zpp_f.pp_d2andrho2.coefs = zeros(size([Zpp_f.pp_an.coefs(:,1)]));%2nd order partial derivative along rho
        Zpp_f.pp_d2bndrho2.coefs = zeros(size([Zpp_f.pp_bn.coefs(:,1)]));%2nd order partial derivative along rho
    elseif Zpp_f.pp_a0.order == 3,%Quadratic
        Zpp_f.pp_da0drho.coefs = [2*Zpp_f.pp_a0.coefs(:,1),Zpp_f.pp_a0.coefs(:,2)];%1st order partial derivative along rho
        Zpp_f.pp_dandrho.coefs = [2*Zpp_f.pp_an.coefs(:,1),Zpp_f.pp_an.coefs(:,2)];%1st order partial derivative along rho
        Zpp_f.pp_dbndrho.coefs = [2*Zpp_f.pp_bn.coefs(:,1),Zpp_f.pp_bn.coefs(:,2)];%1st order partial derivative along rho     
        Zpp_f.pp_d2a0drho2.coefs = [2*Zpp_f.pp_a0.coefs(:,1)];%2nd order partial derivative along rho
        Zpp_f.pp_d2andrho2.coefs = [2*Zpp_f.pp_an.coefs(:,1)];%2nd order partial derivative along rho
        Zpp_f.pp_d2bndrho2.coefs = [2*Zpp_f.pp_bn.coefs(:,1)];%2nd order partial derivative along rho 
    elseif Zpp_f.pp_a0.order == 4,%cubic spline or Hermite polynomials (option pchip)
        Zpp_f.pp_da0drho.coefs = [3*Zpp_f.pp_a0.coefs(:,1),2*Zpp_f.pp_a0.coefs(:,2),Zpp_f.pp_a0.coefs(:,3)];%1st order partial derivative along rho
        Zpp_f.pp_dandrho.coefs = [3*Zpp_f.pp_an.coefs(:,1),2*Zpp_f.pp_an.coefs(:,2),Zpp_f.pp_an.coefs(:,3)];%1st order partial derivative along rho
        Zpp_f.pp_dbndrho.coefs = [3*Zpp_f.pp_bn.coefs(:,1),2*Zpp_f.pp_bn.coefs(:,2),Zpp_f.pp_bn.coefs(:,3)];%1st order partial derivative along rho
        Zpp_f.pp_d2a0drho2.coefs = [6*Zpp_f.pp_a0.coefs(:,1),2*Zpp_f.pp_a0.coefs(:,2)];%2nd order partial derivative along rho
        Zpp_f.pp_d2andrho2.coefs = [6*Zpp_f.pp_an.coefs(:,1),2*Zpp_f.pp_an.coefs(:,2)];%2nd order partial derivative along rho
        Zpp_f.pp_d2bndrho2.coefs = [6*Zpp_f.pp_bn.coefs(:,1),2*Zpp_f.pp_bn.coefs(:,2)];%2nd order partial derivative along rho
    end
    %
    Zpp_f.pp_da0drho.order = Zpp_f.pp_a0.order - 1;%1st order partial derivative along rho
    Zpp_f.pp_dandrho.order = Zpp_f.pp_an.order - 1;%1st order partial derivative along rho
    Zpp_f.pp_dbndrho.order = Zpp_f.pp_bn.order - 1;%1st order partial derivative along rho  
    Zpp_f.pp_d2a0drho2.order = Zpp_f.pp_a0.order - 2;%2nd order partial derivative along rho
    Zpp_f.pp_d2andrho2.order = Zpp_f.pp_an.order - 2;%2nd order partial derivative along rho
    Zpp_f.pp_d2bndrho2.order = Zpp_f.pp_bn.order - 2;%2nd order partial derivative along rho  
else
    error('Coordinates are missing !');
end
