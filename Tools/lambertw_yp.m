% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function w = lambertw_yp(b,z,mode)
% LUKE - LAMBERTW Lambert's W function.
%
%	LAMBERTW Lambert's W function. 
%   W = LAMBERTW(X) is the solution to w*exp(w) = x.
%   W = LAMBERTW(K,X) is the K-th branch of this multi-valued function. Z may be a 
%   complex scalar or array.  For real Z, the result is real on
%   the principal branch for Z >= -1/e.
%
%   W = LAMBERTW(B,Z) specifies which branch of the Lambert 
%   W-Function to compute.  If Z is an array, B may be either an
%   integer array of the same size as Z or an integer scalar.
%   If Z is a scalar, B may be an array of any size.
%
%   The algorithm uses series approximations as initializations
%   and Halley's method as developed in Corless, Gonnet, Hare,
%   Jeffrey, Knuth, "On the Lambert W Function", Advances in
%   Computational Mathematics, volume 5, 1996, pp. 329-359.
%
%	Input:
%
%		- b: data matrix [n,m]
%		- z: data matrix [n,m]
%       - mode: (0) full numerical approach (fast, any matlab version), (1) using Symbolic Math Toolbox is exist and asked (quite slow)
%       
%		  (default = '0')
%
%	Output:
%	
%		- w: Lambert's W function [n,m]
%
[dummy,dummy,flag_toolbox] = matversion_yp('Symbolic Math Toolbox');
%
if flag_toolbox == 0 || nargin < 3, mode = 0;end
%
if nargin == 1,
    z = b;
    b = 0;
end
%
if mode == 0,
    %
    % Use asymptotic expansion w = log(z) - log(log(z)) for most z
    %
    tmp = log(z + (z == 0)) + i*b*6.28318530717958648;
    w = tmp - log(tmp + (tmp == 0));
    %
    % For b = 0, use a series expansion when close to the branch point
    %
    k = find(b == 0 & abs(z + 0.3678794411714423216) <= 1.5);
    tmp = sqrt(5.43656365691809047*z + 2) - 1 + i*b*6.28318530717958648;
    w(k) = tmp(k);
    %
    for k = 1:36
        %
        % Converge with Halley's iterations, about 5 iterations satisfies the tolerance for most z
        %
        c1 = exp(w);
        c2 = w.*c1 - z;
        w1 = w + (w ~= -1);
        dw = c2./(c1.*w1 - ((w + 2).*c2./(2*w1)));
        w = w - dw;
        %
        if all(abs(dw) < 0.7e-16*(2+abs(w)))
            break;
        end
    end
    %
    % Specially handle z = 0
    %
    w(b ~= 0 & z == 0) = -inf;
    %
else
    w = lambertw(b,z); 
end

