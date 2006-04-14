function J = besselj_dke_jd(N,Z,Mode);
%
% generates the Bessel function of the first kind, J_N(Z).
% 
%   - if Mode <> 0, gives the exact, Matlab generated function
%   - if Mode == 0, gives the approximate value (Z/2)^N/N! valid for Z << 1
%
% Note: - N,Mode must have the same size as Z or be scalars.
%       - N must contain integers
%       - Z must be real for approximate formula
%
% by J. Decker 05/01/03
% 
if nargin < 3
    error('Not enough arguments in besselj_dke_jd')
end
%
SZ = size(Z);
SN = size(N);
SM = size(Mode);
%
if max(size(SN) ~= size(SZ)) | max(SN ~= SZ)
    if length(N) ~= 1
        error('N must be scalar or of the same size as Z')
    end
    N = repmat(N,SZ);
end
%        
if max(size(SM) ~= size(SZ)) | max(SM ~= SZ)
    if length(Mode) ~= 1
        error('Mode must be scalar or of the same size as Z')
    end
    Mode = repmat(Mode,SZ);
end
%
if max(N(:) - floor(N(:))) > 0
    error('N must be integers')
end
%
Mask_approx = (Mode == 0);
%
if min(isreal(Mask_approx(:).*Z(:))) == 0
    error('Z must be real for approximate formula')
end
%
Z = Z.*(N >= 0) + (-1).^N.*(N <0).*Z; % J_{-n}(Z) = J_(n)((-1)^n*Z)
N = abs(N);
%
J = zeros(SZ);
J(~Mask_approx) = besselj(N(~Mask_approx),Z(~Mask_approx));
J(Mask_approx) = (Z(Mask_approx)/2).^N(Mask_approx)./fact_dke_jd(N(Mask_approx));
%