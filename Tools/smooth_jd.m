function xfs = smooth_jd(x,xf,dxs);
%
% Gaussian smoothering of function xf on grid x with smooting Gaussian
% width dxs (default: mean step size of x)
% 
% by J. Decker 30/06/06
%
if nargin < 2,
    error('Not enough input arguments')
end
%
Sx = size(x);
if length(Sx) ~= 2 || min(Sx) ~= 1 || max(Sx) == 1,
    error('x must be a vector')
else
    x = x(:);
    nx = length(x);
end
%
if min(diff(x)) <= 0,
    error('x must be monotonic');
end
%
if nargin < 3,
    dxs = mean(diff(x));
end
%
Sdx = size(dxs);
if length(Sdx) ~= 2 | Sdx ~= [1,1],
    error('dxs must be a scalar')
end
%
Sf = size(xf);
if Sf(1) ~= nx,
    error('The first dimension of xf must have the same length as x')
end
%
Sff = Sf(2:length(Sf));
%
x_S = [x(1) - (x(2) - x(1))/2; (x(1:nx-1) + x(2:nx))/2; x(nx) + (x(nx) - x(nx-1))/2];
dx = diff(x_S);%x grid step size
%
Xx = repmat(x,[1,nx,Sff]);
Xx0 = repmat(x.',[nx,1,Sff]);
Xdx0 = repmat(dx.',[nx,1,Sff]);
Xf0 = repmat(reshape(xf,[1,Sf]),[nx,ones(length(Sff))]);
%
xfs = reshape(sum(Xf0.*Xdx0.*exp(-(Xx - Xx0).^2/dxs.^2)/sqrt(pi)/dxs,2),Sf);
%



